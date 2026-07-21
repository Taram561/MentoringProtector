#include "pch.h"
#include "heuristic.h"
#include "../unicode_utils.h"
#include "../json_utils.h"
#include "../logger/logger.h"
#include <wintrust.h>
#include <softpub.h>
#include <wincrypt.h>
#pragma comment(lib, "wintrust.lib")
#pragma comment(lib, "crypt32.lib")

using namespace std;

HeuristicRules::HeuristicRules(): is_loaded_(false), entropy_suspicious_(6.8), entropy_malicious_(7.2), threshold_clean_(20), threshold_suspicious_(50), threshold_malicious_(80) {}

bool HeuristicRules::isLoaded() const { return is_loaded_; }
double HeuristicRules::getEntropySuspicious() const { return entropy_suspicious_; }
double HeuristicRules::getEntropyMalicious() const { return entropy_malicious_; }
int HeuristicRules::getThresholdClean() const { return threshold_clean_; }
int HeuristicRules::getThresholdSuspicious() const { return threshold_suspicious_; }
int HeuristicRules::getThresholdMalicious() const { return threshold_malicious_; }
const vector<HeuristicRule>& HeuristicRules::getImportRules() const { return import_rules_; }
const vector<HeuristicRule>& HeuristicRules::getStringRules() const { return string_rules_; }
const vector<HeuristicRule>& HeuristicRules::getPeRules() const { return pe_rules_; }

vector<HeuristicRule> HeuristicRules::extractRules(const string& json, const string& key) const {
    vector<HeuristicRule> rules;
    string arr = json_utils::extractArray(json, key);
    if (arr.empty()) return rules;
    size_t p = 0;
    while (p < arr.length()) {
        size_t obj_start = arr.find('{', p);
        if (obj_start == string::npos) break;
        size_t obj_end = obj_start + 1;
        int d = 1;
        while (obj_end < arr.length() && d > 0) {
            if (arr[obj_end] == '{') d++;
            if (arr[obj_end] == '}') d--;
            if (d > 0) obj_end++;
        }
        string block = arr.substr(obj_start, obj_end - obj_start + 1);
        HeuristicRule rule;
        rule.name = json_utils::extractString(block, "function");
        if (rule.name.empty()) rule.name = json_utils::extractString(block, "pattern");
        if (rule.name.empty()) rule.name = json_utils::extractString(block, "rule");
        rule.description = json_utils::extractString(block, "description");
        rule.category = json_utils::extractString(block, "category");
        rule.score = json_utils::extractInt(block, "score");
        if (!rule.name.empty()) rules.push_back(rule);
        p = obj_end + 1;
    }
    return rules;
}

