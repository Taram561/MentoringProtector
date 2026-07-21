#include "pch.h"
#include <bcrypt.h>
#pragma comment(lib, "bcrypt.lib")
#pragma comment(lib, "crypt32.lib")
#include "quarantine.h"
#include "../json_utils.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"
#include <iomanip>
#include <objbase.h>
#pragma comment(lib, "ole32.lib")

using namespace std;

static const char GCM_MAGIC[4] = { 'M', 'P', '0', '3' };
static const DWORD GCM_NONCE_SIZE = 12;
static const DWORD GCM_TAG_SIZE = 16;

QuarantineManager::QuarantineManager(): quarantine_dir_("..\\quarantine"), db_path_("..\\quarantine\\quarantine.json"), master_key_path_("..\\quarantine\\master.key") {
    CreateDirectoryW(unicode_utils::utf8_to_wide(quarantine_dir_).c_str(), NULL);
    if (!loadOrCreateMasterKey()) Logger::instance().error("Quarantine", "CRITICAL: failed to load/create master key - all operations will return EncryptionError");
    loadDatabase();
    wipeLegacyEntries();
}
QuarantineManager::QuarantineManager(const string& quarantine_dir): quarantine_dir_(quarantine_dir), db_path_(quarantine_dir + "\\quarantine.json"), master_key_path_(quarantine_dir + "\\master.key") {
    CreateDirectoryW(unicode_utils::utf8_to_wide(quarantine_dir_).c_str(), NULL);
    if (!loadOrCreateMasterKey()) Logger::instance().error("Quarantine", "CRITICAL: failed to load/create master key - all operations will return EncryptionError");
    loadDatabase();
    wipeLegacyEntries();
}
QuarantineManager::~QuarantineManager() {
    saveDatabase();
    if (!master_key_.empty()) {
        SecureZeroMemory(master_key_.data(), master_key_.size());
        master_key_.clear();
    }
}
bool QuarantineManager::loadOrCreateMasterKey() {
    ifstream f(unicode_utils::utf8_to_wide(master_key_path_), ios::binary);
    if (f.is_open()) {
        string blob((istreambuf_iterator<char>(f)), {});
        f.close();
        if (!blob.empty()) {
            DATA_BLOB inBlob{ static_cast<DWORD>(blob.size()), reinterpret_cast<BYTE*>(blob.data()) };
            DATA_BLOB outBlob{};
            if (CryptUnprotectData(&inBlob, nullptr, nullptr, nullptr, nullptr, 0, &outBlob)) {
                if (outBlob.cbData == 32) {
                    master_key_.assign(outBlob.pbData, outBlob.pbData + 32);
                    SecureZeroMemory(outBlob.pbData, outBlob.cbData);
                    LocalFree(outBlob.pbData);
                    return true;
                }
                SecureZeroMemory(outBlob.pbData, outBlob.cbData);
                LocalFree(outBlob.pbData);
            }
        }
    }
    master_key_.resize(32);
    HCRYPTPROV hP = 0;
    if (!CryptAcquireContextW(&hP, nullptr, nullptr, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        master_key_.clear();
        return false;
    }
    BOOL ok = CryptGenRandom(hP, 32, master_key_.data());
    CryptReleaseContext(hP, 0);
    if (!ok) {
        SecureZeroMemory(master_key_.data(), master_key_.size());
        master_key_.clear();
        return false;
    }
    return saveMasterKey();
}
bool QuarantineManager::saveMasterKey() const {
    if (master_key_.size() != 32) return false;

    DATA_BLOB inBlob{ 32, const_cast<BYTE*>(master_key_.data()) };
    DATA_BLOB outBlob{};
    if (!CryptProtectData(&inBlob, nullptr, nullptr, nullptr, nullptr, 0, &outBlob)) return false;

    string tmp_path = master_key_path_ + ".tmp";
    ofstream f(unicode_utils::utf8_to_wide(tmp_path), ios::binary);
    if (!f.is_open()) {
        SecureZeroMemory(outBlob.pbData, outBlob.cbData);
        LocalFree(outBlob.pbData);
        return false;
    }
    f.write(reinterpret_cast<const char*>(outBlob.pbData), outBlob.cbData);
    bool written = f.good();
    f.close();
    SecureZeroMemory(outBlob.pbData, outBlob.cbData);
    LocalFree(outBlob.pbData);

    if (!written) {
        DeleteFileW(unicode_utils::utf8_to_wide(tmp_path).c_str());
        return false;
    }
    if (MoveFileExW(unicode_utils::utf8_to_wide(tmp_path).c_str(), unicode_utils::utf8_to_wide(master_key_path_).c_str(), MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH) != 0) return true;
    DeleteFileW(unicode_utils::utf8_to_wide(tmp_path).c_str());
    return false;
}

void QuarantineManager::wipeLegacyEntries() {
    bool changed = false;
    auto it = entries_.begin();
    while (it != entries_.end()) {
        if (it->quarantine_path.empty()) {
            ++it;
            continue;
        }

        bool legacy = true;
        ifstream f(unicode_utils::utf8_to_wide(it->quarantine_path), ios::binary);
        if (f.is_open()) {
            char magic[4] = {};
            f.read(magic, 4);
            auto nread = f.gcount();
            f.close();
            if (nread == 4 && memcmp(magic, GCM_MAGIC, 4) == 0) legacy = false;
        }
        if (legacy) {
            DeleteFileW(unicode_utils::utf8_to_wide(it->quarantine_path).c_str());
            it = entries_.erase(it);
            changed = true;
        } else { ++it;}
    }
    if (changed) saveDatabase();
}
string QuarantineManager::generateId() const {
    GUID guid;
    CoCreateGuid(&guid);

    ostringstream oss;
    oss << uppercase << hex << setfill('0') << setw(8)  << guid.Data1 << '-' << setw(4)  << guid.Data2 << '-' << setw(4)  << guid.Data3 << '-' << setw(2)  << static_cast<int>(guid.Data4[0]) << setw(2)  << static_cast<int>(guid.Data4[1]) << '-' << setw(2)  << static_cast<int>(guid.Data4[2]) << setw(2)  << static_cast<int>(guid.Data4[3]) << setw(2)  << static_cast<int>(guid.Data4[4]) << setw(2)  << static_cast<int>(guid.Data4[5]) << setw(2)  << static_cast<int>(guid.Data4[6]) << setw(2)  << static_cast<int>(guid.Data4[7]);
    return oss.str();
}
string QuarantineManager::getCurrentDateTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    ostringstream oss;
    oss << setfill('0') << setw(4) << st.wYear << '-' << setw(2) << st.wMonth  << '-' << setw(2) << st.wDay << ' ' << setw(2) << st.wHour << ':' << setw(2) << st.wMinute << ':' << setw(2) << st.wSecond;
    return oss.str();
}

