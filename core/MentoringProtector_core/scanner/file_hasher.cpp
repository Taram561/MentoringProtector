#include "pch.h"
#include "file_hasher.h"

#pragma comment(lib, "advapi32.lib")

using namespace std;

string FileHasher::bytesToHex(const unsigned char* data, size_t length) {
    ostringstream result;
    result << hex << setfill('0');
    for (size_t i = 0; i < length; i++) result << setw(2) << static_cast<int>(data[i]);
    return result.str();
}
string FileHasher::calculateSHA256(const string& file_path) const {
    wstring wide_path = unicode_utils::utf8_to_wide(file_path);
    HANDLE hFile = CreateFileW(wide_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL);
    if (hFile == INVALID_HANDLE_VALUE) return "";

    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;

    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        CloseHandle(hFile);
        return "";
    }
    if (!CryptCreateHash(hProv, CALG_SHA_256, 0, 0, &hHash)) {
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return "";
    }
    const DWORD BUFFER_SIZE = 64 * 1024;
    BYTE buffer[64 * 1024];
    DWORD bytesRead = 0;
    while (ReadFile(hFile, buffer, BUFFER_SIZE, &bytesRead, NULL) && bytesRead > 0) {
        if (!CryptHashData(hHash, buffer, bytesRead, 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            CloseHandle(hFile);
            return "";
        }
    }
    BYTE hashBytes[32];
    DWORD hashSize = 32;
    if (!CryptGetHashParam(hHash, HP_HASHVAL, hashBytes, &hashSize, 0)) {
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return "";
    }
    CryptDestroyHash(hHash);
    CryptReleaseContext(hProv, 0);
    CloseHandle(hFile);
    return bytesToHex(hashBytes, 32);
}
string FileHasher::calculateMD5(const string& file_path) const {
    wstring wide_path = unicode_utils::utf8_to_wide(file_path);
    HANDLE hFile = CreateFileW(wide_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) return "";
    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;
    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) {
        CloseHandle(hFile);
        return "";
    }
    if (!CryptCreateHash(hProv, CALG_MD5, 0, 0, &hHash)) {
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return "";
    }
    const DWORD BUFFER_SIZE = 4096;
    BYTE buffer[BUFFER_SIZE];
    DWORD bytesRead = 0;
    while (ReadFile(hFile, buffer, BUFFER_SIZE, &bytesRead, NULL) && bytesRead > 0) {
        if (!CryptHashData(hHash, buffer, bytesRead, 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            CloseHandle(hFile);
            return "";
        }
    }
    BYTE hashBytes[16];
    DWORD hashSize = 16;
    if (!CryptGetHashParam(hHash, HP_HASHVAL, hashBytes, &hashSize, 0)) {
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return "";
    }
    CryptDestroyHash(hHash);
    CryptReleaseContext(hProv, 0);
    CloseHandle(hFile);
    return bytesToHex(hashBytes, 16);
}
string FileHasher::calculateSHA1(const string& file_path) const {
    wstring wide_path = unicode_utils::utf8_to_wide(file_path);
    HANDLE hFile = CreateFileW(wide_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) return "";
    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;
    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) {
        CloseHandle(hFile);
        return "";
    }
    if (!CryptCreateHash(hProv, CALG_SHA1, 0, 0, &hHash)) {
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return "";
    }
    const DWORD BUFFER_SIZE = 4096;
    BYTE buffer[BUFFER_SIZE];
    DWORD bytesRead = 0;
    while (ReadFile(hFile, buffer, BUFFER_SIZE, &bytesRead, NULL) && bytesRead > 0) {
        if (!CryptHashData(hHash, buffer, bytesRead, 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            CloseHandle(hFile);
            return "";
        }
    }
    BYTE hashBytes[20];
    DWORD hashSize = 20;
    if (!CryptGetHashParam(hHash, HP_HASHVAL, hashBytes, &hashSize, 0)) {
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return "";
    }
    CryptDestroyHash(hHash);
    CryptReleaseContext(hProv, 0);
    CloseHandle(hFile);
    return bytesToHex(hashBytes, 20);
}

MultiHash FileHasher::calculateAllHashes(const string& file_path) const {
    MultiHash result;
    wstring wide_path = unicode_utils::utf8_to_wide(file_path);
    HANDLE hFile = CreateFileW(wide_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL);
    if (hFile == INVALID_HANDLE_VALUE) return result;
    HCRYPTPROV hProv = 0;
    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        CloseHandle(hFile);
        return result;
    }
    HCRYPTHASH hSha256 = 0, hMd5 = 0, hSha1 = 0;
    if (!CryptCreateHash(hProv, CALG_SHA_256, 0, 0, &hSha256)) hSha256 = 0;
    if (!CryptCreateHash(hProv, CALG_MD5, 0, 0, &hMd5))    hMd5 = 0;
    if (!CryptCreateHash(hProv, CALG_SHA1, 0, 0, &hSha1))   hSha1 = 0;
    if (!hSha256 && !hMd5 && !hSha1) {
        CryptReleaseContext(hProv, 0);
        CloseHandle(hFile);
        return result;
    }
    const DWORD BUFFER_SIZE = 64 * 1024;
    BYTE buffer[64 * 1024];
    DWORD bytesRead = 0;

    while (ReadFile(hFile, buffer, BUFFER_SIZE, &bytesRead, NULL) && bytesRead > 0) {
        if (hSha256) CryptHashData(hSha256, buffer, bytesRead, 0);
        if (hMd5) CryptHashData(hMd5, buffer, bytesRead, 0);
        if (hSha1) CryptHashData(hSha1, buffer, bytesRead, 0);
    }
    BYTE hash256[32], hashMd5[16], hashSha1[20];
    DWORD size;
    size = 32;
    if (hSha256 && CryptGetHashParam(hSha256, HP_HASHVAL, hash256, &size, 0)) result.sha256 = bytesToHex(hash256, 32);
    size = 16;
    if (hMd5 && CryptGetHashParam(hMd5, HP_HASHVAL, hashMd5, &size, 0)) result.md5 = bytesToHex(hashMd5, 16);
    size = 20;
    if (hSha1 && CryptGetHashParam(hSha1, HP_HASHVAL, hashSha1, &size, 0)) result.sha1 = bytesToHex(hashSha1, 20);
    if (hSha256) CryptDestroyHash(hSha256);
    if (hMd5)    CryptDestroyHash(hMd5);
    if (hSha1)   CryptDestroyHash(hSha1);
    CryptReleaseContext(hProv, 0);
    CloseHandle(hFile);

    return result;
}