#include "registry_fixes.h"
#include "../MentoringProtector_service/service_pipe_protocol.h"
#include <cstdio>
#include <string>
#include <vector>
// build marker - проверка гипотезы о кэшировании репутации Windows для exe
#include <windows.h>

// S3 (Phase C): mp_helper - единственный делегат повышенных команд к службе
// (DEC-057: gate в acceptLoop требует High IL/Administrators, mp_helper уже
// запускается через requireAdministrator-манифест -> UAC -> проходит gate).
// Строгий allowlist - GUI передаёт сюда только имя команды, а не произвольный
// JSON, поэтому здесь нет риска инъекции в reqJson ниже.
static bool isAllowedServiceCmd(const std::string& cmd) {
    return cmd == "realtime_start" || cmd == "realtime_stop" ||
           cmd == "web_start"      || cmd == "web_stop";
}

// Разбивает "a,b,c" на ["a","b","c"]. Простой парсер - входная строка приходит
// от GUI (allowlist-валидируется здесь же ниже), не от внешнего untrusted источника.
static std::vector<std::string> splitCsv(const std::string& s) {
    std::vector<std::string> out;
    size_t start = 0;
    while (start <= s.size()) {
        size_t comma = s.find(',', start);
        if (comma == std::string::npos) { out.push_back(s.substr(start)); break; }
        out.push_back(s.substr(start, comma - start));
        start = comma + 1;
    }
    return out;
}

// Emits a minimal JSON result string. Relies on no external JSON library -
// values are safe ASCII only.
static std::string buildFixResult(bool ok, const std::string& vuln_id,
                                   const std::string& message,
                                   bool reboot_required, DWORD error_code) {
    std::string escaped;
    for (char c : message) {
        if (c == '"')       escaped += "\\\"";
        else if (c == '\\') escaped += "\\\\";
        else                escaped += c;
    }
    char buf[512];
    _snprintf_s(buf, sizeof(buf), _TRUNCATE,
                "{\"ok\":%s,\"vuln_id\":\"%s\",\"message\":\"%s\""
                ",\"reboot_required\":%s,\"error_code\":%lu}",
                ok ? "true" : "false",
                vuln_id.c_str(),
                escaped.c_str(),
                reboot_required ? "true" : "false",
                static_cast<unsigned long>(error_code));
    return std::string(buf);
}

