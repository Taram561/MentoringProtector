#include "pch.h"
#include "tray_notifier.h"
#include "../unicode_utils.h"
#include <shellapi.h>

#pragma comment(lib, "Shell32.lib")

namespace { constexpr wchar_t WNDCLASS_NAME[] = L"MPTrayNotifierMsgWnd"; }

TrayNotifier::~TrayNotifier() { stop(); }

void TrayNotifier::start() {
    if (running_.exchange(true)) return;

    HANDLE readyEvent = CreateEventW(nullptr, TRUE, FALSE, nullptr);
    thread_ = std::thread([this, readyEvent] { threadMain(readyEvent); });
    WaitForSingleObject(readyEvent, 5000);
    CloseHandle(readyEvent);
}

void TrayNotifier::stop() {
    if (!running_.exchange(false)) return;
    HWND h = hwnd_.load();
    if (h) PostMessageW(h, WM_TRAY_STOP, 0, 0);
    if (thread_.joinable()) thread_.join();
}

void TrayNotifier::showBalloon(const std::string& title_utf8, const std::string& text_utf8) {
    HWND h = hwnd_.load();
    if (!h) return;

    auto data = std::make_unique<BalloonData>();
    data->title = unicode_utils::utf8_to_wide(title_utf8);
    data->text = unicode_utils::utf8_to_wide(text_utf8);

    {
        std::lock_guard<std::mutex> lk(balloonMx_);
        pendingBalloon_ = std::move(data);
    }
    PostMessageW(h, WM_TRAY_SHOW_BALLOON, 0, 0);
}

bool TrayNotifier::consumeClick() { return clicked_.exchange(false); }

void TrayNotifier::threadMain(HANDLE readyEvent) {
    WNDCLASSEXW wc = {};
    wc.cbSize = sizeof(wc);
    wc.lpfnWndProc = wndProc;
    wc.hInstance = GetModuleHandleW(nullptr);
    wc.lpszClassName = WNDCLASS_NAME;
    RegisterClassExW(&wc);
    HWND hwnd = CreateWindowExW(0, WNDCLASS_NAME, L"MP Tray Worker", 0, 0, 0, 0, 0, HWND_MESSAGE, nullptr, GetModuleHandleW(nullptr), nullptr);

    if (!hwnd) {
        SetEvent(readyEvent);
        return;
    }

    SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));

    icon_ = LoadIconW(GetModuleHandleW(nullptr), MAKEINTRESOURCEW(101));
    if (!icon_) icon_ = LoadIconW(nullptr, IDI_SHIELD);
    if (!icon_) icon_ = LoadIconW(nullptr, IDI_APPLICATION);

    NOTIFYICONDATAW nid = {};
    nid.cbSize = sizeof(nid);
    nid.hWnd = hwnd;
    nid.uID = NID_UID;
    nid.uFlags = NIF_ICON | NIF_TIP | NIF_MESSAGE | NIF_SHOWTIP;
    nid.uCallbackMessage = WM_TRAYICON;
    nid.hIcon = icon_;
    nid.uVersion = NOTIFYICON_VERSION_4;
    wcscpy_s(nid.szTip, L"Mentoring Protector");
    Shell_NotifyIconW(NIM_ADD, &nid);
    Shell_NotifyIconW(NIM_SETVERSION, &nid);

    hwnd_.store(hwnd);
    SetEvent(readyEvent);

    MSG msg;
    while (GetMessageW(&msg, nullptr, 0, 0) > 0) {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }
}

LRESULT CALLBACK TrayNotifier::wndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    auto* self = reinterpret_cast<TrayNotifier*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));

    switch (msg) {
    case WM_TRAYICON: {
        UINT event = LOWORD(lp);
        if (self && (event == NIN_BALLOONUSERCLICK || event == WM_LBUTTONUP)) self->clicked_.store(true);
        return 0;
    }

    case WM_TRAY_SHOW_BALLOON: {
        if (!self) return 0;
        std::unique_ptr<BalloonData> data;
        {
            std::lock_guard<std::mutex> lk(self->balloonMx_);
            data = std::move(self->pendingBalloon_);
        }
        if (!data) return 0;

        NOTIFYICONDATAW nid = {};
        nid.cbSize = sizeof(nid);
        nid.hWnd = hwnd;
        nid.uID = NID_UID;
        nid.uFlags = NIF_INFO;
        nid.dwInfoFlags = NIIF_INFO | NIIF_NOSOUND;
        wcsncpy_s(nid.szInfoTitle, data->title.c_str(), _TRUNCATE);
        wcsncpy_s(nid.szInfo, data->text.c_str(), _TRUNCATE);
        Shell_NotifyIconW(NIM_MODIFY, &nid);
        return 0;
    }

    case WM_TRAY_STOP: {
        NOTIFYICONDATAW nid = {};
        nid.cbSize = sizeof(nid);
        nid.hWnd = hwnd;
        nid.uID = NID_UID;
        Shell_NotifyIconW(NIM_DELETE, &nid);

        if (self) self->hwnd_.store(nullptr);
        DestroyWindow(hwnd);
        return 0;
    }
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(hwnd, msg, wp, lp);
}