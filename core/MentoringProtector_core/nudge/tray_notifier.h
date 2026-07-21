#pragma once
#include <Windows.h>
#include <shellapi.h>
#include <atomic>
#include <mutex>
#include <thread>
#include <string>
#include <memory>

constexpr UINT WM_TRAYICON = WM_APP + 100;
constexpr UINT WM_TRAY_SHOW_BALLOON = WM_APP + 101;
constexpr UINT WM_TRAY_STOP = WM_APP + 102;

class TrayNotifier {
public:
    TrayNotifier() = default;
    ~TrayNotifier();

    TrayNotifier(const TrayNotifier&) = delete;
    TrayNotifier& operator=(const TrayNotifier&) = delete;

    void start();
    void stop();
    void showBalloon(const std::string& title_utf8, const std::string& text_utf8);
    bool consumeClick();

private:
    struct BalloonData { std::wstring title; std::wstring text; };

    void   threadMain(HANDLE readyEvent);
    static LRESULT CALLBACK wndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp);

    std::atomic<HWND> hwnd_{ nullptr };
    std::thread thread_;
    std::atomic<bool> running_{ false };
    std::atomic<bool> clicked_{ false };
    std::mutex balloonMx_;
    std::unique_ptr<BalloonData> pendingBalloon_;
    HICON icon_ = nullptr;

    static constexpr UINT NID_UID = 1;
};