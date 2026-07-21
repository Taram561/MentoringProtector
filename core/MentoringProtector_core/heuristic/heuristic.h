#pragma once
#include "pch.h"
#include "../scanner/i_scan_engine.h"

struct HeuristicRule {
    std::string name, description, category;
    int score = 0;
};

struct SignatureInfo {
    bool is_valid = false, is_revoked = false;
    std::string signer_name, issuer, expiry_date, thumbprint, revocation_status;
    bool hasSignature() const { return is_valid; }
};

struct HeuristicResult {
    int suspicion_score = 0, danger_level = 0;
    std::string verdict, error_message;
    double entropy = 0.0;
    bool is_pe_file = false, is_packed = false, has_signature = false, analyzed = false;
    SignatureInfo signature;
    std::vector<std::string> triggered_rules, suspicious_imports, suspicious_strings;
};

class HeuristicRules {
public: HeuristicRules();
    bool loadFromFile(const std::string& json_path);
    bool isLoaded() const;
    double getEntropySuspicious() const;
    double getEntropyMalicious() const;
    int getThresholdClean() const;
    int getThresholdSuspicious() const;
    int getThresholdMalicious() const;
    const std::vector<HeuristicRule>& getImportRules() const;
    const std::vector<HeuristicRule>& getStringRules() const;
    const std::vector<HeuristicRule>& getPeRules() const;

private: bool is_loaded_;
    double entropy_suspicious_, entropy_malicious_;
    int threshold_clean_, threshold_suspicious_, threshold_malicious_;
    std::vector<HeuristicRule> import_rules_, string_rules_, pe_rules_;
    std::vector<HeuristicRule> extractRules(const std::string& json, const std::string& key) const;
};

class HeuristicAnalyzer : public IScanEngine {
public: HeuristicAnalyzer();
    ~HeuristicAnalyzer();
    bool loadRules(const std::string& rules_path);
    HeuristicResult analyze(const std::string& file_path);
    ScanEngineResult scan(const std::string& file_path) override;
    bool isAvailable() const override;
    std::string name() const override { return "heuristic"; }
    bool checkDigitalSignature(const std::string& file_path);
    SignatureInfo extractSignatureInfo(const std::string& file_path, bool check_revocation = false);
    static void prefetchCertificateCache();

private: HeuristicRules* rules_;
    double calculateEntropy(const std::string& file_path);
    bool analyzePeHeader(const std::string& file_path, HeuristicResult& result);
    void analyzeImports(const std::string& file_path, HeuristicResult& result);
    void analyzeStrings(const std::string& file_path, HeuristicResult& result);
    void calculateVerdict(HeuristicResult& result);
    bool isPeFile(const std::string& file_path);
    bool isIndexFile(const std::string& path) const;
    std::vector<std::string> extractStrings(const std::string& file_path, size_t min_length = 4);
    void checkImportRule(const std::string& func_name, HeuristicResult& result);
    bool verifyCatalogSignature(const std::wstring& wide_path);
};
