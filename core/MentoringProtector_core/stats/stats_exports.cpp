#include "pch.h"
#include "../exports.h"
#include "stats_recorder.h"

namespace {

char* allocCString(const std::string& s) {
    char* result = new char[s.size() + 1];
    memcpy(result, s.c_str(), s.size() + 1);
    return result;
}
char* allocError(const char* msg) {
    std::string j = std::string("{\"error\":\"") + msg + "\"}";
    return allocCString(j);
}

}

extern "C" {

MP_API char* get_threat_stats(int period_days) {
    try {
        auto json = stats::StatsRecorder::instance().getThreatStatsJson(period_days);
        return allocCString(json);
    } catch (const std::exception& e) {
        return allocError(e.what());
    } catch (...) {
        return allocError("unknown");
    }
}

MP_API char* get_scan_history(int period_days) {
    try {
        auto json = stats::StatsRecorder::instance().getScanHistoryJson(period_days);
        return allocCString(json);
    } catch (const std::exception& e) {
        return allocError(e.what());
    } catch (...) {
        return allocError("unknown");
    }
}
MP_API char* get_threat_sources(int period_days) {
    try {
        auto json = stats::StatsRecorder::instance().getThreatSourcesJson(period_days);
        return allocCString(json);
    } catch (const std::exception& e) {
        return allocError(e.what());
    } catch (...) {
        return allocError("unknown");
    }
}

}