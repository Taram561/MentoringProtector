#pragma once
#include "../pch.h"
#include "../unicode_utils.h"
#include <wincrypt.h>
#include <iomanip>
#include <sstream>

struct MultiHash {
    std::string sha256;
    std::string md5;
    std::string sha1;
};

class FileHasher {
public:
    std::string calculateSHA256(const std::string& file_path) const, calculateMD5(const std::string& file_path) const, calculateSHA1(const std::string& file_path) const;
    MultiHash calculateAllHashes(const std::string& file_path) const;
    static std::string bytesToHex(const unsigned char* data, size_t length);
};