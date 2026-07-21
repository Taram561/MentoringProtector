#pragma once
#include "pch.h"

#define MP_API extern "C" __declspec(dllexport)

MP_API char* get_file_hash(const char* file_path);
MP_API char* scan_file(const char* file_path);

MP_API void free_string(char* ptr);


MP_API char* get_core_version();
MP_API unsigned int mp_get_api_version();
MP_API int reload_signatures();
MP_API char* get_active_engines();
MP_API char* core_initialize();

MP_API char* quarantine_file(const char* file_path, const char* threat_name, const char* threat_type, int danger_level, const char* file_hash, const char* detection_method);
MP_API char* restore_file(const char* entry_id);
MP_API char* delete_from_quarantine(const char* entry_id);
MP_API char* get_quarantine_list();

MP_API char* start_process_monitoring();
MP_API char* stop_process_monitoring();
MP_API char* get_process_alerts();
MP_API char* analyze_process(int pid);
MP_API char* is_monitoring();
MP_API char* terminate_process_by_pid(int pid);

MP_API char* scan_vulnerabilities();
MP_API char* get_vuln_fix_descriptor(const char* vuln_id);

MP_API char* scan_computer_start();
MP_API char* scan_computer_get_progress();
MP_API char* scan_computer_stop();

MP_API char* start_realtime_monitor();
MP_API char* stop_realtime_monitor();
MP_API char* is_realtime_monitoring();
MP_API char* get_realtime_events();

MP_API char* start_memory_scan();
MP_API char* stop_memory_scan();
MP_API char* get_memory_scan_progress();
MP_API char* scan_process_memory(int pid);

MP_API char* get_etw_status();
MP_API char* get_dll_injection_alerts();

MP_API char* smart_scan_get_stats();
MP_API char* smart_scan_invalidate();
MP_API char* smart_scan_clear();

MP_API char* get_yara_status();
MP_API char* yara_reload_rules();

MP_API char* get_exclusions();
MP_API char* add_exclusion(const char* path);
MP_API char* remove_exclusion(const char* path);
MP_API char* test_export();

MP_API char* get_threat_stats(int period_days);
MP_API char* get_scan_history(int period_days);
MP_API char* get_threat_sources(int period_days);
MP_API int mp_verify_helper_exe(const char* path);

#include "service_ipc_client.h"

MP_API char* archive_scan_supported();

MP_API char* sandbox_is_supported();
MP_API char* sandbox_run(const char* file_path);
MP_API char* sandbox_get_status();
MP_API char* sandbox_get_report();
MP_API char* sandbox_cancel();

MP_API char* nudge_get_pending();
MP_API void tray_show_balloon(const char* title, const char* text);
MP_API char* tray_consume_click();