static const LONGLONG MAX_QUARANTINE_FILE = 512LL * 1024 * 1024;
static bool openGcmKey(const vector<BYTE>& master_key, BCRYPT_ALG_HANDLE& hAlg, BCRYPT_KEY_HANDLE& hKey, vector<BYTE>& keyObj) {
    hAlg = nullptr; hKey = nullptr;

    if (BCryptOpenAlgorithmProvider(&hAlg, BCRYPT_AES_ALGORITHM, nullptr, 0) != 0) return false;
    if (BCryptSetProperty(hAlg, BCRYPT_CHAINING_MODE, (PUCHAR)BCRYPT_CHAIN_MODE_GCM, sizeof(BCRYPT_CHAIN_MODE_GCM), 0) != 0) {
        BCryptCloseAlgorithmProvider(hAlg, 0); hAlg = nullptr;
        return false;
    }
    DWORD cbKeyObj = 0, cbData = 0;
    if (BCryptGetProperty(hAlg, BCRYPT_OBJECT_LENGTH, (PUCHAR)&cbKeyObj, sizeof(DWORD), &cbData, 0) != 0 || cbKeyObj == 0) {
        BCryptCloseAlgorithmProvider(hAlg, 0); hAlg = nullptr;
        return false;
    }
    keyObj.resize(cbKeyObj);

    if (BCryptGenerateSymmetricKey(hAlg, &hKey, keyObj.data(), cbKeyObj, const_cast<PUCHAR>(master_key.data()), 32, 0) != 0) {
        BCryptCloseAlgorithmProvider(hAlg, 0); hAlg = nullptr;
        return false;
    }
    return true;
}

