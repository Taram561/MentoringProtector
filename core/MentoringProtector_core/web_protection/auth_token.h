#pragma once

#include <string>
#include <mutex>
#include <filesystem>

namespace mentoring_protector {

class AuthToken {

public:
    static AuthToken& getInstance();

    AuthToken(const AuthToken&) = delete;
    AuthToken& operator=(const AuthToken&) = delete;
    bool initialize(const std::string& data_dir), validate(const std::string& auth_header) const, regenerate();
    std::string getToken() const, getTokenFilePath() const;

private: AuthToken() = default;
    bool generateRandomBytes(unsigned char* buffer, size_t length), constantTimeCompare(const std::string& a, const std::string& b) const, setFilePermissions(const std::string& filepath), saveToken(const std::string& filepath), loadToken(const std::string& filepath), m_initialized = false;
    std::string base64Encode(const unsigned char* data, size_t length), m_token, m_tokenFilePath;
    mutable std::mutex m_mutex;
};
}