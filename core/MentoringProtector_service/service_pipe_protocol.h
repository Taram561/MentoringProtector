#pragma once
#include <windows.h>
#include <string>

namespace service_pipe {

inline constexpr wchar_t kPipeName[] = L"\\\\.\\pipe\\MentoringProtectorService";

bool send(const std::string& reqJson, std::string& respOut);

}