#pragma once
#include <string>

enum class NudgeCategory {DownloadedExe, MacroDocument, SuspiciousScript, UsbDevice, DownloadedContainer};

struct Nudge {
    NudgeCategory category = NudgeCategory::DownloadedExe;
    std::string detail, context, severity, detected_at;

    bool isSecurity() const { return category == NudgeCategory::DownloadedExe || category == NudgeCategory::SuspiciousScript || category == NudgeCategory::DownloadedContainer; }
};
