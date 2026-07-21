#pragma once
#include <string>

#ifndef MP_API
#define MP_API extern "C" __declspec(dllexport)
#endif

bool serviceIpcPing(), isServiceHosting(), serviceIpcSend(const std::string& reqJson, std::string& respOut), serviceQueryStatus(bool& realtime, bool& web);
MP_API int mp_service_is_running();