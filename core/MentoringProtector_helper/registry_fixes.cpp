#include "registry_fixes.h"
#include <array>
#include <string_view>
#include <sstream>

// Whitelist of allowed vuln_ids (defense-in-depth: Dart also validates).
static constexpr std::array<std::string_view, 5> kAllowedIds = {
    "smartscreen",
    "firewall",
    "uac",
    "windows_update",
    "autologon",
};

bool isKnownVulnId(const std::string& vuln_id) {
    for (const auto& id : kAllowedIds) {
        if (id == vuln_id) return true;
    }
    return false;
}

// Opens a registry key with explicit 64-bit view to avoid WOW64 redirection.
static LSTATUS openKey64(HKEY root, LPCWSTR sub, HKEY& out,
                         REGSAM extra_access = 0) {
    return RegOpenKeyExW(root, sub, 0,
                         KEY_SET_VALUE | KEY_WOW64_64KEY | extra_access,
                         &out);
}

// Creates (or opens) a registry key in the 64-bit hive.
static LSTATUS createKey64(HKEY root, LPCWSTR sub, HKEY& out) {
    DWORD disp = 0;
    return RegCreateKeyExW(root, sub, 0, nullptr, REG_OPTION_NON_VOLATILE,
                           KEY_SET_VALUE | KEY_WOW64_64KEY,
                           nullptr, &out, &disp);
}

static LSTATUS setDword(HKEY key, LPCWSTR name, DWORD value) {
    return RegSetValueExW(key, name, 0, REG_DWORD,
                          reinterpret_cast<const BYTE*>(&value), sizeof(DWORD));
}

static LSTATUS deleteValue(HKEY key, LPCWSTR name) {
    return RegDeleteValueW(key, name);
}

// ── Individual fix implementations ──────────────────────────────────────────

static FixResult fixSmartScreen() {
    HKEY key = nullptr;
    LSTATUS st = createKey64(
        HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Policies\\Microsoft\\Windows\\System",
        key);
    if (st != ERROR_SUCCESS) {
        return {false, false, "RegCreateKeyEx failed", static_cast<DWORD>(st)};
    }
    st = setDword(key, L"EnableSmartScreen", 1);
    RegCloseKey(key);
    if (st != ERROR_SUCCESS) {
        return {false, false, "RegSetValueEx failed", static_cast<DWORD>(st)};
    }
    return {true, false, "SmartScreen enabled"};
}

static FixResult fixFirewall() {
    static const wchar_t* kProfiles[] = {
        L"SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\"
        L"Parameters\\FirewallPolicy\\StandardProfile",
        L"SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\"
        L"Parameters\\FirewallPolicy\\DomainProfile",
        L"SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\"
        L"Parameters\\FirewallPolicy\\PublicProfile",
    };
    for (const auto* profile : kProfiles) {
        HKEY key = nullptr;
        LSTATUS st = openKey64(HKEY_LOCAL_MACHINE, profile, key);
        if (st != ERROR_SUCCESS) continue;
        setDword(key, L"EnableFirewall", 1);
        RegCloseKey(key);
    }
    return {true, false, "Firewall enabled for all profiles"};
}

static FixResult fixUac() {
    HKEY key = nullptr;
    LSTATUS st = openKey64(
        HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
        key);
    if (st != ERROR_SUCCESS) {
        return {false, false, "RegOpenKeyEx failed", static_cast<DWORD>(st)};
    }
    setDword(key, L"ConsentPromptBehaviorAdmin", 2);
    setDword(key, L"EnableLUA", 1);
    RegCloseKey(key);
    return {true, true, "UAC level raised (reboot required)"};
}

static FixResult fixWindowsUpdate() {
    HKEY key = nullptr;
    LSTATUS st = createKey64(
        HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU",
        key);
    if (st != ERROR_SUCCESS) {
        return {false, false, "RegCreateKeyEx failed", static_cast<DWORD>(st)};
    }
    setDword(key, L"NoAutoUpdate", 0);
    RegCloseKey(key);
    return {true, false, "Windows Update enabled"};
}

static FixResult fixAutoLogon() {
    HKEY key = nullptr;
    LSTATUS st = openKey64(
        HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon",
        key);
    if (st != ERROR_SUCCESS) {
        return {false, false, "RegOpenKeyEx failed", static_cast<DWORD>(st)};
    }
    deleteValue(key, L"AutoAdminLogon");
    deleteValue(key, L"DefaultPassword");
    RegCloseKey(key);
    return {true, false, "Auto-logon disabled"};
}

// ── Dispatcher ──────────────────────────────────────────────────────────────

FixResult applyFix(const std::string& vuln_id) {
    if (vuln_id == "smartscreen")    return fixSmartScreen();
    if (vuln_id == "firewall")       return fixFirewall();
    if (vuln_id == "uac")            return fixUac();
    if (vuln_id == "windows_update") return fixWindowsUpdate();
    if (vuln_id == "autologon")      return fixAutoLogon();
    return {false, false, "unknown vuln_id: " + vuln_id, ERROR_INVALID_PARAMETER};
}

std::string listSupported() {
    std::ostringstream oss;
    oss << "[";
    for (size_t i = 0; i < kAllowedIds.size(); ++i) {
        if (i > 0) oss << ",";
        oss << "\"" << kAllowedIds[i] << "\"";
    }
    oss << "]";
    return oss.str();
}
