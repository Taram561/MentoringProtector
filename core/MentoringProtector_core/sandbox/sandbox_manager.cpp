#include "pch.h"
#include "sandbox_manager.h"

SandboxManager& SandboxManager::instance() {
    static SandboxManager inst;
    return inst;
}

SandboxManager::~SandboxManager() {
    {
        std::lock_guard<std::mutex> lk(mtx_);
        if (state_ == SandboxState::Running) {
            state_ = SandboxState::Cancelled;
            if (process_) process_->terminate();
        }
    }
    if (watcher_.joinable()) {
        watcher_.join();
    }
}

bool SandboxManager::isSupported() const {
    HMODULE userenv = GetModuleHandleW(L"userenv.dll");
    if (!userenv) userenv = LoadLibraryExW(L"userenv.dll", nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (!userenv) return false;
    return GetProcAddress(userenv, "CreateAppContainerProfile") != nullptr;
}

SandboxRunResult SandboxManager::run(const std::wstring& filePath, int timeoutSeconds) {
    std::lock_guard<std::mutex> lk(mtx_);
    if (state_ == SandboxState::Running) return {false, "already_running"};

    if (watcher_.joinable()) watcher_.join();

    process_ = std::make_unique<SandboxProcess>();
    monitor_ = nullptr;
    elapsed_s_ = 0;
    report_json_.clear();
    state_ = SandboxState::Idle;

    SandboxConfig cfg;
    cfg.executable_path = filePath;
    cfg.timeout_seconds = timeoutSeconds;
    cfg.memory_limit_mb = 256;

    SandboxLaunchResult res = process_->launch(cfg);
    if (!res.success) {
        state_ = SandboxState::Error;
        report_json_ = "{\"error\":\"" + escapeJson(res.error_code) + "\"}";
        return {false, res.error_code};
    }

    sandbox_pid_ = res.pid;
    monitor_ = std::make_unique<SandboxMonitor>(sandbox_pid_);
    monitor_->start();
    state_ = SandboxState::Running;

    watcher_ = std::thread(&SandboxManager::watcherLoop, this, timeoutSeconds);
    return {true, ""};
}

void SandboxManager::cancel() {
    {
        std::lock_guard<std::mutex> lk(mtx_);
        if (state_ != SandboxState::Running) return;
        state_ = SandboxState::Cancelled;
        if (process_) process_->terminate();
    }
    if (watcher_.joinable()) watcher_.join();
    std::lock_guard<std::mutex> lk(mtx_);
    if (monitor_) {
        monitor_->stop();
        auto events = monitor_->getEvents();
        report_json_ = buildReportJson(events, monitor_->computeRiskScore(), false, elapsed_s_);
    }
}

SandboxState SandboxManager::getState() const {
    std::lock_guard<std::mutex> lk(mtx_);
    return state_;
}

int SandboxManager::getElapsedSeconds() const {
    std::lock_guard<std::mutex> lk(mtx_);
    return elapsed_s_;
}

std::string SandboxManager::getReportJson() const {
    std::lock_guard<std::mutex> lk(mtx_);
    return report_json_.empty() ? "{\"completed\":false}" : report_json_;
}

void SandboxManager::watcherLoop(int timeoutSecs) {
    auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(timeoutSecs);

    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));

        std::lock_guard<std::mutex> lk(mtx_);
        elapsed_s_++;

        if (state_ == SandboxState::Cancelled) break;

        bool timedOut = std::chrono::steady_clock::now() >= deadline;
        bool dead = process_ && !process_->isRunning();

        if (timedOut || dead) {
            if (process_) process_->terminate();
            if (monitor_) monitor_->stop();

            auto events = monitor_ ? monitor_->getEvents() : std::vector<BehavioralEvent>{};
            int  score = monitor_ ? monitor_->computeRiskScore() : 0;
            report_json_ = buildReportJson(events, score, timedOut, elapsed_s_);
            state_ = SandboxState::Completed;
            break;
        }
    }
}

std::string SandboxManager::buildReportJson(const std::vector<BehavioralEvent>& events, int riskScore, bool timedOut, int duration) const {
    int procCreates = 0, moduleLoads = 0;
    bool memSpike = false;
    for (const auto& e : events) {
        if (e.type == "process_create") procCreates++;
        else if (e.type == "module_load") moduleLoads++;
        else if (e.type == "memory_spike") memSpike = true;
    }

    std::ostringstream indicators;
    bool first = true;
    auto addIndicator = [&](const std::string& s) {
        if (!first) indicators << ",";
        indicators << "\"" << escapeJson(s) << "\"";
        first = false;
    };

    if (procCreates > 0) addIndicator("Spawned " + std::to_string(procCreates) + " child process(es)");
    if (moduleLoads > 0) addIndicator("Loaded " + std::to_string(moduleLoads) + " non-system module(s)");
    if (memSpike) addIndicator("Memory usage exceeded 200 MB");
    if (timedOut) addIndicator("Analysis completed after timeout (" + std::to_string(duration) + "s)");

    std::ostringstream evJson;
    for (size_t i = 0; i < events.size(); i++) {
        if (i > 0) evJson << ",";
        const auto& e = events[i];
        evJson << "{" << "\"type\":\"" << escapeJson(e.type) << "\"," << "\"target\":\"" << escapeJson(e.target) << "\"," << "\"detail\":\"" << escapeJson(e.detail) << "\"," << "\"timestamp\":\"" << escapeJson(e.timestamp) << "\"" << "}";
    }

    std::ostringstream json;
    json << "{" << "\"completed\":true," << "\"duration\":" << duration << "," << "\"risk_score\":" << riskScore << "," << "\"timed_out\":" << (timedOut ? "true" : "false") << "," << "\"risk_indicators\":[" << indicators.str() << "]," << "\"events\":[" << evJson.str() << "]" << "}";
    return json.str();
}

std::string SandboxManager::escapeJson(const std::string& s) const {
    std::string out;
    out.reserve(s.size());
    for (char c : s) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\n': out += "\\n";  break;
            case '\r': out += "\\r";  break;
            case '\t': out += "\\t";  break;
            default:
                if (static_cast<unsigned char>(c) < 0x20) {
                    char buf[8];
                    snprintf(buf, sizeof(buf), "\\u%04x", static_cast<unsigned char>(c));
                    out += buf;
                } else { out += c; }
        }
    }
    return out;
}