// S3 follow-up: ShellExecuteEx (нужен для реального UAC-диалога - CreateProcess
// без elevated-вызывающего просто возвращает ERROR_ELEVATION_REQUIRED, без UI)
// не даёт родителю pipe/stdout редиректа elevated-процесса. Результат пишем в
// файл, который читает GUI после WaitForSingleObject на handle процесса.
static void writeResultFile(const std::wstring& path, const std::string& json) {
    if (path.empty()) return;
    FILE* f = nullptr;
    if (_wfopen_s(&f, path.c_str(), L"wb") != 0 || !f) return;
    fwrite(json.data(), 1, json.size(), f);
    fclose(f);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("{\"ok\":false,\"message\":\"Usage: mp_helper.exe --fix <vuln_id> | "
               "--list-supported | --service-cmd <name> | --service-cmds <a,b,...> "
               "[--output-file <path>]\"}\n");
        return 1;
    }

    const std::string flag = argv[1];

    // --output-file - необязательный, может стоять после основных аргументов
    // любой ветки (--fix <id> --output-file <path> | --service-cmd <cmd> --output-file <path>).
    std::wstring outputFile;
    for (int i = 2; i + 1 < argc; ++i) {
        if (std::string(argv[i]) == "--output-file") {
            int len = MultiByteToWideChar(CP_UTF8, 0, argv[i + 1], -1, nullptr, 0);
            if (len > 0) {
                std::wstring wpath(static_cast<size_t>(len - 1), L'\0');
                MultiByteToWideChar(CP_UTF8, 0, argv[i + 1], -1, wpath.data(), len);
                outputFile = wpath;
            }
            break;
        }
    }

    if (flag == "--list-supported") {
        char buf[2048];
        _snprintf_s(buf, sizeof(buf), _TRUNCATE, "{\"ok\":true,\"supported\":%s}", listSupported().c_str());
        printf("%s\n", buf);
        writeResultFile(outputFile, buf);
        return 0;
    }

    if (flag == "--fix") {
        if (argc < 3) {
            const char* msg = "{\"ok\":false,\"message\":\"--fix requires a vuln_id argument\"}";
            printf("%s\n", msg);
            writeResultFile(outputFile, msg);
            return 1;
        }
        const std::string vuln_id = argv[2];

        if (!isKnownVulnId(vuln_id)) {
            char buf[256];
            _snprintf_s(buf, sizeof(buf), _TRUNCATE,
                        "{\"ok\":false,\"vuln_id\":\"%s\","
                        "\"message\":\"unknown vuln_id\",\"error_code\":87}",
                        vuln_id.c_str());
            printf("%s\n", buf);
            writeResultFile(outputFile, buf);
            return 1;
        }

        const FixResult r = applyFix(vuln_id);
        const std::string result = buildFixResult(r.ok, vuln_id, r.message, r.reboot_required, r.error_code);
        printf("%s\n", result.c_str());
        writeResultFile(outputFile, result);
        return r.ok ? 0 : 1;
    }

    if (flag == "--service-cmd") {
        if (argc < 3) {
            const char* msg = "{\"ok\":false,\"message\":\"--service-cmd requires a command name\"}";
            printf("%s\n", msg);
            writeResultFile(outputFile, msg);
            return 1;
        }
        const std::string cmd = argv[2];

        if (!isAllowedServiceCmd(cmd)) {
            const char* msg = "{\"ok\":false,\"message\":\"unknown service cmd\"}";
            printf("%s\n", msg);
            writeResultFile(outputFile, msg);
            return 1;
        }

        std::string resp;
        const std::string reqJson = "{\"cmd\":\"" + cmd + "\"}";
        if (!service_pipe::send(reqJson, resp)) {
            const char* msg = "{\"ok\":false,\"message\":\"service_unreachable\"}";
            printf("%s\n", msg);
            writeResultFile(outputFile, msg);
            return 1;
        }

        // Ответ службы уже валидный JSON ({"ok":...,...}) - пробрасываем как есть,
        // HelperBridge на стороне Dart парсит его напрямую.
        printf("%s\n", resp.c_str());
        writeResultFile(outputFile, resp);
        return resp.find("\"ok\":true") != std::string::npos ? 0 : 1;
    }

    // Batch-режим: несколько IPC-команд за ОДИН elevated-запуск -> ОДИН UAC,
    // а не по одному диалогу на команду (UX-фикс для enableAllProtection/
    // disableAllProtection, которые могут запускать realtime+web одновременно).
    if (flag == "--service-cmds") {
        if (argc < 3) {
            const char* msg = "{\"ok\":false,\"message\":\"--service-cmds requires comma-separated command names\"}";
            printf("%s\n", msg);
            writeResultFile(outputFile, msg);
            return 1;
        }
        const std::vector<std::string> cmds = splitCsv(argv[2]);
        bool allOk = true;
        std::string results = "[";
        for (size_t i = 0; i < cmds.size(); ++i) {
            const std::string& cmd = cmds[i];
            std::string entry;
            if (!isAllowedServiceCmd(cmd)) {
                entry = "{\"cmd\":\"" + cmd + "\",\"ok\":false,\"message\":\"unknown service cmd\"}";
                allOk = false;
            } else {
                std::string resp;
                const std::string reqJson = "{\"cmd\":\"" + cmd + "\"}";
                if (!service_pipe::send(reqJson, resp)) {
                    entry = "{\"cmd\":\"" + cmd + "\",\"ok\":false,\"message\":\"service_unreachable\"}";
                    allOk = false;
                } else {
                    // resp уже {"ok":...,...} - вкладываем "cmd" перед остальными полями.
                    entry = "{\"cmd\":\"" + cmd + "\"," + resp.substr(1);
                    if (resp.find("\"ok\":true") == std::string::npos) allOk = false;
                }
            }
            results += entry;
            if (i + 1 < cmds.size()) results += ",";
        }
        results += "]";
        const std::string finalResult = std::string("{\"ok\":") + (allOk ? "true" : "false") +
                                         ",\"results\":" + results + "}";
        printf("%s\n", finalResult.c_str());
        writeResultFile(outputFile, finalResult);
        return allOk ? 0 : 1;
    }

    char buf[256];
    _snprintf_s(buf, sizeof(buf), _TRUNCATE, "{\"ok\":false,\"message\":\"Unknown flag: %s\"}", flag.c_str());
    printf("%s\n", buf);
    writeResultFile(outputFile, buf);
    return 1;
}
