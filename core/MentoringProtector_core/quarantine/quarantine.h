#pragma once
#include "pch.h"

struct QuarantineEntry {
    std::string id, original_path, quarantine_path, original_name, threat_name, threat_type, date_quarantined, file_hash, detection_method;
    int danger_level = 0;
    long long file_size = 0;
    bool is_encrypted = false, is_orphan = false;
};

enum class QuarantineStatus { Success, FileNotFound, AccessDenied, AlreadyExists, NotInQuarantine, DatabaseError, EncryptionError, UnknownError };

class QuarantineManager {
public: QuarantineManager();
    explicit QuarantineManager(const std::string& quarantine_dir);
    ~QuarantineManager();

    QuarantineStatus quarantineFile(QuarantineEntry& entry);
    QuarantineStatus restoreFile(const std::string& entry_id);
    QuarantineStatus restoreFileTo(const std::string& entry_id, const std::string& dest_path);
    QuarantineStatus deleteFile(const std::string& entry_id);
    QuarantineStatus clearAll();
    std::vector<QuarantineEntry> getAllEntries() const;
    const QuarantineEntry* findById(const std::string& entry_id) const;
    size_t getCount() const;
    long long getTotalSize() const;
    bool loadDatabase();
    bool saveDatabase() const;

private:
    std::string quarantine_dir_, db_path_, master_key_path_;
    std::vector<QuarantineEntry> entries_;
    std::vector<BYTE> master_key_;
    bool loadOrCreateMasterKey();
    bool saveMasterKey() const;
    void wipeLegacyEntries();
    QuarantineStatus encryptFileByHandle(HANDLE hSrc, const std::string& dst) const;
    QuarantineStatus decryptFile(const std::string& src, const std::string& dst) const;
    std::string generateId() const;
    std::string getCurrentDateTime() const;
    void removeEntry(const std::string& entry_id);
    std::string entryToJson(const QuarantineEntry& entry) const;
    QuarantineEntry parseEntry(const std::string& json) const;
    std::string extractField(const std::string& json, const std::string& key) const;
    long long extractLongLong(const std::string& json, const std::string& key) const;
    int extractInt(const std::string& json, const std::string& key) const;
};