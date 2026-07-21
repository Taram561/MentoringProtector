#pragma once
#include <string>
#include <sstream>

namespace json_utils {

inline std::string escapeJson(const std::string& s) {
    std::string result;
    result.reserve(s.size() + s.size() / 8);
    for (unsigned char c : s) {
        switch (c) {
        case '"': result += "\\\""; break;
        case '\\': result += "\\\\"; break;
        case '\n': result += "\\n"; break;
        case '\r': result += "\\r"; break;
        case '\t': result += "\\t"; break;
        case '\b': result += "\\b"; break;
        case '\f': result += "\\f"; break;
        default:
            if (c < 0x20) {
                char buf[8];
                snprintf(buf, sizeof(buf), "\\u%04x", c);
                result += buf;
            }
            else { result += static_cast<char>(c); }
            break;
        }
    }
    return result;
}

inline const char* boolToJson(bool value) { return value ? "true" : "false"; }

inline bool parseBool(const std::string& value, bool defaultValue = false) {
    if (value == "true") return true;
    if (value == "false") return false;
    return defaultValue;
}

inline std::string unescapeJsonString(const std::string& s) {
    std::string result;
    result.reserve(s.size());
    for (size_t i = 0; i < s.size(); i++) {
        if (s[i] == '\\' && i + 1 < s.size()) {
            switch (s[i + 1]) {
            case '"': result += '"'; i++; break;
            case '\\': result += '\\'; i++; break;
            case '/': result += '/'; i++; break;
            case 'n': result += '\n'; i++; break;
            case 'r': result += '\r'; i++; break;
            case 't': result += '\t'; i++; break;
            case 'b': result += '\b'; i++; break;
            case 'f': result += '\f'; i++; break;
            case 'u':
                result += s[i];
                break;
            default: result += s[i];
                break;
            }
        } else { result += s[i]; }
    }
    return result;
}

inline std::string extractString(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\": \"";
    size_t pos = json.find(search);
    if (pos == std::string::npos) {
        search = "\"" + key + "\":\"";
        pos = json.find(search);
        if (pos == std::string::npos) return "";
    }
    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length()) {
        if (json[end] == '"') {
            int backslashes = 0;
            for (size_t k = end; k > start && json[k - 1] == '\\'; k--) backslashes++;
            if (backslashes % 2 == 0) break;
        }
        end++;
    }
    return unescapeJsonString(json.substr(start, end - start));
}

inline double extractDouble(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\": ";
    size_t pos = json.find(search);
    if (pos == std::string::npos) {
        search = "\"" + key + "\":";
        pos = json.find(search);
        if (pos == std::string::npos) return 0.0;
    }
    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length() && (std::isdigit(static_cast<unsigned char>(json[end])) || json[end] == '.' || json[end] == '-')) {
        end++;
    }
    try { return std::stod(json.substr(start, end - start)); }
    catch (...) { return 0.0; }
}

inline bool extractBool(const std::string& json, const std::string& key, bool defaultValue = false) {
    std::string search = "\"" + key + "\": ";
    size_t pos = json.find(search);
    if (pos == std::string::npos) {
        search = "\"" + key + "\":";
        pos = json.find(search);
        if (pos == std::string::npos) return defaultValue;
    }
    size_t start = pos + search.length();
    if (json.compare(start, 4, "true") == 0) return true;
    if (json.compare(start, 5, "false") == 0) return false;
    return defaultValue;
}

inline int extractInt(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\": ";
    size_t pos = json.find(search);
    if (pos == std::string::npos) {
        search = "\"" + key + "\":";
        pos = json.find(search);
        if (pos == std::string::npos) return 0;
    }
    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length() && (std::isdigit(static_cast<unsigned char>(json[end])) || json[end] == '-')) {
        end++;
    }
    try { return std::stoi(json.substr(start, end - start)); }
    catch (...) { return 0; }
}

inline std::string extractBlock(const std::string& json, const std::string& key) {
    size_t pos = json.find("\"" + key + "\"");
    if (pos == std::string::npos) return "";
    size_t brace = json.find('{', pos);
    if (brace == std::string::npos) return "";
    int depth = 1;
    size_t end = brace + 1;
    while (end < json.length() && depth > 0) {
        if (json[end] == '{') depth++;
        if (json[end] == '}') depth--;
        if (depth > 0) end++;
    }
    return json.substr(brace, end - brace + 1);
}

inline std::string extractArray(const std::string& json, const std::string& key) {
    size_t pos = json.find("\"" + key + "\"");
    if (pos == std::string::npos) return "";
    size_t bracket = json.find('[', pos);
    if (bracket == std::string::npos) return "";
    int depth = 1;
    size_t end = bracket + 1;
    while (end < json.length() && depth > 0) {
        if (json[end] == '[') depth++;
        if (json[end] == ']') depth--;
        if (depth > 0) end++;
    }
    return json.substr(bracket + 1, end - bracket - 1);
}

class JsonBuilder {
    std::ostringstream ss_;
public:
    JsonBuilder& str(const std::string& key, const std::string& val) {
        ss_ << '"' << key << "\":\"" << escapeJson(val) << "\",";
        return *this;
    }
    JsonBuilder& num(const std::string& key, int val) {
        ss_ << '"' << key << "\":" << val << ',';
        return *this;
    }
    JsonBuilder& num(const std::string& key, long long val) {
        ss_ << '"' << key << "\":" << val << ',';
        return *this;
    }
    JsonBuilder& num(const std::string& key, std::size_t val) {
        ss_ << '"' << key << "\":" << val << ',';
        return *this;
    }
    JsonBuilder& num(const std::string& key, double val, int prec = 2) {
        char buf[32];
        snprintf(buf, sizeof(buf), "%.*f", prec, val);
        ss_ << '"' << key << "\":" << buf << ',';
        return *this;
    }
    JsonBuilder& boolean(const std::string& key, bool val) {
        ss_ << '"' << key << "\":" << (val ? "true" : "false") << ',';
        return *this;
    }
    JsonBuilder& raw(const std::string& key, const std::string& raw_val) {
        ss_ << '"' << key << "\":" << raw_val << ',';
        return *this;
    }
    std::string build() const {
        std::string s = ss_.str();
        if (!s.empty() && s.back() == ',') s.pop_back();
        return "{" + s + "}";
    }
};
class JsonArrayBuilder {
    std::ostringstream ss_;
public:
    JsonArrayBuilder& str(const std::string& val) {
        ss_ << '"' << escapeJson(val) << "\",";
        return *this;
    }
    JsonArrayBuilder& num(int val) {
        ss_ << val << ',';
        return *this;
    }
    JsonArrayBuilder& obj(const std::string& serialized_obj) {
        ss_ << serialized_obj << ',';
        return *this;
    }
    std::string build() const {
        std::string s = ss_.str();
        if (!s.empty() && s.back() == ',') s.pop_back();
        return "[" + s + "]";
    }
};

}