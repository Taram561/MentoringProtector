#pragma once
#include <string>

namespace motw {
    bool isFromInternet(const std::wstring& path);
    bool isFromInternet(const std::string& path_utf8);
}