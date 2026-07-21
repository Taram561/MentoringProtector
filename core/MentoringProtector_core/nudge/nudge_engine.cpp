#include "pch.h"
#include "nudge_engine.h"
#include <algorithm>

using namespace std;
using namespace chrono;

void NudgeEngine::emit(const Nudge& nudge) {
    lock_guard<mutex> lock(mutex_);
    auto now = steady_clock::now();
    string key = makeKey(nudge);

    if (nudge.category == NudgeCategory::DownloadedContainer) {
        int catId = categoryToId(nudge.category);
        auto cit = category_emit_map_.find(catId);
        if (cit != category_emit_map_.end()) {
            auto elapsed = duration_cast<seconds>(now - cit->second).count();
            if (elapsed < CONTAINER_COOLDOWN_SEC) return;
        }
    }

    auto it = dedup_map_.find(key);
    if (it != dedup_map_.end()) {
        auto elapsed = duration_cast<seconds>(now - it->second).count();
        if (elapsed < DEDUP_WINDOW_SEC) {
            if (!nudge.context.empty()) {
                for (auto& q : queue_) {
                    if (makeKey(q) == key && q.context.empty()) {
                        q.context = nudge.context;
                        break;
                    }
                }
            }
            return;
        }
    }

    dedup_map_[key] = now;

    if (nudge.category == NudgeCategory::DownloadedContainer) category_emit_map_[categoryToId(nudge.category)] = now;
    if (dedup_map_.size() > 500) {
        for (auto it2 = dedup_map_.begin(); it2 != dedup_map_.end(); ) {
            if (duration_cast<seconds>(now - it2->second).count() > DEDUP_WINDOW_SEC * 10) it2 = dedup_map_.erase(it2);
            else ++it2;
        }
    }

    Nudge n = nudge;
    if (n.detected_at.empty()) n.detected_at = getCurrentTime();
    queue_.push_back(move(n));

    if (static_cast<int>(queue_.size()) > QUEUE_LIMIT) queue_.erase(queue_.begin(), queue_.begin() + (queue_.size() - QUEUE_LIMIT));
}

vector<Nudge> NudgeEngine::getAndClear() {
    lock_guard<mutex> lock(mutex_);
    vector<Nudge> result = move(queue_);
    queue_.clear();
    return result;
}

string NudgeEngine::makeKey(const Nudge& n) const { return to_string(categoryToId(n.category)) + "|" + n.detail; }

int NudgeEngine::categoryToId(NudgeCategory c) const {
    switch (c) {
    case NudgeCategory::DownloadedExe: return 0;
    case NudgeCategory::MacroDocument: return 1;
    case NudgeCategory::SuspiciousScript: return 2;
    case NudgeCategory::UsbDevice: return 3;
    case NudgeCategory::DownloadedContainer: return 4;
    default: return -1;
    }
}

string NudgeEngine::getCurrentTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}