#include "pch.h"
#include "usb_monitor.h"
#include "nudge.h"
#include <chrono>

using namespace std;
using namespace chrono;

static constexpr UINT WM_USB_STOP = WM_APP + 102;

namespace {
    constexpr wchar_t WNDCLASS_NAME[] = L"MPUsbMonitorMsgWnd";
    HMODULE getDllModule() {
        HMODULE h = nullptr;
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, reinterpret_cast<LPCWSTR>(&UsbMonitor::wndProc), &h);
        return h;
    }

    string getCurrentTime() {
        SYSTEMTIME st;
        GetLocalTime(&st);
        char buf[32];
        sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
        return buf;
    }
}

UsbMonitor::~UsbMonitor() { stop(); }

void UsbMonitor::start(INudgeSink* sink) {
    if (running_.exchange(true)) return;
    sink_ = sink;

    HANDLE readyEvent = CreateEventW(nullptr, TRUE, FALSE, nullptr);
    thread_ = thread([this, readyEvent] { threadMain(readyEvent); });
    WaitForSingleObject(readyEvent, 3000);
    CloseHandle(readyEvent);
}

void UsbMonitor::stop() {
    if (!running_.exchange(false)) return;
    HWND h = hwnd_.load();
    if (h) PostMessageW(h, WM_USB_STOP, 0, 0);
    if (thread_.joinable()) thread_.join();
}



void UsbMonitor::threadMain(HANDLE readyEvent) {
    HMODULE hMod = getDllModule();

    WNDCLASSEXW wc = {};
    wc.cbSize = sizeof(wc);
    wc.lpfnWndProc = wndProc;
    wc.hInstance = hMod;
    wc.lpszClassName = WNDCLASS_NAME;
    RegisterClassExW(&wc);
    HWND hwnd = CreateWindowExW(WS_EX_NOACTIVATE, WNDCLASS_NAME, L"", WS_POPUP, -32000, -32000, 1, 1, nullptr, nullptr, hMod, nullptr);

    if (!hwnd) {
        char buf[128];
        sprintf_s(buf, "UsbMonitor: CreateWindowExW failed GLE=%lu", GetLastError());
        OutputDebugStringA(buf);
        SetEvent(readyEvent);
        return;
    }

    SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));

    hwnd_.store(hwnd);
    SetEvent(readyEvent);

    MSG msg;
    while (GetMessageW(&msg, nullptr, 0, 0) > 0) {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }
    UnregisterClassW(WNDCLASS_NAME, hMod);
}



LRESULT CALLBACK UsbMonitor::wndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    auto* self = reinterpret_cast<UsbMonitor*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));

    if (msg == WM_DEVICECHANGE && wp == DBT_DEVICEARRIVAL) {
        auto* hdr = reinterpret_cast<DEV_BROADCAST_HDR*>(lp);
        if (hdr && hdr->dbch_devicetype == DBT_DEVTYP_VOLUME && self && self->sink_) {
            auto* vol = reinterpret_cast<DEV_BROADCAST_VOLUME*>(lp);
            char letter = driveLetter(vol->dbcv_unitmask);
            if (letter == '\0') return 0;

            wchar_t root[4] = { static_cast<wchar_t>(letter), L':', L'\\', L'\0' };
            if (GetDriveTypeW(root) != DRIVE_REMOVABLE) return 0;

            auto now = steady_clock::now();
            {
                lock_guard<mutex> lk(self->dedupMx_);
                auto it = self->recentArrivals_.find(letter);
                if (it != self->recentArrivals_.end()) {
                    auto elapsed = duration_cast<seconds>(now - it->second).count();
                    if (elapsed < DEDUP_SEC) return 0;
                }
                self->recentArrivals_[letter] = now;
            }
            Nudge n;
            n.category = NudgeCategory::UsbDevice;
            n.detail = string("Drive ") + letter + ":";
            n.severity = "info";
            n.detected_at = getCurrentTime();
            self->sink_->emit(n);
        }
        return 0;
    }
    if (msg == WM_USB_STOP) {
        if (self) self->hwnd_.store(nullptr);
        DestroyWindow(hwnd);
        return 0;
    }
    if (msg == WM_DESTROY) {
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(hwnd, msg, wp, lp);
}

char UsbMonitor::driveLetter(DWORD unitMask) {
    if (unitMask == 0) return '\0';
    int bit = 0;
    while (bit < 26 && !(unitMask & (1u << bit))) ++bit;
    return (bit < 26) ? static_cast<char>('A' + bit) : '\0';
}