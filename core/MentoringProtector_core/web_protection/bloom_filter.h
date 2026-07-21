#pragma once

#include <string>
#include <vector>
#include <cstdint>
#include <cmath>
#include <mutex>

namespace mentoring_protector {

class BloomFilter {
public:
    explicit BloomFilter(size_t expected_elements = 100000, double false_positive_rate = 0.01);
    void add(const std::string& element);
    bool mightContain(const std::string& element) const;
    void clear();

    size_t getBitCount() const { return m_numBits; }
    size_t getHashCount() const { return m_numHashes; } 
    size_t getMemoryBytes() const { return m_bits.size(); }
    size_t getElementCount() const { return m_elementCount; }

    double estimatedFalsePositiveRate() const;

private:
    uint32_t murmurHash3(const std::string& key, uint32_t seed) const;

    size_t getNthHash(const std::string& element, size_t n) const;

    void setBit(size_t index);
    bool getBit(size_t index) const;

    std::vector<uint8_t> m_bits;
    size_t m_numBits, m_numHashes, m_elementCount = 0;
    mutable std::mutex m_mutex;
};
}