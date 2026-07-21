#pragma once
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string>

struct FixResult {
    bool ok = false;
    bool reboot_required = false;
    std::string message;
    DWORD error_code = 0;
};

// Returns true if vuln_id is in the whitelist.
bool isKnownVulnId(const std::string& vuln_id);

// Applies the registry fix for the given vuln_id.
FixResult applyFix(const std::string& vuln_id);

// Returns a JSON array of supported vuln IDs.
std::string listSupported();