bool HeuristicRules::loadFromFile(const string& json_path) {
    is_loaded_ = false;
    ifstream file(json_path);
    if (!file.is_open()) return false;
    string content((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
    file.close();
    if (content.empty()) return false;
    string entropy_block = json_utils::extractBlock(content, "entropy_thresholds");
    if (!entropy_block.empty()) {
        entropy_suspicious_ = json_utils::extractDouble(entropy_block, "suspicious");
        entropy_malicious_ = json_utils::extractDouble(entropy_block, "malicious");
    }
    string verdict_block = json_utils::extractBlock(content, "verdict_thresholds");
    if (!verdict_block.empty()) {
        threshold_clean_ = json_utils::extractInt(verdict_block, "clean");
        threshold_suspicious_ = json_utils::extractInt(verdict_block, "suspicious");
        threshold_malicious_ = json_utils::extractInt(verdict_block, "likely_malicious");
    }
    import_rules_ = extractRules(content, "suspicious_imports");
    string_rules_ = extractRules(content, "suspicious_strings");
    pe_rules_ = extractRules(content, "pe_anomalies");
    is_loaded_ = (!import_rules_.empty() || !string_rules_.empty() || !pe_rules_.empty());
    return is_loaded_;
}

HeuristicAnalyzer::HeuristicAnalyzer() { rules_ = new HeuristicRules(); }
HeuristicAnalyzer::~HeuristicAnalyzer() { delete rules_; }
bool HeuristicAnalyzer::loadRules(const string& rules_path) { return rules_->loadFromFile(rules_path); }

ScanEngineResult HeuristicAnalyzer::scan(const string& file_path) {
    HeuristicResult hr = analyze(file_path);
    ScanEngineResult r;
    r.engine_name = "heuristic";
    r.score = hr.suspicion_score;
    r.is_threat = (hr.suspicion_score >= 70);
    r.threat_name = hr.verdict.empty() ? (r.is_threat ? string("Heuristic.Suspicious") : string()) : hr.verdict;
    return r;
}

bool HeuristicAnalyzer::isAvailable() const { return rules_ != nullptr && rules_->isLoaded(); }

double HeuristicAnalyzer::calculateEntropy(const string& file_path) {
    unsigned long long freq[256] = {};
    unsigned long long total = 0;
    ifstream file(file_path, ios::binary);
    if (!file.is_open()) return 0.0;
    const size_t BUFFER_SIZE = 65536;
    vector<unsigned char> buffer(BUFFER_SIZE);
    while (file.read(reinterpret_cast<char*>(buffer.data()), BUFFER_SIZE) || file.gcount() > 0) {
        size_t bytes_read = static_cast<size_t>(file.gcount());
        for (size_t i = 0; i < bytes_read; i++) { freq[buffer[i]]++; total++; }
    }
    file.close();
    if (total == 0) return 0.0;
    double entropy = 0.0;
    for (int i = 0; i < 256; i++) {
        if (freq[i] == 0) continue;
        double p = static_cast<double>(freq[i]) / static_cast<double>(total);
        entropy -= p * log2(p);
    }
    return entropy;
}

bool HeuristicAnalyzer::isPeFile(const string& file_path) {
    ifstream file(file_path, ios::binary);
    if (!file.is_open()) return false;
    char magic[2] = {};
    file.read(magic, 2);
    file.close();
    return (magic[0] == 'M' && magic[1] == 'Z');
}

bool HeuristicAnalyzer::analyzePeHeader(const string& file_path, HeuristicResult& result) {
    ifstream file(file_path, ios::binary);
    if (!file.is_open()) return false;
    unsigned char dos_header[64] = {};
    file.read(reinterpret_cast<char*>(dos_header), 64);
    if (dos_header[0] != 'M' || dos_header[1] != 'Z') { file.close(); return false; }
    result.is_pe_file = true;
    uint32_t pe_offset = *reinterpret_cast<uint32_t*>(&dos_header[0x3C]);
    file.seekg(pe_offset);
    unsigned char pe_sig[4] = {};
    file.read(reinterpret_cast<char*>(pe_sig), 4);
    if (pe_sig[0] != 'P' || pe_sig[1] != 'E') { file.close(); return false; }
    unsigned char file_header[20] = {};
    file.read(reinterpret_cast<char*>(file_header), 20);
    uint16_t num_sections = *reinterpret_cast<uint16_t*>(&file_header[2]);
    uint16_t opt_hdr_size = *reinterpret_cast<uint16_t*>(&file_header[16]);
    if (opt_hdr_size < 28) { file.close(); return false; }
    unsigned char opt_header[240] = {};
    file.read(reinterpret_cast<char*>(opt_header), (opt_hdr_size < 240 ? opt_hdr_size : 240));
    uint16_t magic = *reinterpret_cast<uint16_t*>(&opt_header[0]);
    uint32_t entry_point = *reinterpret_cast<uint32_t*>(&opt_header[16]);
    bool entry_in_text = false, has_upx = false, has_import_table = false;
    size_t dd_offset = (magic == 0x20B) ? 112 : 96;
    if (opt_hdr_size > (int)(dd_offset + 8)) {
        uint32_t import_rva = *reinterpret_cast<uint32_t*>(&opt_header[dd_offset]);
        has_import_table = (import_rva != 0);
    }
    bool has_rwx_section = false, has_random_section_name = false;
    static const vector<string> known_section_names = { ".text", ".rdata", ".data", ".rsrc", ".reloc", ".pdata", ".idata", ".edata", ".bss", ".tls", ".CRT", ".debug", "CODE", "DATA", ".code", ".xdata", ".cfg", ".gfids", ".00cfg", ".retplne", "UPX0", "UPX1", "UPX2", ".ndata", ".didat", ".sxdata", ".shared", ".cormeta" };
    for (int s = 0; s < num_sections && s < 16; s++) {
        unsigned char section[40] = {};
        file.read(reinterpret_cast<char*>(section), 40);
        string sec_name(reinterpret_cast<char*>(section), 8);
        sec_name = sec_name.substr(0, sec_name.find('\0'));
        uint32_t sec_vaddr = *reinterpret_cast<uint32_t*>(&section[12]);
        uint32_t sec_vsize = *reinterpret_cast<uint32_t*>(&section[8]);
        uint32_t sec_chars = *reinterpret_cast<uint32_t*>(&section[36]);
        if (sec_name == ".text") entry_in_text = (entry_point >= sec_vaddr && entry_point < sec_vaddr + sec_vsize);
        if (sec_name == "UPX0" || sec_name == "UPX1" || sec_name == "UPX2") has_upx = true;
        const uint32_t RWX = 0x20000000 | 0x40000000 | 0x80000000;
        if ((sec_chars & RWX) == RWX) has_rwx_section = true;
        if (!sec_name.empty()) {
            bool known = false;
            for (const auto& kn : known_section_names) { if (sec_name == kn) { known = true; break; } }
            if (!known) {
                int non_alpha = 0;
                for (char c : sec_name) { if (!isalnum(static_cast<unsigned char>(c)) && c != '.' && c != '_') non_alpha++; }
                if (non_alpha > static_cast<int>(sec_name.size()) / 2) has_random_section_name = true;
            }
        }
    }
    file.close();
    if (!has_import_table && has_upx) { result.suspicion_score += 20; result.triggered_rules.push_back("Отсутствует таблица импорта - вероятно упакован или шифрован"); }
    if (entry_in_text == false && has_import_table) {
        int penalty = result.has_signature ? 10 : 35;
        result.suspicion_score += penalty;
        result.triggered_rules.push_back(result.has_signature ? "Точка входа вне .text (подписанный - вероятно инсталлятор)" : "Точка входа находится вне секции .text");
    }
    if (has_upx) { result.is_packed = true; result.suspicion_score += 15; result.triggered_rules.push_back("Обнаружены секции упаковщика UPX"); }
    if (has_rwx_section) { result.suspicion_score += 30; result.triggered_rules.push_back("Обнаружена секция с правами RWX (чтение+запись+выполнение)"); }
    if (has_random_section_name) { result.suspicion_score += 20; result.triggered_rules.push_back("Нестандартное имя секции PE (признак обфускации или custom packer)"); }
    return true;
}

vector<string> HeuristicAnalyzer::extractStrings(const string& file_path, size_t min_length) {
    vector<string> result;
    ifstream file(file_path, ios::binary);
    if (!file.is_open()) return result;
    string current;
    char byte;
    while (file.get(byte)) {
        if ((byte >= 32 && byte <= 126) || byte == '\t' || byte == '\r' || byte == '\n') current += byte;
        else { if (current.length() >= min_length) result.push_back(current); current.clear(); }
    }
    if (current.length() >= min_length) result.push_back(current);
    file.close();
    return result;
}

void HeuristicAnalyzer::analyzeStrings(const string& file_path, HeuristicResult& result) {
    vector<string> strings = extractStrings(file_path, 4);
    if (strings.empty()) return;
    vector<HeuristicRule> rules;
    if (rules_->isLoaded()) rules = rules_->getStringRules();
    else rules = { {"bitcoin", "Упоминание криптовалюты", "ransomware", 40}, {"your files", "Текст вымогателя", "ransomware", 45}, {"encrypted", "Упоминание шифрования", "ransomware", 10}, {"cmd.exe /c", "Скрытый запуск cmd", "execution", 15}, {"powershell -enc", "Закодированный PS скрипт", "execution", 25}, {"powershell -nop", "PowerShell без профиля", "execution", 20}, {".onion", "Адрес сети Tor", "network", 15}, {"HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run", "Запись в автозагрузку", "persistence", 25}, {"CreateRemoteThread", "Внедрение кода (строка)", "injection", 20}, {"VirtualAlloc", "Выделение памяти (строка)", "injection", 10} };
    string all_strings_lower;
    for (const auto& s : strings) {
        string lower = s;
        transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
        all_strings_lower += lower + "\n";
    }
    for (const auto& rule : rules) {
        string pattern_lower = rule.name;
        transform(pattern_lower.begin(), pattern_lower.end(), pattern_lower.begin(), ::tolower);
        if (all_strings_lower.find(pattern_lower) != string::npos) {
            bool already_in_imports = false;
            for (const auto& imp : result.suspicious_imports) {
                string imp_lower = imp;
                transform(imp_lower.begin(), imp_lower.end(), imp_lower.begin(), ::tolower);
                if (imp_lower.find(pattern_lower) != string::npos || pattern_lower.find(imp_lower) != string::npos) { already_in_imports = true; break; }
            }
            if (already_in_imports) continue;
            result.suspicion_score += rule.score;
            result.suspicious_strings.push_back(rule.name);
            result.triggered_rules.push_back(rule.description + " (строка: \"" + rule.name + "\")");
        }
    }
}

void HeuristicAnalyzer::analyzeImports(const string& path, HeuristicResult& result) {
    ifstream file(path, ios::binary);
    if (!file.is_open()) return;
    IMAGE_DOS_HEADER dosHeader;
    file.read(reinterpret_cast<char*>(&dosHeader), sizeof(dosHeader));
    if (dosHeader.e_magic != IMAGE_DOS_SIGNATURE) return;
    file.seekg(dosHeader.e_lfanew, ios::beg);
    DWORD peSignature;
    file.read(reinterpret_cast<char*>(&peSignature), sizeof(DWORD));
    if (peSignature != IMAGE_NT_SIGNATURE) return;
    IMAGE_FILE_HEADER fileHeader;
    file.read(reinterpret_cast<char*>(&fileHeader), sizeof(IMAGE_FILE_HEADER));
    DWORD importDirRVA = 0, importDirSize = 0;
    bool isPE64 = false;
    WORD optMagic;
    file.read(reinterpret_cast<char*>(&optMagic), sizeof(WORD));
    file.seekg(-2, ios::cur);
    if (optMagic == IMAGE_NT_OPTIONAL_HDR64_MAGIC) {
        IMAGE_OPTIONAL_HEADER64 optHeader;
        file.read(reinterpret_cast<char*>(&optHeader), sizeof(optHeader));
        importDirRVA = optHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;
        importDirSize = optHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size;
        isPE64 = true;
    } else {
        IMAGE_OPTIONAL_HEADER32 optHeader;
        file.read(reinterpret_cast<char*>(&optHeader), sizeof(optHeader));
        importDirRVA = optHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;
        importDirSize = optHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size;
    }
    if (importDirRVA == 0) return;
    vector<IMAGE_SECTION_HEADER> sections(fileHeader.NumberOfSections);
    for (auto& section : sections) file.read(reinterpret_cast<char*>(&section), sizeof(IMAGE_SECTION_HEADER));
    auto rvaToOffset = [&](DWORD rva) -> DWORD {
        for (const auto& sec : sections) {
            if (rva >= sec.VirtualAddress && rva < sec.VirtualAddress + sec.SizeOfRawData) return rva - sec.VirtualAddress + sec.PointerToRawData;
        }
        return 0;
    };
    DWORD importOffset = rvaToOffset(importDirRVA);
    if (importOffset == 0) return;
    static constexpr int MAX_IMPORT_DLLS = 500, MAX_FUNCTIONS_PER_DLL = 5000;
    file.seekg(importOffset, ios::beg);
    for (int dllIdx = 0; dllIdx < MAX_IMPORT_DLLS; dllIdx++) {
        IMAGE_IMPORT_DESCRIPTOR descriptor;
        file.read(reinterpret_cast<char*>(&descriptor), sizeof(descriptor));
        if (!file.good() || descriptor.Name == 0) break;
        DWORD nameOffset = rvaToOffset(descriptor.Name);
        if (nameOffset == 0) continue;
        streampos savedPos = file.tellg();
        file.seekg(nameOffset, ios::beg);
        char dllName[256] = {};
        file.read(dllName, sizeof(dllName) - 1);
        file.seekg(savedPos);
        DWORD thunkRVA = descriptor.OriginalFirstThunk != 0 ? descriptor.OriginalFirstThunk : descriptor.FirstThunk;
        DWORD thunkOffset = rvaToOffset(thunkRVA);
        if (thunkOffset == 0) continue;
        file.seekg(thunkOffset, ios::beg);
        for (int funcIdx = 0; funcIdx < MAX_FUNCTIONS_PER_DLL; funcIdx++) {
            ULONGLONG thunk = 0;
            size_t thunkSize = isPE64 ? 8 : 4;
            file.read(reinterpret_cast<char*>(&thunk), thunkSize);
            if (!file.good() || thunk == 0) break;
            bool importByOrdinal = isPE64 ? (thunk & 0x8000000000000000ULL) != 0 : (thunk & 0x80000000UL) != 0;
            if (!importByOrdinal) {
                DWORD nameRVA = static_cast<DWORD>(thunk);
                DWORD funcOffset = rvaToOffset(nameRVA);
                if (funcOffset != 0) {
                    savedPos = file.tellg();
                    file.seekg(funcOffset + 2, ios::beg);
                    char funcName[256] = {};
                    file.read(funcName, sizeof(funcName) - 1);
                    file.seekg(savedPos);
                    checkImportRule(funcName, result);
                }
            }
        }
    }
}

void HeuristicAnalyzer::checkImportRule(const string& func_name, HeuristicResult& result) {
    if (rules_->isLoaded() && !rules_->getImportRules().empty()) {
        for (const auto& rule : rules_->getImportRules()) {
            if (_stricmp(func_name.c_str(), rule.name.c_str()) == 0 || (func_name.length() == rule.name.length() + 1 && _strnicmp(func_name.c_str(), rule.name.c_str(), rule.name.length()) == 0 && (func_name.back() == 'A' || func_name.back() == 'W'))) {
                result.suspicion_score += rule.score;
                result.suspicious_imports.push_back(func_name);
                result.triggered_rules.push_back(rule.description + " (" + func_name + ")");
                return;
            }
        }
        return;
    }
    static const vector<pair<string, int>> RULES = { { "VirtualAllocEx", 20 }, { "WriteProcessMemory", 15 }, { "CreateRemoteThread", 30 }, { "NtUnmapViewOfSection", 35 }, { "SetWindowsHookExA", 15 }, { "SetWindowsHookExW", 15 }, { "CryptEncrypt", 20 }, { "RegSetValueExA", 5 }, { "RegSetValueExW", 5 }, { "ShellExecuteA", 5 }, { "ShellExecuteW", 5 }, { "WinExec", 20 }, { "URLDownloadToFileA", 20 }, { "URLDownloadToFileW", 20 }, { "InternetOpenUrlA", 5 }, { "InternetOpenUrlW", 5 }, { "IsDebuggerPresent", 2 }, { "OpenProcess", 5 } };
    for (const auto& [name, score] : RULES) {
        if (_stricmp(func_name.c_str(), name.c_str()) == 0) { result.suspicion_score += score; result.suspicious_imports.push_back(func_name); result.triggered_rules.push_back("Подозрительный импорт: " + func_name); break; }
    }
}

bool HeuristicAnalyzer::checkDigitalSignature(const string& file_path) {
    wstring wide_path = unicode_utils::utf8_to_wide(file_path);
    WINTRUST_FILE_INFO file_info = {};
    file_info.cbStruct = sizeof(WINTRUST_FILE_INFO);
    file_info.pcwszFilePath = wide_path.c_str();
    file_info.hFile = NULL;
    file_info.pgKnownSubject = NULL;
    GUID action_id = WINTRUST_ACTION_GENERIC_VERIFY_V2;
    WINTRUST_DATA trust_data = {};
    trust_data.cbStruct = sizeof(WINTRUST_DATA);
    trust_data.dwUIChoice = WTD_UI_NONE;
    trust_data.fdwRevocationChecks = WTD_REVOKE_NONE;
    trust_data.dwUnionChoice = WTD_CHOICE_FILE;
    trust_data.pFile = &file_info;
    trust_data.dwStateAction = WTD_STATEACTION_VERIFY;
    trust_data.dwProvFlags = WTD_SAFER_FLAG | WTD_CACHE_ONLY_URL_RETRIEVAL;
    LONG status = WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &trust_data);
    trust_data.dwStateAction = WTD_STATEACTION_CLOSE;
    WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &trust_data);
    if (status == ERROR_SUCCESS) return true;
    return verifyCatalogSignature(wide_path);
}

