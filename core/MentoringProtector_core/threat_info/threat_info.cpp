#include "pch.h"
#include "threat_info.h"

using namespace std;

ThreatDatabase::ThreatDatabase() : is_loaded_(false) {}
ThreatDatabase::~ThreatDatabase() {}

ThreatInfo ThreatDatabase::createUnknown(const string& threat_name) {
    ThreatInfo info;
    info.is_found = false;
    info.name = threat_name;
    info.display_name = "Неизвестная угроза";
    info.type = "unknown";
    info.danger_level = 5;
    info.description_short = "Обнаружен подозрительный файл. " "Подробная информация об этой угрозе отсутствует в базе.";
    info.description_full = "Данная угроза была обнаружена по сигнатуре, однако " "подробное описание в базе знаний MentoringProtector отсутствует. " "Рекомендуется поместить файл в карантин.";
    info.how_it_spreads = "Способ распространения неизвестен.";
    info.what_it_does = "Действия программы неизвестны.";
    info.recommended_action = "quarantine";
    info.removal_steps = { {1, "Поместите файл в карантин через MentoringProtector"}, {2, "Проверьте систему на другие угрозы - запустите полное сканирование"}, {3, "Обновите базу сигнатур и выполните повторное сканирование"} };
    info.prevention_tips = { "Не запускайте файлы из непроверенных источников", "Регулярно обновляйте базу сигнатур MentoringProtector", "Проверяйте файлы на VirusTotal перед запуском" };
    info.hygiene_category = "general";
    return info;
}
string ThreatDatabase::extractJsonString(const string& json, const string& key) const {
    string search = "\"" + key + "\": \"";
    size_t pos = json.find(search);

    if (pos == string::npos) {
        search = "\"" + key + "\":\"";
        pos = json.find(search);
        if (pos == string::npos) return "";
    }
    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length()) {
        if (json[end] == '"' && json[end - 1] != '\\') break;
        end++;
    }
    return json.substr(start, end - start);
}
int ThreatDatabase::extractJsonInt(const string& json, const string& key) const {
    string search = "\"" + key + "\": ";
    size_t pos = json.find(search);

    if (pos == string::npos) {
        search = "\"" + key + "\":";
        pos = json.find(search);
        if (pos == string::npos) return 0;
    }

    size_t start = pos + search.length();
    size_t end = start;
    while (end < json.length() && isdigit(json[end])) { end++; }

    if (start == end) return 0;
    try { return stoi(json.substr(start, end - start)); }
    catch (...) { return 0; }
}
vector<string> ThreatDatabase::extractJsonArray(const string& json, const string& key) const {
    vector<string> result;
    string search = "\"" + key + "\": [";
    size_t pos = json.find(search);

    if (pos == string::npos) {
        search = "\"" + key + "\":[";
        pos = json.find(search);
        if (pos == string::npos) return result;
    }
    size_t arr_start = json.find('[', pos);
    size_t arr_end = json.find(']', arr_start);

    if (arr_start == string::npos || arr_end == string::npos) return result;
    string arr_content = json.substr(arr_start + 1, arr_end - arr_start - 1);
    size_t search_pos = 0;
    while (search_pos < arr_content.length()) {
        size_t q_start = arr_content.find('"', search_pos);
        if (q_start == string::npos) break;

        size_t q_end = q_start + 1;
        while (q_end < arr_content.length()) {
            if (arr_content[q_end] == '"' && arr_content[q_end - 1] != '\\') break;
            q_end++;
        }

        result.push_back(arr_content.substr(q_start + 1, q_end - q_start - 1));
        search_pos = q_end + 1;
    }
    return result;
}
ThreatInfo ThreatDatabase::parseOneThreat(const string& json_block) const {
    ThreatInfo info;
    info.is_found = true;
    info.name = extractJsonString(json_block, "name");
    info.display_name = extractJsonString(json_block, "display_name");
    info.type = extractJsonString(json_block, "type");
    info.danger_level = extractJsonInt(json_block, "danger_level");
    info.description_short = extractJsonString(json_block, "description_short");
    info.description_full = extractJsonString(json_block, "description_full");
    info.how_it_spreads = extractJsonString(json_block, "how_it_spreads");
    info.what_it_does = extractJsonString(json_block, "what_it_does");
    info.recommended_action = extractJsonString(json_block, "recommended_action");
    string steps_search = "\"removal_steps\": [";
    size_t steps_pos = json_block.find(steps_search);
    if (steps_pos == string::npos) {
        steps_search = "\"removal_steps\":[";
        steps_pos = json_block.find(steps_search);
    }
    if (steps_pos != string::npos) {
        auto steps = extractJsonArray(json_block, "removal_steps");
        for (int i = 0; i < (int)steps.size(); i++) {
            RemovalStep step;
            step.step_number = i + 1;
            step.description = steps[i];
            info.removal_steps.push_back(step);
        }
    }
    info.prevention_tips = extractJsonArray(json_block, "prevention_tips");
    info.hygiene_category = extractJsonString(json_block, "hygiene_category");
    return info;
}
int ThreatDatabase::loadFromFile(const string& json_path) {
    threats_.clear();
    is_loaded_ = false;

    ifstream file(json_path);
    if (!file.is_open()) return 0;
    string content((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
    file.close();
    if (content.empty()) return 0;

    string threats_key = "\"threats\"";
    size_t threats_pos = content.find(threats_key);
    if (threats_pos == string::npos) return 0;
    size_t arr_open = content.find('[', threats_pos);
    if (arr_open == string::npos) return 0;
    size_t arr_close = arr_open + 1;
    int depth = 1;
    while (arr_close < content.length() && depth > 0) {
        if (content[arr_close] == '[') depth++;
        if (content[arr_close] == ']') depth--;
        if (depth > 0) arr_close++;
    }
    string arr_content = content.substr(arr_open + 1, arr_close - arr_open - 1);

    int count = 0;
    size_t pos = 0;
    while (pos < arr_content.length()) {
        size_t obj_start = arr_content.find('{', pos);
        if (obj_start == string::npos) break;
        size_t obj_end = obj_start + 1;
        int obj_depth = 1;

        while (obj_end < arr_content.length() && obj_depth > 0) {
            if (arr_content[obj_end] == '{') obj_depth++;
            if (arr_content[obj_end] == '}') obj_depth--;
            if (obj_depth > 0) obj_end++;
        }
        string block = arr_content.substr(obj_start, obj_end - obj_start + 1);

        if (block.find("\"name\"") != string::npos) {
            ThreatInfo info = parseOneThreat(block);
            if (!info.name.empty()) {
                threats_[info.name] = info;
                count++;
            }
        }
        pos = obj_end + 1;
    }
    if (count > 0) is_loaded_ = true;
    return count;
}

ThreatInfo ThreatDatabase::findByName(const string& threat_name) const {
    auto it = threats_.find(threat_name);
    if (it == threats_.end()) return createUnknown(threat_name);
    return it->second;
}
vector<ThreatInfo> ThreatDatabase::findByType(const string& type) const {
    vector<ThreatInfo> result;
    for (const auto& pair : threats_) {
        if (pair.second.type == type) result.push_back(pair.second);
    }
    return result;
}
size_t ThreatDatabase::getCount() const { return threats_.size(); }
bool ThreatDatabase::isLoaded() const { return is_loaded_; }