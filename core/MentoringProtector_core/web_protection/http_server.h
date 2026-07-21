#pragma once
#include "../pch.h"
#include "url_checker.h"
#include "auth_token.h"
#include <string>
#include <thread>
#include <atomic>
#include <functional>
#include <vector>
#include <queue>
#include <condition_variable>
#include <unordered_map>

class INudgeSink;

constexpr int WEB_PROTECTION_PORT = 27432;

class WebProtectionServer {
public:
    explicit WebProtectionServer(UrlChecker& checker, INudgeSink* nudge_sink = nullptr);
    ~WebProtectionServer();

    bool start();
    void stop();
    bool isRunning() const;
    int port() const { return port_; }

    WebProtectionServer(const WebProtectionServer&) = delete;
    WebProtectionServer& operator=(const WebProtectionServer&) = delete;

private:
    void acceptLoop();
    void handleClient(SOCKET clientSocket);

    std::string handleCheck(const std::string& query);
    std::string handleStatus() const;
    std::string handleVersion() const;

    static std::string buildResponse(int statusCode, const std::string& body, const std::string& allowedOrigin = "");

    UrlChecker& checker_;
    INudgeSink* nudge_sink_ = nullptr;

protected:
    std::string routeRequest(const std::string& method, const std::string& path, const std::string& query);
    std::string handleNudge(const std::string& query);
    static std::string sanitize(std::string s, size_t cap);
    static std::string urlDecode(const std::string& encoded);
    static std::string getQueryParam(const std::string& query, const std::string& param);
    static bool parseRequestLine(const std::string& request, std::string& method, std::string& path, std::string& query);
    static std::string getHeader(const std::string& request, const std::string& headerName);
    static std::string validateOrigin(const std::string& origin);
    int port_ = WEB_PROTECTION_PORT;
    SOCKET listenSocket_ = INVALID_SOCKET;
    std::atomic<bool> running_{ false };
    std::thread acceptThread_;

    static constexpr int    MAX_WORKER_THREADS = 8;
    std::vector<std::thread> workers_;
    std::queue<SOCKET> taskQueue_;
    std::mutex queueMutex_;
    std::condition_variable queueCV_;
    void workerFunc();

    static constexpr int RATE_LIMIT_MAX_TOKENS = 100;
    static constexpr double RATE_LIMIT_REFILL_PER_SEC = 50.0;
    static constexpr size_t RATE_LIMIT_MAX_ENTRIES = 64;

    struct TokenBucket {
        double tokens = RATE_LIMIT_MAX_TOKENS;
        std::chrono::steady_clock::time_point lastRefill = std::chrono::steady_clock::now();
    };

    std::unordered_map<std::string, TokenBucket> rateBuckets_;
    std::mutex rate_mutex_;
    bool tryConsumeToken(const std::string& clientIP);
};