bool HeuristicAnalyzer::verifyCatalogSignature(const wstring& wide_path) {
    HANDLE hFile = CreateFileW(wide_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    if (hFile == INVALID_HANDLE_VALUE) return false;
    HCATADMIN hCatAdmin = NULL;
    if (!CryptCATAdminAcquireContext(&hCatAdmin, NULL, 0)) { CloseHandle(hFile); return false; }
    DWORD hashSize = 0;
    CryptCATAdminCalcHashFromFileHandle(hFile, &hashSize, NULL, 0);
    if (hashSize == 0) { CryptCATAdminReleaseContext(hCatAdmin, 0); CloseHandle(hFile); return false; }
    vector<BYTE> hash(hashSize);
    if (!CryptCATAdminCalcHashFromFileHandle(hFile, &hashSize, hash.data(), 0)) { CryptCATAdminReleaseContext(hCatAdmin, 0); CloseHandle(hFile); return false; }
    CloseHandle(hFile);
    HCATINFO hCatInfo = CryptCATAdminEnumCatalogFromHash(hCatAdmin, hash.data(), hashSize, 0, NULL);
    bool verified = false;
    if (hCatInfo != NULL) {
        CATALOG_INFO ci = {};
        ci.cbStruct = sizeof(ci);
        if (CryptCATCatalogInfoFromContext(hCatInfo, &ci, 0)) {
            WINTRUST_CATALOG_INFO wci = {};
            wci.cbStruct = sizeof(wci);
            wci.pcwszCatalogFilePath = ci.wszCatalogFile;
            wci.pcwszMemberFilePath = wide_path.c_str();
            wci.pbCalculatedFileHash = hash.data();
            wci.cbCalculatedFileHash = hashSize;
            wstring memberTag;
            memberTag.reserve(hashSize * 2);
            for (DWORD i = 0; i < hashSize; i++) { wchar_t hex[3]; swprintf_s(hex, L"%02X", hash[i]); memberTag += hex; }
            wci.pcwszMemberTag = memberTag.c_str();
            WINTRUST_DATA wtd = {};
            wtd.cbStruct = sizeof(wtd);
            wtd.dwUIChoice = WTD_UI_NONE;
            wtd.fdwRevocationChecks = WTD_REVOKE_NONE;
            wtd.dwUnionChoice = WTD_CHOICE_CATALOG;
            wtd.pCatalog = &wci;
            wtd.dwProvFlags = WTD_SAFER_FLAG | WTD_CACHE_ONLY_URL_RETRIEVAL;
            GUID action = WINTRUST_ACTION_GENERIC_VERIFY_V2;
            LONG status = WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action, &wtd);
            verified = (status == ERROR_SUCCESS);
        }
        CryptCATAdminReleaseCatalogContext(hCatAdmin, hCatInfo, 0);
    }
    CryptCATAdminReleaseContext(hCatAdmin, 0);
    return verified;
}

