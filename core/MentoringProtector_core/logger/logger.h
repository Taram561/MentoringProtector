#pragma once
#include "pch.h"

enum class LogLevel { Debug, Info, Warning, Error };

class Logger {
public:
    static Logger& instance();
    void log(LogLevel level, const std::string& module, const std::string& message);
    void debug(const std::string& m, const std::string& msg) {log(LogLevel::Debug, m, msg);}
    void info(const std::string& m, const std::string& msg) {log(LogLevel::Info, m, msg);}
    void warning(const std::string& m, const std::string& msg) {log(LogLevel::Warning, m, msg);}
    void error(const std::string& m, const std::string& msg) {log(LogLevel::Error, m, msg);}

private: Logger();
    ~Logger();
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

    std::ofstream log_file_;
    std::mutex mutex_;
    std::condition_variable flush_cv_;
    std::atomic<bool> running_{true};
    std::thread flush_thread_;
    std::wstring logPath_;
    int writeCount_ = 0;

    void backgroundFlush();
    std::string getCurrentTime() const;
    std::string levelToString(LogLevel level) const;
    void rotateIfNeeded(const std::wstring& logPath) const;
    void reopenFile();
    void applyDirDacl(const std::wstring& dirPath) const;
    void applyFileDacl(const std::wstring& filePath) const;
};

#define LS_LOG_INFO(mod, msg) Logger::instance().info(mod, msg)
#define LS_LOG_WARN(mod, msg) Logger::instance().warning(mod, msg)
#define LS_LOG_ERROR(mod, msg) Logger::instance().error(mod, msg)
