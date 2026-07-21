#include "pch.h"
#include "signatures.h"

using namespace std;

SignatureDatabase::SignatureDatabase(): is_loaded_(false) { }
SignatureDatabase::~SignatureDatabase() { }

bool SignatureDatabase::parseLine(const string& line, SignatureRecord& record) {
    if (line.empty() || line[0] == '#') return false;
    size_t first_colon = line.find(':');
    if (first_colon == string::npos) return false;
    size_t second_colon = line.find(':', first_colon + 1);
    if (second_colon == string::npos) return false;
    record.hash = line.substr(0, first_colon);
    string size_str = line.substr(first_colon + 1, second_colon - first_colon - 1);
    try { record.file_size = stoll(size_str); }
    catch (...) { record.file_size = -1; }
    record.threat_name = line.substr(second_colon + 1);
    if (!record.threat_name.empty() && record.threat_name.back() == '\r') { record.threat_name.pop_back(); }
    return !record.hash.empty() && !record.threat_name.empty();
}

int SignatureDatabase::loadFromFile(const string& db_path) {
    signatures_.clear();
    is_loaded_ = false;
    ifstream file(db_path);

    if (!file.is_open()) return 0;

    string line;
    int loaded_count = 0;

    while (getline(file, line)) {
        SignatureRecord record;
        if (parseLine(line, record)) {
            const auto& name = record.threat_name;
            if (name.substr(0, 5) == "Andr." || name.substr(0, 8) == "Android.") { continue; }
            signatures_[record.hash] = record;
            loaded_count++;
        }
    }

    file.close();
    if (loaded_count > 0) is_loaded_ = true;
    return loaded_count;
}
const SignatureRecord* SignatureDatabase::findByHash(const string& hash) const {
    auto it = signatures_.find(hash);
    if (it == signatures_.end()) return nullptr;
    return &(it->second);
}
size_t SignatureDatabase::getCount() const { return signatures_.size(); }

bool SignatureDatabase::isLoaded() const { return is_loaded_; }