SignatureInfo HeuristicAnalyzer::extractSignatureInfo(const string& file_path, bool check_revocation) {
    SignatureInfo info;
    wstring wide_path = unicode_utils::utf8_to_wide(file_path);
    WINTRUST_FILE_INFO file_info = {};
    file_info.cbStruct = sizeof(WINTRUST_FILE_INFO);
    file_info.pcwszFilePath = wide_path.c_str();
    GUID action_id = WINTRUST_ACTION_GENERIC_VERIFY_V2;
    WINTRUST_DATA trust_data = {};
    trust_data.cbStruct = sizeof(WINTRUST_DATA);
    trust_data.dwUIChoice = WTD_UI_NONE;
    trust_data.dwUnionChoice = WTD_CHOICE_FILE;
    trust_data.pFile = &file_info;
    trust_data.dwStateAction = WTD_STATEACTION_VERIFY;
    if (check_revocation) { trust_data.fdwRevocationChecks = WTD_REVOKE_WHOLECHAIN; trust_data.dwProvFlags = WTD_SAFER_FLAG; }
    else { trust_data.fdwRevocationChecks = WTD_REVOKE_NONE; trust_data.dwProvFlags = WTD_SAFER_FLAG | WTD_CACHE_ONLY_URL_RETRIEVAL; }
    LONG status = WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &trust_data);
    info.is_valid = (status == ERROR_SUCCESS);
    if (status == (LONG)CERT_E_REVOKED) { info.is_revoked = true; info.revocation_status = "revoked"; }
    else if (info.is_valid) info.revocation_status = check_revocation ? "ok" : "unknown";
    else info.revocation_status = "unknown";
    CRYPT_PROVIDER_DATA* prov_data = WTHelperProvDataFromStateData(trust_data.hWVTStateData);
    if (prov_data) {
        CRYPT_PROVIDER_SGNR* signer = WTHelperGetProvSignerFromChain(prov_data, 0, FALSE, 0);
        if (signer && signer->csCertChain > 0) {
            CRYPT_PROVIDER_CERT* cert = WTHelperGetProvCertFromChain(signer, 0);
            if (cert && cert->pCert) {
                PCCERT_CONTEXT pCert = cert->pCert;
                wchar_t name_buf[256] = {};
                DWORD name_len = CertGetNameStringW(pCert, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, NULL, name_buf, 256);
                if (name_len > 1) info.signer_name = unicode_utils::wide_to_utf8(wstring(name_buf));
                wchar_t issuer_buf[256] = {};
                DWORD issuer_len = CertGetNameStringW(pCert, CERT_NAME_SIMPLE_DISPLAY_TYPE, CERT_NAME_ISSUER_FLAG, NULL, issuer_buf, 256);
                if (issuer_len > 1) info.issuer = unicode_utils::wide_to_utf8(wstring(issuer_buf));
                FILETIME ft = pCert->pCertInfo->NotAfter;
                SYSTEMTIME st = {};
                FileTimeToSystemTime(&ft, &st);
                char date_buf[32] = {};
                snprintf(date_buf, sizeof(date_buf), "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
                info.expiry_date = date_buf;
                BYTE hash[20] = {};
                DWORD hash_size = sizeof(hash);
                if (CertGetCertificateContextProperty(pCert, CERT_HASH_PROP_ID, hash, &hash_size)) {
                    char hex[48] = {};
                    for (DWORD i = 0; i < hash_size; i++) snprintf(hex + i * 2, 3, "%02X", hash[i]);
                    info.thumbprint = hex;
                }
            }
        }
    }
    trust_data.dwStateAction = WTD_STATEACTION_CLOSE;
    WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &trust_data);
    if (!info.is_valid) {
        if (verifyCatalogSignature(wide_path)) {
            info.is_valid = true;
            info.revocation_status = "catalog";
            if (info.signer_name.empty()) { info.signer_name = "Microsoft Windows (catalog)"; info.issuer = "Microsoft Windows Verification PCA"; }
        }
    }
    return info;
}

