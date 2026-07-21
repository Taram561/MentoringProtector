#include "pch.h"
#include "crl_updater.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"
#include <wincrypt.h>
#include <filesystem>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

#pragma comment(lib, "crypt32.lib")
#pragma comment(lib, "cryptnet.lib")

using namespace std;
namespace fs = filesystem;

CrlUpdater::CrlUpdater() = default;
CrlUpdater::~CrlUpdater() { stop(); }

void CrlUpdater::start() {
    if (running_.load()) return;
    running_ = true;
    worker_thread_ = thread(&CrlUpdater::workerLoop, this);
    Logger::instance().info("CrlUpdater", "Background CRL updater started");
}
void CrlUpdater::stop() {
    running_ = false;
    cv_.notify_all();
    if (worker_thread_.joinable()) worker_thread_.join();
    Logger::instance().info("CrlUpdater", "Background CRL updater stopped");
}

bool CrlUpdater::isRunning() const {return running_.load();}

CrlUpdater::Stats CrlUpdater::getStats() const {
    lock_guard<mutex> lock(stats_mutex_);
    return stats_;
}

void CrlUpdater::workerLoop() {
    try {
        updateCycle();
        while (running_.load()) {
            {
                unique_lock<mutex> lk(cv_mutex_);
                cv_.wait_for(lk, chrono::seconds(UPDATE_INTERVAL_SEC), [this] { return !running_.load(); });
            }
            if (running_.load()) updateCycle();
        }
    }
    catch (const exception& e) { Logger::instance().error("CrlUpdater", string("Worker thread exception: ") + e.what()); }
    catch (...) { Logger::instance().error("CrlUpdater", "Worker thread unknown exception"); }
}

void CrlUpdater::updateCycle() {
    Logger::instance().info("CrlUpdater", "Starting CRL update cycle");
    set<string> all_urls;

    try {
        auto urls1 = collectCrlUrls(L"C:\\Program Files");
        all_urls.insert(urls1.begin(), urls1.end());
    }
    catch (const exception& e) { Logger::instance().error("CrlUpdater", string("collectCrlUrls(PF) failed: ") + e.what()); }

    try {
        auto urls2 = collectCrlUrls(L"C:\\Program Files (x86)");
        all_urls.insert(urls2.begin(), urls2.end());
    }
    catch (const exception& e) { Logger::instance().error("CrlUpdater", string("collectCrlUrls(PFx86) failed: ") + e.what()); }

    int updated = 0;
    int failed = 0;

    for (const auto& url : all_urls) {
        if (!running_.load()) break;
        if (downloadCrl(url)) updated++;
        else { failed++; }
    }

    auto now = chrono::system_clock::now();
    auto t = chrono::system_clock::to_time_t(now);
    tm tm_buf = {};
    localtime_s(&tm_buf, &t);

    ostringstream ts;
    ts << put_time(&tm_buf, "%Y-%m-%dT%H:%M:%S");

    {
        lock_guard<mutex> lock(stats_mutex_);
        stats_.urls_found = static_cast<int>(all_urls.size());
        stats_.urls_updated = updated;
        stats_.urls_failed = failed;
        stats_.last_update = ts.str();
    }

    Logger::instance().info("CrlUpdater", "CRL update done: " + to_string(all_urls.size()) + " URLs found, " + to_string(updated) + " updated, " + to_string(failed) + " failed");
}

set<string> CrlUpdater::collectCrlUrls(const wstring& directory) {
    set<string> urls;
    int files_checked = 0;
    const int MAX_FILES = 50;
    error_code ec;
    for (auto& entry : fs::directory_iterator(directory, ec)) {
        if (!running_.load() || files_checked >= MAX_FILES) break;
        if (!entry.is_directory(ec)) continue;

        for (auto& file : fs::directory_iterator(entry.path(), ec)) {
            if (!running_.load() || files_checked >= MAX_FILES) break;
            if (!file.is_regular_file(ec)) continue;

            auto ext = file.path().extension().wstring();
            if (ext != L".exe" && ext != L".EXE" && ext != L".dll" && ext != L".DLL") { continue; }

            auto file_urls = extractCrlUrlsFromFile(file.path().wstring());
            urls.insert(file_urls.begin(), file_urls.end());
            files_checked++;
        }
    }
    return urls;
}

vector<string> CrlUpdater::extractCrlUrlsFromFile(const wstring& file_path) {
    vector<string> urls;
    HCERTSTORE hStore = NULL;
    DWORD encoding = 0, content_type = 0, format_type = 0;
    BOOL ok = CryptQueryObject(CERT_QUERY_OBJECT_FILE, file_path.c_str(), CERT_QUERY_CONTENT_FLAG_PKCS7_SIGNED_EMBED, CERT_QUERY_FORMAT_FLAG_BINARY, 0, &encoding, &content_type, &format_type, &hStore, NULL, NULL);

    if (!ok || !hStore) return urls;

    PCCERT_CONTEXT pCert = NULL;
    while ((pCert = CertEnumCertificatesInStore(hStore, pCert))) {
        PCERT_EXTENSION ext = CertFindExtension(szOID_CRL_DIST_POINTS, pCert->pCertInfo->cExtension, pCert->pCertInfo->rgExtension);
        if (!ext) continue;

        PCRL_DIST_POINTS_INFO pPoints = NULL;
        DWORD points_size = 0;
        if (!CryptDecodeObjectEx(X509_ASN_ENCODING, szOID_CRL_DIST_POINTS, ext->Value.pbData, ext->Value.cbData, CRYPT_DECODE_ALLOC_FLAG, NULL, &pPoints, &points_size)) continue;

        if (pPoints) {
            for (DWORD i = 0; i < pPoints->cDistPoint; i++) {
                auto& dp = pPoints->rgDistPoint[i];
                if (dp.DistPointName.dwDistPointNameChoice == CRL_DIST_POINT_FULL_NAME) {

                    auto& alt = dp.DistPointName.FullName;
                    for (DWORD j = 0; j < alt.cAltEntry; j++) {
                        if (alt.rgAltEntry[j].dwAltNameChoice == CERT_ALT_NAME_URL) {

                            wstring wurl(alt.rgAltEntry[j].pwszURL);
                            string url = unicode_utils::wide_to_utf8(wurl);

                            if (url.find("http") == 0) urls.push_back(url);
                        }
                    }
                }
            }
            LocalFree(pPoints);
        }
    }
    CertCloseStore(hStore, 0);
    return urls;
}

bool CrlUpdater::downloadCrl(const string& url) {
    wstring wide_url = unicode_utils::utf8_to_wide(url);

    CRYPT_BLOB_ARRAY* pObject = NULL;
    CRYPT_RETRIEVE_AUX_INFO aux = {};
    aux.cbSize = sizeof(aux);

    BOOL ok = CryptRetrieveObjectByUrlW(wide_url.c_str(), CONTEXT_OID_CAPI2_ANY, CRYPT_RETRIEVE_MULTIPLE_OBJECTS | CRYPT_CACHE_ONLY_RETRIEVAL, 10000, reinterpret_cast<void**>(&pObject), NULL, NULL, NULL, &aux);

    if (!ok) ok = CryptRetrieveObjectByUrlW(wide_url.c_str(), CONTEXT_OID_CAPI2_ANY, CRYPT_WIRE_ONLY_RETRIEVAL, 10000, reinterpret_cast<void**>(&pObject), NULL, NULL, NULL, &aux);
    if (ok && pObject) {
        for (DWORD i = 0; i < pObject->cBlob; i++) {
        }
        return true;
    }
    return false;
}