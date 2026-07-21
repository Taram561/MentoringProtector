#pragma once

#define _WIN32_WINNT 0x0602
#define WINVER 0x0602
#define NOMINMAX

#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#include <wincrypt.h>
#include <shlwapi.h>
#include <softpub.h>
#include <wintrust.h>
#include <mscat.h>
#include <lm.h>
#include <winsvc.h>
#include <objbase.h>
#include <evntrace.h>
#include <evntcons.h>
#include <tdh.h>

#pragma comment(lib, "Crypt32.lib")
#pragma comment(lib, "Advapi32.lib")
#pragma comment(lib, "Tdh.lib")
#pragma comment(lib, "Psapi.lib")
#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "Wintrust.lib")
#pragma comment(lib, "Netapi32.lib")
#pragma comment(lib, "Ole32.lib")

#include <string>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <fstream>
#include <sstream>
#include <iostream>
#include <algorithm>
#include <memory>
#include <functional>
#include <stdexcept>
#include <iomanip>
#include <cassert>
#include <numeric>
#include <thread>
#include <mutex>
#include <shared_mutex>
#include <atomic>
#include <condition_variable>
#include <chrono>
#include <future>