#include "search.h"
#include <queue>

int SearchMatcher::newNode() {
    nodes_.emplace_back();
    return static_cast<int>(nodes_.size()) - 1;
}

void SearchMatcher::addPattern(const uint8_t* pattern, size_t length, size_t id) {
    if (!pattern || length == 0) return;
    built_ = false;
    if (nodes_.empty()) newNode();
    int cur = 0;
    for (size_t i = 0; i < length; i++) {
        int c = static_cast<unsigned char>(pattern[i]);
        if (nodes_[cur].children[c] == -1) nodes_[cur].children[c] = newNode();
        cur = nodes_[cur].children[c];
    }
    nodes_[cur].output.push_back(id);
}

void SearchMatcher::build() {
    if (nodes_.empty()) { built_ = true; return; }
    std::queue<int> q;
    for (int c = 0; c < 256; c++) {
        if (nodes_[0].children[c] == -1) {
            nodes_[0].children[c] = 0;
        } else {
            nodes_[nodes_[0].children[c]].fail = 0;
            q.push(nodes_[0].children[c]);
        }
    }

    while (!q.empty()) {
        int cur = q.front(); q.pop();
        for (size_t id : nodes_[nodes_[cur].fail].output) nodes_[cur].output.push_back(id);

        for (int c = 0; c < 256; c++) {
            if (nodes_[cur].children[c] == -1) {
                nodes_[cur].children[c] = nodes_[nodes_[cur].fail].children[c];
            } else {
                int child = nodes_[cur].children[c];
                nodes_[child].fail = nodes_[nodes_[cur].fail].children[c];
                q.push(child);
            }
        }
    }
    built_ = true;
}

std::vector<std::pair<size_t, size_t>> SearchMatcher::findAll(const uint8_t* data, size_t len) const {
    std::vector<std::pair<size_t, size_t>> results;
    if (!built_ || nodes_.empty() || !data) return results;
    int state = 0;
    for (size_t i = 0; i < len; i++) {
        state = nodes_[state].children[static_cast<unsigned char>(data[i])];
        for (size_t id : nodes_[state].output) results.emplace_back(id, i);
    }
    return results;
}