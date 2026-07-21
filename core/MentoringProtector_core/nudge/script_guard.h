#pragma once
#include <string>

namespace script_guard {

struct ScriptGuardResult {
    bool suspicious;
    std::string foundTokens;
};
ScriptGuardResult analyze(const std::string& path_utf8);
}