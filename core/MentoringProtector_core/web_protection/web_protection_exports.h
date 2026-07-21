#pragma once
#include "pch.h"

class INudgeSink;

#ifndef MP_API
#define MP_API extern "C" __declspec(dllexport)
#endif

void web_protection_set_nudge_sink(INudgeSink* sink);

MP_API int web_protection_start(const char* phishingDbPath, const char* safeListPath);
MP_API void web_protection_stop();
MP_API int web_protection_is_running();

MP_API char* web_protection_check_url(const char* url);
MP_API int web_protection_threats_count();

MP_API int web_protection_reload_db(const char* phishingDbPath);

MP_API char* web_protection_get_auth_token();
MP_API int web_protection_regenerate_token();