QuarantineStatus QuarantineManager::encryptFileByHandle(HANDLE hSrc, const string& dst_path) const {
    if (master_key_.size() != 32) return QuarantineStatus::EncryptionError;
    LARGE_INTEGER fileSize{};
    if (!GetFileSizeEx(hSrc, &fileSize) || fileSize.QuadPart > MAX_QUARANTINE_FILE) return QuarantineStatus::EncryptionError;

    size_t plainLen = static_cast<size_t>(fileSize.QuadPart);
    vector<BYTE> plaintext(plainLen);

    struct ZeroOnExit {
        vector<BYTE>& buf;
        ~ZeroOnExit() { if (!buf.empty()) SecureZeroMemory(buf.data(), buf.size()); }
    } _zero{ plaintext };

    if (plainLen > 0) {
        DWORD totalRead = 0;
        while (totalRead < static_cast<DWORD>(plainLen)) {
            DWORD chunk = static_cast<DWORD>(min<size_t>(65536, plainLen - totalRead));
            DWORD bytesRead = 0;
            if (!ReadFile(hSrc, plaintext.data() + totalRead, chunk, &bytesRead, nullptr) || bytesRead == 0) return QuarantineStatus::EncryptionError;
            totalRead += bytesRead;
        }
    }
    BYTE nonce[12];
    {
        HCRYPTPROV hP = 0;
        if (!CryptAcquireContextW(&hP, nullptr, nullptr, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) return QuarantineStatus::EncryptionError;
        BOOL ok = CryptGenRandom(hP, GCM_NONCE_SIZE, nonce);
        CryptReleaseContext(hP, 0);
        if (!ok) return QuarantineStatus::EncryptionError;
    }

    BCRYPT_ALG_HANDLE hAlg = nullptr;
    BCRYPT_KEY_HANDLE hKey = nullptr;
    vector<BYTE> keyObj;
    if (!openGcmKey(master_key_, hAlg, hKey, keyObj)) return QuarantineStatus::EncryptionError;

    vector<BYTE> ciphertext(plainLen);
    BYTE tag[16] = {};

    BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO authInfo;
    BCRYPT_INIT_AUTH_MODE_INFO(authInfo);
    authInfo.pbNonce = nonce;
    authInfo.cbNonce = GCM_NONCE_SIZE;
    authInfo.pbTag = tag;
    authInfo.cbTag = GCM_TAG_SIZE;

    BYTE dummy = 0;
    DWORD cbResult = static_cast<DWORD>(plainLen);
    NTSTATUS ns = BCryptEncrypt(hKey, plainLen > 0 ? plaintext.data() : &dummy, static_cast<ULONG>(plainLen), &authInfo, nullptr, 0, plainLen > 0 ? ciphertext.data() : &dummy, static_cast<ULONG>(plainLen),&cbResult, 0);

    SecureZeroMemory(plaintext.data(), plaintext.size());
    SecureZeroMemory(keyObj.data(), keyObj.size());
    BCryptDestroyKey(hKey);
    BCryptCloseAlgorithmProvider(hAlg, 0);
    if (ns != 0) return QuarantineStatus::EncryptionError;
    ofstream dst(unicode_utils::utf8_to_wide(dst_path), ios::binary);
    if (!dst.is_open()) return QuarantineStatus::FileNotFound;

    dst.write(GCM_MAGIC, 4);
    dst.write(reinterpret_cast<const char*>(nonce), GCM_NONCE_SIZE);
    if (cbResult > 0) dst.write(reinterpret_cast<const char*>(ciphertext.data()), cbResult);
    dst.write(reinterpret_cast<const char*>(tag), GCM_TAG_SIZE);
    if (!dst.good()) {
        dst.close();
        if (!DeleteFileW(unicode_utils::utf8_to_wide(dst_path).c_str())) Logger::instance().warning("Quarantine", "Не удалось удалить частично записанный .lsq файл");
        return QuarantineStatus::EncryptionError;
    }
    return QuarantineStatus::Success;
}
QuarantineStatus QuarantineManager::decryptFile(const string& src_path, const string& dst_path) const {
    if (master_key_.size() != 32) return QuarantineStatus::EncryptionError;
    ifstream src(unicode_utils::utf8_to_wide(src_path), ios::binary);
    if (!src.is_open()) return QuarantineStatus::FileNotFound;
    char magic[4] = {};
    src.read(magic, 4);
    if (src.gcount() != 4 || memcmp(magic, GCM_MAGIC, 4) != 0) {
        src.close();
        return QuarantineStatus::EncryptionError;
    }

    BYTE nonce[12] = {};
    src.read(reinterpret_cast<char*>(nonce), GCM_NONCE_SIZE);
    if (src.gcount() != GCM_NONCE_SIZE) {
        src.close();
        return QuarantineStatus::EncryptionError;
    }

    string blob((istreambuf_iterator<char>(src)), {});
    src.close();

    if (blob.size() < GCM_TAG_SIZE) return QuarantineStatus::EncryptionError;

    size_t cipherLen = blob.size() - GCM_TAG_SIZE;
    BYTE* cipherData = reinterpret_cast<BYTE*>(&blob[0]);
    BYTE  tag[16];
    memcpy(tag, &blob[cipherLen], GCM_TAG_SIZE);

    BCRYPT_ALG_HANDLE hAlg = nullptr;
    BCRYPT_KEY_HANDLE hKey = nullptr;
    vector<BYTE> keyObj;
    if (!openGcmKey(master_key_, hAlg, hKey, keyObj)) {
        SecureZeroMemory(blob.data(), blob.size());
        return QuarantineStatus::EncryptionError;
    }
    vector<BYTE> plaintext(cipherLen);
    BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO authInfo;
    BCRYPT_INIT_AUTH_MODE_INFO(authInfo);
    authInfo.pbNonce = nonce;
    authInfo.cbNonce = GCM_NONCE_SIZE;
    authInfo.pbTag = tag;
    authInfo.cbTag = GCM_TAG_SIZE;

    BYTE dummy = 0;
    DWORD cbPlain = static_cast<DWORD>(cipherLen);
    NTSTATUS ns = BCryptDecrypt(hKey, cipherLen > 0 ? cipherData : &dummy, static_cast<ULONG>(cipherLen), &authInfo, nullptr, 0, cipherLen > 0 ? plaintext.data() : &dummy, static_cast<ULONG>(cipherLen), &cbPlain, 0);

    SecureZeroMemory(blob.data(), blob.size());
    SecureZeroMemory(keyObj.data(), keyObj.size());
    BCryptDestroyKey(hKey);
    BCryptCloseAlgorithmProvider(hAlg, 0);

    if (ns != 0) {
        SecureZeroMemory(plaintext.data(), plaintext.size());
        return QuarantineStatus::EncryptionError;
    }
    ofstream dst(unicode_utils::utf8_to_wide(dst_path), ios::binary);
    if (!dst.is_open()) {
        SecureZeroMemory(plaintext.data(), plaintext.size());
        return QuarantineStatus::FileNotFound;
    }
    if (cbPlain > 0) {
        dst.write(reinterpret_cast<const char*>(plaintext.data()), cbPlain);
        if (!dst.good()) {
            SecureZeroMemory(plaintext.data(), plaintext.size());
            dst.close();
            if (!DeleteFileW(unicode_utils::utf8_to_wide(dst_path).c_str())) Logger::instance().warning("Quarantine", "Не удалось удалить частично восстановленный файл");
            return QuarantineStatus::UnknownError;
        }
    }
    SecureZeroMemory(plaintext.data(), plaintext.size());
    return QuarantineStatus::Success;
}
QuarantineStatus QuarantineManager::quarantineFile(QuarantineEntry& entry) {
    HANDLE hFile = CreateFileW(unicode_utils::utf8_to_wide(entry.original_path).c_str(), GENERIC_READ | DELETE, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_FLAG_OPEN_REPARSE_POINT, nullptr);

    if (hFile == INVALID_HANDLE_VALUE) return QuarantineStatus::FileNotFound;

    BY_HANDLE_FILE_INFORMATION fi{};
    if (GetFileInformationByHandle(hFile, &fi) && (fi.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)) {
        CloseHandle(hFile);
        return QuarantineStatus::AccessDenied;
    }

    for (const auto& e : entries_) {
        if (e.original_path == entry.original_path) {
            CloseHandle(hFile);
            return QuarantineStatus::AlreadyExists;
        }
    }

    LARGE_INTEGER size{};
    GetFileSizeEx(hFile, &size);
    entry.file_size = size.QuadPart;
    entry.id = generateId();
    entry.date_quarantined = getCurrentDateTime();
    size_t slash = entry.original_path.find_last_of("\\/");
    entry.original_name = (slash != string::npos)? entry.original_path.substr(slash + 1): entry.original_path;
    entry.quarantine_path = quarantine_dir_ + "\\" + entry.id + ".lsq";
    entry.is_encrypted = true;

    QuarantineStatus status = encryptFileByHandle(hFile, entry.quarantine_path);

    if (status != QuarantineStatus::Success) {
        CloseHandle(hFile);
        return status;
    }

    FILE_DISPOSITION_INFO fdi{ TRUE };
    if (!SetFileInformationByHandle(hFile, FileDispositionInfo, &fdi, sizeof(fdi))) {
        CloseHandle(hFile);
        DeleteFileW(unicode_utils::utf8_to_wide(entry.quarantine_path).c_str());
        return QuarantineStatus::AccessDenied;
    }
    CloseHandle(hFile);

    entries_.push_back(entry);
    saveDatabase();
    return QuarantineStatus::Success;
}

QuarantineStatus QuarantineManager::restoreFile(const string& entry_id) {
    const QuarantineEntry* entry = findById(entry_id);
    if (entry == nullptr) return QuarantineStatus::NotInQuarantine;

    return restoreFileTo(entry_id, entry->original_path);
}

QuarantineStatus QuarantineManager::restoreFileTo(const string& entry_id, const string& dest_path) {
    const QuarantineEntry* entry = findById(entry_id);
    if (entry == nullptr) return QuarantineStatus::NotInQuarantine;
    DWORD attrs = GetFileAttributesW(unicode_utils::utf8_to_wide(entry->quarantine_path).c_str());
    if (attrs == INVALID_FILE_ATTRIBUTES) return QuarantineStatus::FileNotFound;
    QuarantineStatus status = decryptFile(entry->quarantine_path, dest_path);
    if (status != QuarantineStatus::Success) return status;
    DeleteFileW(unicode_utils::utf8_to_wide(entry->quarantine_path).c_str());
    removeEntry(entry_id);
    saveDatabase();
    return QuarantineStatus::Success;
}

QuarantineStatus QuarantineManager::deleteFile(const string& entry_id) {
    const QuarantineEntry* entry = findById(entry_id);
    if (entry == nullptr) return QuarantineStatus::NotInQuarantine;
    DeleteFileW(unicode_utils::utf8_to_wide(entry->quarantine_path).c_str());
    removeEntry(entry_id);
    saveDatabase();
    return QuarantineStatus::Success;
}
QuarantineStatus QuarantineManager::clearAll() {
    for (const auto& entry : entries_) DeleteFileW(unicode_utils::utf8_to_wide(entry.quarantine_path).c_str());
    entries_.clear();
    saveDatabase();
    return QuarantineStatus::Success;
}

vector<QuarantineEntry> QuarantineManager::getAllEntries() const { return entries_; }

const QuarantineEntry* QuarantineManager::findById(const string& entry_id) const {
    for (const auto& entry : entries_) if (entry.id == entry_id) return &entry;
    return nullptr;
}

size_t QuarantineManager::getCount() const { return entries_.size(); }

long long QuarantineManager::getTotalSize() const {
    long long total = 0;
    for (const auto& entry : entries_) total += entry.file_size;
    return total;
}

void QuarantineManager::removeEntry(const string& entry_id) { entries_.erase(remove_if(entries_.begin(), entries_.end(), [&entry_id](const QuarantineEntry& e) { return e.id == entry_id; }), entries_.end() ); }

string QuarantineManager::entryToJson(const QuarantineEntry& e) const {
    using json_utils::escapeJson;
    using json_utils::boolToJson;
    ostringstream json;
    json << "  {\n" << "    \"id\": \"" << escapeJson(e.id) << "\",\n" << "    \"original_path\": \"" << escapeJson(e.original_path) << "\",\n"  << "    \"quarantine_path\": \"" << escapeJson(e.quarantine_path) << "\",\n" << "    \"original_name\": \"" << escapeJson(e.original_name) << "\",\n" << "    \"threat_name\": \"" << escapeJson(e.threat_name) << "\",\n" << "    \"threat_type\": \"" << escapeJson(e.threat_type) << "\",\n" << "    \"danger_level\": " << e.danger_level << ",\n" << "    \"date_quarantined\": \"" << escapeJson(e.date_quarantined) << "\",\n" << "    \"file_size\": " << e.file_size << ",\n" << "    \"file_hash\": \"" << escapeJson(e.file_hash) << "\",\n" << "    \"detection_method\": \"" << escapeJson(e.detection_method) << "\",\n" << "    \"is_encrypted\": " << boolToJson(e.is_encrypted) << "\n" << "  }";
    return json.str();
}
string QuarantineManager::extractField(const string& json, const string& key) const {
    string search = "\"" + key + "\": \"";
    size_t pos = json.find(search);
    if (pos == string::npos) return "";
    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length()) {
        if (json[end] == '"' && json[end - 1] != '\\') break;
        end++;
    }
    return json.substr(start, end - start);
}

