#pragma once
#include <array>
#include <cstddef>
#include <cstdint>
#include <vector>

class SearchMatcher {
public:
    void addPattern(const uint8_t* pattern, size_t length, size_t id);
    void build();
    std::vector<std::pair<size_t, size_t>> findAll(const uint8_t* data, size_t len) const;
    bool isBuilt() const { return built_; }
    size_t nodeCount() const { return nodes_.size(); }

private:
    struct Node {
        std::array<int, 256> children;
        int fail = 0;
        std::vector<size_t> output;
        Node() { children.fill(-1); }
    };

    std::vector<Node> nodes_;
    bool built_ = false;

    int newNode();
};