void HeuristicAnalyzer::prefetchCertificateCache() {
    static const wchar_t* system_files[] = { L"C:\\Windows\\System32\\kernel32.dll", L"C:\\Windows\\explorer.exe", L"C:\\Windows\\System32\\svchost.exe" };
    auto start = chrono::steady_clock::now();
    const auto timeout = chrono::seconds(5);
    for (const auto* path : system_files) {
        if (chrono::steady_clock::now() - start > timeout) { Logger::instance().warning("Heuristic", "CRL prefetch timeout - skipping remaining files"); break; }
        WINTRUST_FILE_INFO fi = {};
        fi.cbStruct = sizeof(fi);
        fi.pcwszFilePath = path;
        GUID action_id = WINTRUST_ACTION_GENERIC_VERIFY_V2;
        WINTRUST_DATA td = {};
        td.cbStruct = sizeof(td);
        td.dwUIChoice = WTD_UI_NONE;
        td.fdwRevocationChecks = WTD_REVOKE_WHOLECHAIN;
        td.dwUnionChoice = WTD_CHOICE_FILE;
        td.pFile = &fi;
        td.dwStateAction = WTD_STATEACTION_VERIFY;
        td.dwProvFlags = WTD_SAFER_FLAG;
        WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &td);
        td.dwStateAction = WTD_STATEACTION_CLOSE;
        WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &td);
    }
    Logger::instance().info("Heuristic", "CRL prefetch completed");
}

