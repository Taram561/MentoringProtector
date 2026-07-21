#include "pch.h"
#include "service_ipc_client.h"
#include "json_utils.h"
#include "../MentoringProtector_service/service_pipe_protocol.h"

using namespace std;

bool serviceIpcSend(const std::string& reqJson, std::string& respOut) {
    return service_pipe::send(reqJson, respOut);
}

bool serviceIpcPing() {
    std::string resp;
    return serviceIpcSend("{\"cmd\":\"ping\"}", resp) && resp.find("\"ok\":true") != std::string::npos;
}

bool serviceQueryStatus(bool& realtime, bool& web) {
    std::string resp;
    if (!serviceIpcSend("{\"cmd\":\"status\"}", resp)) return false;
    if (resp.find("\"ok\":true") == std::string::npos) return false;
    realtime = json_utils::extractBool(resp, "realtime", false);
    web = json_utils::extractBool(resp, "web", false);
    return true;
}

MP_API int mp_service_is_running() {
    return serviceIpcPing() ? 1 : 0;
}

static std::atomic<bool> g_serviceHostingCached{false};
static std::atomic<long long> g_serviceHostingCheckedAtMs{-1};
constexpr long long kServiceHostingCacheTtlMs = 5000;

bool isServiceHosting() {
    const long long now = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
    const long long checkedAt = g_serviceHostingCheckedAtMs.load();
    if (checkedAt >= 0 && now - checkedAt < kServiceHostingCacheTtlMs) return g_serviceHostingCached.load();
    const bool result = serviceIpcPing();
    g_serviceHostingCached.store(result);
    g_serviceHostingCheckedAtMs.store(now);
    return result;
}