long long QuarantineManager::extractLongLong(const string& json, const string& key) const {
    string search = "\"" + key + "\": ";
    size_t pos = json.find(search);
    if (pos == string::npos) return 0;
    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length() && (isdigit(json[end]) || json[end] == '-')) {
        end++;
    }
    try { return stoll(json.substr(start, end - start)); }
    catch (...) { return 0; }
}

int QuarantineManager::extractInt(const string& json, const string& key) const {
    return (int)extractLongLong(json, key);
}
QuarantineEntry QuarantineManager::parseEntry(const string& json) const {
    QuarantineEntry e;
    e.id = extractField(json, "id");
    e.original_path = extractField(json, "original_path");
    e.quarantine_path = extractField(json, "quarantine_path");
    e.original_name = extractField(json, "original_name");
    e.threat_name = extractField(json, "threat_name");
    e.threat_type = extractField(json, "threat_type");
    e.danger_level = extractInt(json, "danger_level");
    e.date_quarantined = extractField(json, "date_quarantined");
    e.file_size = extractLongLong(json, "file_size");
    e.file_hash = extractField(json, "file_hash");
    e.detection_method = extractField(json, "detection_method");

    string enc_search = "\"is_encrypted\": ";
    size_t enc_pos = json.find(enc_search);
    if (enc_pos != string::npos) {
        size_t val_start = enc_pos + enc_search.length();
        while (val_start < json.length() && json[val_start] == ' ') val_start++;
        e.is_encrypted = (val_start < json.length() && json[val_start] == 't');
    }
    else { e.is_encrypted = false; }
    return e;
}
bool QuarantineManager::saveDatabase() const {
    ofstream file(unicode_utils::utf8_to_wide(db_path_));
    if (!file.is_open()) return false;
    file << "{\n";
    file << "  \"version\": \"1.0.0\",\n";
    file << "  \"entries\": [\n";
    for (size_t i = 0; i < entries_.size(); i++) {
        file << entryToJson(entries_[i]);
        if (i < entries_.size() - 1) file << ",";
        file << "\n";
    }
    file << "  ]\n";
    file << "}\n";
    file.close();
    return true;
}
bool QuarantineManager::loadDatabase() {
    entries_.clear();
    ifstream file(unicode_utils::utf8_to_wide(db_path_));
    if (!file.is_open()) return false;
    string content((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
    file.close();
    if (content.empty()) return false;
    size_t arr_pos = content.find("\"entries\"");
    if (arr_pos == string::npos) return false;
    size_t arr_open = content.find('[', arr_pos);
    if (arr_open == string::npos) return false;

    size_t pos = arr_open + 1;
    while (pos < content.length()) {
        size_t obj_start = content.find('{', pos);
        if (obj_start == string::npos) break;
        size_t obj_end = obj_start + 1;
        int depth = 1;
        while (obj_end < content.length() && depth > 0) {
            if (content[obj_end] == '{') depth++;
            if (content[obj_end] == '}') depth--;
            if (depth > 0) obj_end++;
        }
        string block = content.substr(obj_start, obj_end - obj_start + 1);
        QuarantineEntry entry = parseEntry(block);
        if (!entry.id.empty()) {
            if (entry.quarantine_path.empty() || GetFileAttributesW(unicode_utils::utf8_to_wide(entry.quarantine_path).c_str()) == INVALID_FILE_ATTRIBUTES) entry.is_orphan = true;
            entries_.push_back(entry);
        }
        pos = obj_end + 1;
    }
    return true;
}