void HeuristicAnalyzer::calculateVerdict(HeuristicResult& result) {
    int clean = rules_->isLoaded() ? rules_->getThresholdClean() : 20;
    int suspicious = rules_->isLoaded() ? rules_->getThresholdSuspicious() : 50;
    int malicious = rules_->isLoaded() ? rules_->getThresholdMalicious() : 80;
    if (result.suspicion_score <= clean) { result.verdict = "clean"; result.danger_level = 0; }
    else if (result.suspicion_score <= suspicious) { result.verdict = "suspicious"; result.danger_level = 4; }
    else if (result.suspicion_score <= malicious) { result.verdict = "likely_malicious"; result.danger_level = 7; }
    else { result.verdict = "malicious"; result.danger_level = 9; }
}

bool HeuristicAnalyzer::isIndexFile(const string& path) const {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    size_t dot = lower.rfind('.');
    if (dot == string::npos) return false;
    string ext = lower.substr(dot);
    static const vector<string> index_exts = { ".db", ".dat", ".idx", ".etl", ".evtx", ".evt", ".edb", ".mdb", ".ldb", ".log" };
    for (const auto& ie : index_exts) if (ext == ie) return true;
    return false;
}

HeuristicResult HeuristicAnalyzer::analyze(const string& file_path) {
    HeuristicResult result{};
    result.verdict = "clean";
    ifstream test(file_path);
    if (!test.is_open()) { result.error_message = "Файл не найден или нет доступа"; return result; }
    test.close();
    {
        auto future = async(launch::async, [this, fp = string(file_path)]() { return extractSignatureInfo(fp, false); });
        if (future.wait_for(chrono::seconds(3)) == future_status::ready) result.signature = future.get();
        else { result.signature = SignatureInfo{}; result.signature.is_valid = checkDigitalSignature(file_path); result.signature.revocation_status = "unknown"; }
    }
    result.has_signature = result.signature.is_valid;
    result.entropy = calculateEntropy(file_path);
    if (result.entropy > (rules_->isLoaded() ? rules_->getEntropyMalicious() : 7.2)) {
        int entropy_penalty = result.has_signature ? 5 : 15;
        result.suspicion_score += entropy_penalty;
        result.triggered_rules.push_back("Очень высокая энтропия (" + to_string(result.entropy).substr(0, 4) + ")" + (result.has_signature ? " - вероятно сжатый инсталлятор" : " - может быть Rust/Go/упакованный файл"));
    } else if (result.entropy > (rules_->isLoaded() ? rules_->getEntropySuspicious() : 6.8)) {
        result.suspicion_score += 15;
        result.triggered_rules.push_back("Повышенная энтропия (" + to_string(result.entropy).substr(0, 4) + ") - возможна упаковка");
    }
    if (isPeFile(file_path)) analyzePeHeader(file_path, result);
    if (result.is_pe_file) analyzeImports(file_path, result);
    if (!isIndexFile(file_path)) analyzeStrings(file_path, result);
    if (result.is_pe_file && result.has_signature) {
        static const vector<string> TRUSTED_SIGNERS = { "microsoft", "google", "mozilla", "apple", "valve", "unity", "nvidia", "amd", "intel", "oracle", "adobe", "jetbrains", "autodesk", "vmware", "citrix", "dell", "hp ", "lenovo", "samsung", "logitech", "corsair", "razer", "steelseries", "epic games", "riot games", "blizzard", "electronic arts", "ubisoft", "steam", "github", "slack", "zoom", "discord", "spotify", "dropbox", "1password", "cloudflare", "amazon", "meta platforms" };
        string signer_lower = result.signature.signer_name;
        transform(signer_lower.begin(), signer_lower.end(), signer_lower.begin(), ::tolower);
        bool is_trusted = false;
        for (const auto& trusted : TRUSTED_SIGNERS) { if (signer_lower.find(trusted) != string::npos) { is_trusted = true; break; } }
        int old_score = result.suspicion_score;
        if (is_trusted) {
            result.suspicion_score /= 3;
            if (result.suspicion_score > 15) result.suspicion_score = 15;
            result.triggered_rules.push_back("Доверенный подписант: " + result.signature.signer_name + " (score " + to_string(old_score) + " -> " + to_string(result.suspicion_score) + ")");
        } else {
            result.suspicion_score /= 2;
            result.triggered_rules.push_back("Валидная подпись: " + result.signature.signer_name + " (score " + to_string(old_score) + " -> " + to_string(result.suspicion_score) + ")");
        }
    } else if (result.is_pe_file && !result.has_signature && result.suspicion_score > 20) {
        result.suspicion_score += 10;
        result.triggered_rules.push_back("PE файл не имеет цифровой подписи (+10)");
    }
    if (result.has_signature && result.suspicion_score > 30) {
        auto revoke_future = async(launch::async, [this, fp = string(file_path)]() { return extractSignatureInfo(fp, true); });
        SignatureInfo revoke_check;
        if (revoke_future.wait_for(chrono::seconds(5)) == future_status::ready) revoke_check = revoke_future.get();
        else revoke_check.revocation_status = "offline";
        result.signature.is_revoked = revoke_check.is_revoked;
        result.signature.revocation_status = revoke_check.revocation_status;
        if (revoke_check.is_revoked) { result.suspicion_score += 40; result.triggered_rules.push_back("Сертификат подписи ОТОЗВАН - ключ мог быть украден или использован для подписи малвари (+40)"); }
        else if (revoke_check.revocation_status == "ok") result.triggered_rules.push_back("Онлайн-проверка CRL/OCSP: сертификат не отозван");
    }
    if (!result.has_signature && result.suspicion_score > 0) {
        string lower = file_path;
        transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
        bool in_trusted_path = false, in_package_manager = false;
        if (lower.length() >= 3 && lower[1] == ':' && lower[2] == '\\') {
            string after_drive = lower.substr(2);
            in_trusted_path = (after_drive.find("\\program files\\") == 0) || (after_drive.find("\\program files (x86)\\") == 0) || (after_drive.find("\\windows\\") == 0);
        }
        static const vector<string> PKG_DIRS = { "\\.rustup\\", "\\.cargo\\", "\\.dotnet\\", "\\.nuget\\", "\\scoop\\", "\\chocolatey\\", "\\.npm\\", "\\node_modules\\", "\\.pyenv\\", "\\python\\", "\\.go\\", "\\go\\", "\\.gradle\\", "\\.m2\\", "\\.minikube\\", "\\.kube\\", "\\kubernetes\\", "\\.docker\\", "\\docker\\", "\\.vscode\\", "\\appdata\\local\\programs\\" };
        for (const auto& pkg : PKG_DIRS) { if (lower.find(pkg) != string::npos) { in_package_manager = true; break; } }
        if (in_trusted_path) {
            int old_score = result.suspicion_score;
            result.suspicion_score /= 2;
            if (result.suspicion_score > 30) result.suspicion_score = 30;
            result.triggered_rules.push_back("Файл в системной директории без подписи (score " + to_string(old_score) + " -> " + to_string(result.suspicion_score) + ")");
        } else if (in_package_manager) {
            int old_score = result.suspicion_score;
            result.suspicion_score /= 2;
            result.triggered_rules.push_back("Файл из package manager без подписи (score " + to_string(old_score) + " -> " + to_string(result.suspicion_score) + ")");
        }
    }
    calculateVerdict(result);
    result.analyzed = true;
    return result;
}
