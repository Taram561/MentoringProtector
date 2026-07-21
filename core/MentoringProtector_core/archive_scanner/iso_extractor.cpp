#include "pch.h"
#include <initguid.h>
#include "iso_extractor.h"
#include "../unicode_utils.h"
#include <virtdisk.h>
#include <filesystem>
#include <algorithm>

#pragma comment(lib, "virtdisk.lib")

namespace fs = std::filesystem;
using namespace std;

struct VirtualDiskGuard {
    HANDLE handle = INVALID_HANDLE_VALUE;
    bool attached = false;

    ~VirtualDiskGuard() {
        if (attached) DetachVirtualDisk(handle, DETACH_VIRTUAL_DISK_FLAG_NONE, 0);
        if (handle != INVALID_HANDLE_VALUE) CloseHandle(handle);
    }
};

bool IsoExtractor::hasExtension(const wstring& path, const wstring& ext) const {
    if (path.size() < ext.size()) return false;
    wstring tail = path.substr(path.size() - ext.size());
    transform(tail.begin(), tail.end(), tail.begin(), ::towlower);
    return tail == ext;
}

bool IsoExtractor::canHandle(const wstring& path) const {
    return hasExtension(path, L".iso") || hasExtension(path, L".img");
}

void IsoExtractor::copyDirRecursive(const wstring& srcDir, const wstring& dstDir, ExtractionResult& result, const ArchiveLimits& limits, int& fileCount, uint64_t& totalBytes) const {
    WIN32_FIND_DATAW fd = {};
    wstring pattern = srcDir + L"\\*";
    HANDLE hFind = FindFirstFileW(pattern.c_str(), &fd);
    if (hFind == INVALID_HANDLE_VALUE) return;

    do {
        if (wcscmp(fd.cFileName, L".") == 0 || wcscmp(fd.cFileName, L"..") == 0) continue;

        wstring srcPath = srcDir + L"\\" + fd.cFileName;
        wstring dstPath = dstDir + L"\\" + fd.cFileName;

        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            try { fs::create_directories(dstPath); } catch (...) {}
            copyDirRecursive(srcPath, dstPath, result, limits, fileCount, totalBytes);
        } else {
            if (fileCount >= limits.max_files) break;
            LARGE_INTEGER sz = {};
            sz.LowPart = fd.nFileSizeLow;
            sz.HighPart = static_cast<LONG>(fd.nFileSizeHigh);
            uint64_t fileSize = static_cast<uint64_t>(sz.QuadPart);
            if (totalBytes + fileSize > limits.max_size_bytes) break;

            try { fs::create_directories(fs::path(dstPath).parent_path()); } catch (...) {}
            if (CopyFileW(srcPath.c_str(), dstPath.c_str(), FALSE)) {
                ExtractedFile ef;
                ef.local_path = dstPath;
                ef.original_size = fileSize;
                ef.inner_path = srcPath;
                result.files.push_back(ef);
                ++fileCount;
                totalBytes += fileSize;
            }
        }
    } while (FindNextFileW(hFind, &fd));

    FindClose(hFind);
}

ExtractionResult IsoExtractor::extract(const wstring& path, const wstring& dest_dir, const ArchiveLimits& limits) {
    ExtractionResult res;

    VIRTUAL_STORAGE_TYPE storageType = {};
    storageType.DeviceId = VIRTUAL_STORAGE_TYPE_DEVICE_ISO;
    storageType.VendorId = VIRTUAL_STORAGE_TYPE_VENDOR_MICROSOFT;

    OPEN_VIRTUAL_DISK_PARAMETERS openParams = {};
    openParams.Version = OPEN_VIRTUAL_DISK_VERSION_1;
    openParams.Version1.RWDepth = OPEN_VIRTUAL_DISK_RW_DEPTH_DEFAULT;

    VirtualDiskGuard vd;
    DWORD rc = OpenVirtualDisk(&storageType, path.c_str(), VIRTUAL_DISK_ACCESS_READ, OPEN_VIRTUAL_DISK_FLAG_NONE, &openParams, &vd.handle);

    if (rc == ERROR_PRIVILEGE_NOT_HELD || rc == ERROR_ACCESS_DENIED) { res.error = "requires_elevation"; return res; }
    if (rc != ERROR_SUCCESS) { res.error = "read_error"; return res; }

    ATTACH_VIRTUAL_DISK_PARAMETERS attachParams = {};
    attachParams.Version = ATTACH_VIRTUAL_DISK_VERSION_1;

    rc = AttachVirtualDisk(vd.handle, nullptr, ATTACH_VIRTUAL_DISK_FLAG_READ_ONLY | ATTACH_VIRTUAL_DISK_FLAG_NO_DRIVE_LETTER, 0, &attachParams, nullptr);

    if (rc == ERROR_PRIVILEGE_NOT_HELD || rc == ERROR_ACCESS_DENIED) { res.error = "requires_elevation"; return res; }
    if (rc != ERROR_SUCCESS) { res.error = "read_error"; return res; }
    vd.attached = true;

    DWORD physPathSize = 512;
    wstring physPath(physPathSize, L'\0');
    rc = GetVirtualDiskPhysicalPath(vd.handle, &physPathSize, physPath.data());
    if (rc != ERROR_SUCCESS) { res.error = "read_error"; return res; }
    physPath.resize(physPathSize > 0 ? physPathSize - 1 : 0);

    wchar_t volName[MAX_PATH] = {};
    HANDLE hVol = FindFirstVolumeW(volName, MAX_PATH);
    wstring mountRoot;
    if (hVol != INVALID_HANDLE_VALUE) {
        do {
            wchar_t devName[MAX_PATH] = {};
            wstring dev = volName;
            if (!dev.empty() && dev.back() == L'\\') dev.pop_back();
            if (dev.rfind(L"\\\\?\\", 0) == 0) dev = dev.substr(4);
            QueryDosDeviceW(dev.c_str(), devName, MAX_PATH);

            wstring devStr(devName);
            if (!physPath.empty() && devStr.find(physPath) != wstring::npos) { mountRoot = volName; break; }
        } while (FindNextVolumeW(hVol, volName, MAX_PATH));
        FindVolumeClose(hVol);
    }

    if (mountRoot.empty()) {
        for (wchar_t c = L'D'; c <= L'Z'; ++c) {
            wstring candidate = wstring(1, c) + L":\\";
            UINT type = GetDriveTypeW(candidate.c_str());
            if (type == DRIVE_CDROM) { mountRoot = candidate; break; }
        }
    }

    if (mountRoot.empty()) { res.error = "mount_failed"; return res; }

    wstring srcRoot = mountRoot;
    while (!srcRoot.empty() && srcRoot.back() == L'\\') srcRoot.pop_back();

    int fileCount = 0;
    uint64_t totalBytes = 0;
    try { fs::create_directories(dest_dir); } catch (...) {}
    copyDirRecursive(srcRoot, dest_dir, res, limits, fileCount, totalBytes);

    res.ok = true;
    return res;
}
