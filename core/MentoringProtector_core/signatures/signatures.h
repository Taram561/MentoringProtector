#pragma once
#include "../pch.h"

struct SignatureRecord {
    std::string hash;
    long long file_size;
    std::string threat_name;
};

class SignatureDatabase {
public: 
    SignatureDatabase();
    ~SignatureDatabase();

    int loadFromFile(const std::string& db_path);
    const SignatureRecord* findByHash(const std::string& hash) const;
    size_t getCount() const;
    bool isLoaded() const;

private:
    std::unordered_map<std::string, SignatureRecord> signatures_;
    bool is_loaded_;
    bool parseLine(const std::string& line, SignatureRecord& record);
};