#pragma once
#include "pch.h"
#include "inudge_sink.h"
#include "nudge.h"
#include <vector>
#include <mutex>
#include <unordered_map>
#include <chrono>

class NudgeEngine : public INudgeSink {
public:
    static constexpr int DEDUP_WINDOW_SEC = 10;
    static constexpr int QUEUE_LIMIT = 100;
    static constexpr int CONTAINER_COOLDOWN_SEC = 3600;
    void emit(const Nudge& nudge) override;
    std::vector<Nudge> getAndClear();

private:
    std::vector<Nudge> queue_;
    std::mutex mutex_;
    std::unordered_map<std::string, std::chrono::steady_clock::time_point> dedup_map_;
    std::unordered_map<int, std::chrono::steady_clock::time_point> category_emit_map_;
    std::string makeKey(const Nudge& n) const;
    std::string getCurrentTime() const;
    int categoryToId(NudgeCategory c) const;
};