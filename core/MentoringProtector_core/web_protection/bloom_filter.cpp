#include "pch.h"
#include "bloom_filter.h"
#include <cstring>
#include <algorithm>

using namespace std;
namespace mentoring_protector {

BloomFilter::BloomFilter(size_t expected_elements, double false_positive_rate) {

    double ln2 = log(2.0);
    double ln2_sq = ln2 * ln2, n = static_cast<double>(expected_elements), p = false_positive_rate;

    m_numBits = static_cast<size_t>(ceil(-(n * log(p)) / ln2_sq));
    m_numBits = max(m_numBits, static_cast<size_t>(64));
    m_numHashes = static_cast<size_t>(round(static_cast<double>(m_numBits) / n * ln2));
    m_numHashes = max(m_numHashes, static_cast<size_t>(1));
    m_numHashes = min(m_numHashes, static_cast<size_t>(20));
    m_bits.resize((m_numBits + 7) / 8, 0);
}

void BloomFilter::add(const string& element) {
    lock_guard<mutex> lock(m_mutex);
    for (size_t i = 0; i < m_numHashes; ++i) {
        size_t bitIndex = getNthHash(element, i);
        setBit(bitIndex);
    }
    m_elementCount++;
}

bool BloomFilter::mightContain(const string& element) const {
    lock_guard<mutex> lock(m_mutex);
    for (size_t i = 0; i < m_numHashes; ++i) {
        size_t bitIndex = getNthHash(element, i);
        if (!getBit(bitIndex)) return false;
    }
    return true;
}
void BloomFilter::clear() {
    lock_guard<mutex> lock(m_mutex);
    fill(m_bits.begin(), m_bits.end(), 0);
    m_elementCount = 0;
}

double BloomFilter::estimatedFalsePositiveRate() const {
    double k = static_cast<double>(m_numHashes), n = static_cast<double>(m_elementCount), m = static_cast<double>(m_numBits);
    if (m == 0) return 1.0;
    return pow(1.0 - exp(-k * n / m), k);
}

uint32_t BloomFilter::murmurHash3(const string& key, uint32_t seed) const {
    const uint8_t* data = reinterpret_cast<const uint8_t*>(key.data());
    const int len = static_cast<int>(key.length());
    const int nblocks = len / 4;

    uint32_t h1 = seed;

    const uint32_t c1 = 0xcc9e2d51, c2 = 0x1b873593;
    const uint32_t* blocks = reinterpret_cast<const uint32_t*>(data);

    for (int i = 0; i < nblocks; i++) {
        uint32_t k1 = blocks[i];

        k1 *= c1;
        k1 = (k1 << 15) | (k1 >> 17);
        k1 *= c2;
        h1 ^= k1;
        h1 = (h1 << 13) | (h1 >> 19);
        h1 = h1 * 5 + 0xe6546b64;
    }

    const uint8_t* tail = data + nblocks * 4;
    uint32_t k1 = 0;

    switch (len & 3) {
        case 3: k1 ^= tail[2] << 16;
                [[fallthrough]];
        case 2: k1 ^= tail[1] << 8;
                [[fallthrough]];
        case 1: k1 ^= tail[0];
                k1 *= c1;
                k1 = (k1 << 15) | (k1 >> 17);
                k1 *= c2;
                h1 ^= k1;
    }

    h1 ^= static_cast<uint32_t>(len);

    h1 ^= h1 >> 16;
    h1 *= 0x85ebca6b;
    h1 ^= h1 >> 13;
    h1 *= 0xc2b2ae35;
    h1 ^= h1 >> 16;

    return h1;
}

size_t BloomFilter::getNthHash(const string& element, size_t n) const {
    uint32_t h1 = murmurHash3(element, 0), h2 = murmurHash3(element, 42);
    uint64_t combined = static_cast<uint64_t>(h1) + static_cast<uint64_t>(n) * static_cast<uint64_t>(h2);
    return static_cast<size_t>(combined % m_numBits);
}

void BloomFilter::setBit(size_t index) { m_bits[index / 8] |= (1 << (index % 8)); }

bool BloomFilter::getBit(size_t index) const { return (m_bits[index / 8] & (1 << (index % 8))) != 0; }
}