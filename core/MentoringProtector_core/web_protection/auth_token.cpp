#include "pch.h"
#include "auth_token.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cstring>

#ifdef _WIN32
    #include <windows.h>
    #include <wincrypt.h>
    #include <aclapi.h>
    #include <sddl.h>
    #pragma comment(lib, "advapi32.lib")
    #pragma comment(lib, "crypt32.lib")
#endif


using namespace std;
namespace mentoring_protector {

AuthToken& AuthToken::getInstance() {
    static AuthToken instance;
    return instance;
}

bool AuthToken::initialize(const string& data_dir) {
    lock_guard<mutex> lock(m_mutex);

    filesystem::path dir(data_dir);
    filesystem::path tokenPath = dir / "auth_token.dat";
    m_tokenFilePath = tokenPath.string();

    filesystem::create_directories(dir);

    if (filesystem::exists(tokenPath) && loadToken(m_tokenFilePath)) {
        if (m_token.length() == 44) {
            m_initialized = true;
            return true;
        }
    }
    unsigned char randomBytes[32];
    if (!generateRandomBytes(randomBytes, sizeof(randomBytes))) return false;

    m_token = base64Encode(randomBytes, sizeof(randomBytes));
#ifdef _WIN32
    SecureZeroMemory(randomBytes, sizeof(randomBytes));
#else
    volatile unsigned char* p = randomBytes;
    for (size_t i = 0; i < sizeof(randomBytes); ++i) p[i] = 0;
#endif

    if (!saveToken(m_tokenFilePath)) return false;
    setFilePermissions(m_tokenFilePath);
    m_initialized = true;
    return true;
}

bool AuthToken::validate(const string& auth_header) const {
    lock_guard<mutex> lock(m_mutex);

    if (!m_initialized || m_token.empty()) return false;
    const string prefix = "Bearer ";
    if ((auth_header.length() != prefix.length() + m_token.length()) || (auth_header.substr(0, prefix.length()) != prefix)) return false;

    string provided_token = auth_header.substr(prefix.length());
    return constantTimeCompare(provided_token, m_token);
}

string AuthToken::getToken() const {
    lock_guard<mutex> lock(m_mutex);
    return m_token;
}

bool AuthToken::regenerate() {
    lock_guard<mutex> lock(m_mutex);

    if (!m_initialized) return false;
    unsigned char randomBytes[32];
    if (!generateRandomBytes(randomBytes, sizeof(randomBytes))) return false;
    m_token = base64Encode(randomBytes, sizeof(randomBytes));

#ifdef _WIN32
    SecureZeroMemory(randomBytes, sizeof(randomBytes));
#endif
    return saveToken(m_tokenFilePath);
}

string AuthToken::getTokenFilePath() const {
    lock_guard<mutex> lock(m_mutex);
    return m_tokenFilePath;
}

bool AuthToken::generateRandomBytes(unsigned char* buffer, size_t length) {
#ifdef _WIN32
    HCRYPTPROV hProv = 0;

    if (!CryptAcquireContextW(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) return false;
    BOOL result = CryptGenRandom(hProv, static_cast<DWORD>(length), buffer);

    CryptReleaseContext(hProv, 0);

    return result == TRUE;
#else
    ifstream urandom("/dev/urandom", ios::binary);
    if (!urandom.is_open()) return false;
    urandom.read(reinterpret_cast<char*>(buffer), length);
    return urandom.good();
#endif
}

string AuthToken::base64Encode(const unsigned char* data, size_t length) {
    static const char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz" "0123456789+/";

    string result;
    result.reserve(4 * ((length + 2) / 3));

    for (size_t i = 0; i < length; i += 3) {
        unsigned int triple = 0;
        int bytes_in_group = 0;

        for (int j = 0; j < 3 && (i + j) < length; ++j) {
            triple = (triple << 8) | data[i + j];
            bytes_in_group++;
        }
        triple <<= (3 - bytes_in_group) * 8;

        result += alphabet[(triple >> 18) & 0x3F];
        result += alphabet[(triple >> 12) & 0x3F];
        result += (bytes_in_group > 1) ? alphabet[(triple >> 6) & 0x3F] : '=';
        result += (bytes_in_group > 2) ? alphabet[triple & 0x3F] : '=';
    }

    return result;
}

bool AuthToken::constantTimeCompare(const string& a, const string& b) const {
    if (a.length() != b.length()) return false;

    volatile unsigned char result = 0;

    for (size_t i = 0; i < a.length(); ++i) {
        result |= static_cast<unsigned char>(a[i]) ^ static_cast<unsigned char>(b[i]);
    }
    return result == 0;
}

bool AuthToken::setFilePermissions(const string& filepath) {
#ifdef _WIN32
    PSECURITY_DESCRIPTOR pSD = NULL;
 BOOL ok = ConvertStringSecurityDescriptorToSecurityDescriptorA("D:PAI(A;;FA;;;OW)(A;;FA;;;SY)", SDDL_REVISION_1, &pSD, NULL);

    if (!ok || !pSD) return false;
    BOOL daclPresent, daclDefaulted;
    PACL pDacl = NULL;
    GetSecurityDescriptorDacl(pSD, &daclPresent, &pDacl, &daclDefaulted);
    DWORD result = SetNamedSecurityInfoA(const_cast<char*>(filepath.c_str()), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION | PROTECTED_DACL_SECURITY_INFORMATION, NULL, NULL, pDacl, NULL);

    LocalFree(pSD);
    return result == ERROR_SUCCESS;
#else
    filesystem::permissions(filepath, filesystem::perms::owner_read | filesystem::perms::owner_write, filesystem::perm_options::replace);
    return true;
#endif
}
bool AuthToken::saveToken(const string& filepath) {
#ifdef _WIN32
    DATA_BLOB plainBlob;
    plainBlob.pbData = reinterpret_cast<BYTE*>(const_cast<char*>(m_token.data()));
    plainBlob.cbData = static_cast<DWORD>(m_token.size());

    DATA_BLOB encryptedBlob = {};

 BOOL ok = CryptProtectData(&plainBlob, L"MentoringProtector Auth Token", NULL, NULL, NULL, 0, &encryptedBlob);

    if (ok && encryptedBlob.pbData) {
        ofstream file(filepath, ios::binary | ios::trunc);
        if (file.is_open()) {
            DWORD size = encryptedBlob.cbData;
            file.write(reinterpret_cast<const char*>(&size), sizeof(size));
            file.write(reinterpret_cast<const char*>(encryptedBlob.pbData), size);
            file.close();
            LocalFree(encryptedBlob.pbData);
            return file.good();
        }
        LocalFree(encryptedBlob.pbData);
    }
    OutputDebugStringA("[MP] DPAPI CryptProtectData failed - token NOT saved\n");
    return false;
#else
    ofstream file(filepath, ios::trunc);
    if (!file.is_open()) return false;
    file << m_token;
    file.close();
    return file.good();
#endif
}

bool AuthToken::loadToken(const string& filepath) {
#ifdef _WIN32
    ifstream file(filepath, ios::binary | ios::ate);
    if (!file.is_open()) return false;

    auto fileSize = file.tellg();
    if (fileSize > static_cast<streampos>(sizeof(DWORD))) {
        file.seekg(0);
        DWORD encSize = 0;
        file.read(reinterpret_cast<char*>(&encSize), sizeof(encSize));

        if (encSize > 0 && encSize <= 4096 && static_cast<streampos>(sizeof(DWORD) + encSize) == fileSize) {

            vector<BYTE> encData(encSize);
            file.read(reinterpret_cast<char*>(encData.data()), encSize);
            DATA_BLOB encryptedBlob;
            encryptedBlob.pbData = encData.data();
            encryptedBlob.cbData = encSize;
            DATA_BLOB plainBlob = {};
            BOOL ok = CryptUnprotectData(&encryptedBlob, NULL, NULL, NULL, NULL, 0, &plainBlob);

            if (ok && plainBlob.pbData) {
                m_token.assign(reinterpret_cast<const char*>(plainBlob.pbData), plainBlob.cbData);
                SecureZeroMemory(plainBlob.pbData, plainBlob.cbData);
                LocalFree(plainBlob.pbData);
                return !m_token.empty();
            }
        }
    }
    file.close();

#endif
    ifstream textFile(filepath);
    if (!textFile.is_open()) return false;
    getline(textFile, m_token);
    m_token.erase(remove_if(m_token.begin(), m_token.end(), ::isspace), m_token.end());

    if (!m_token.empty()) saveToken(filepath);

    return !m_token.empty();
}
}