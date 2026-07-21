#include "pch.h"
#include "seven_zip_extractor.h"
#include "../unicode_utils.h"
#include <filesystem>
#include <algorithm>
#include <objbase.h>
#include <oleauto.h>

namespace fs = std::filesystem;
using namespace std;

static const GUID IID_IInArchive = { 0x23170F69, 0x40C1, 0x278A, { 0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00 } };
static const GUID IID_IArchiveExtractCallback = { 0x23170F69, 0x40C1, 0x278A, { 0x00, 0x00, 0x00, 0x06, 0x00, 0x20, 0x00, 0x00 } };
static const GUID IID_ISequentialOutStream = { 0x23170F69, 0x40C1, 0x278A, { 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00 } };
static const GUID CLSID_CFormat7z = { 0x23170F69, 0x40C1, 0x278A, { 0x10, 0x00, 0x00, 0x01, 0x10, 0x07, 0x00, 0x00 } };
static const GUID CLSID_CFormatRar = { 0x23170F69, 0x40C1, 0x278A, { 0x10, 0x00, 0x00, 0x01, 0x10, 0x03, 0x00, 0x00 } };

struct IInArchive : IUnknown {
    virtual HRESULT STDMETHODCALLTYPE Open(IUnknown* stream, const UINT64* maxCheckStartPosition, IUnknown* openCallback) = 0;
    virtual HRESULT STDMETHODCALLTYPE Close() = 0;
    virtual HRESULT STDMETHODCALLTYPE GetNumberOfItems(UINT32* numItems) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetProperty(UINT32 index, PROPID propID, PROPVARIANT* value) = 0;
    virtual HRESULT STDMETHODCALLTYPE Extract(const UINT32* indices, UINT32 numItems, INT32 testMode, IUnknown* extractCallback) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetArchiveProperty(PROPID propID, PROPVARIANT* value) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetNumberOfProperties(UINT32* numProperties) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetPropertyInfo(UINT32 index, BSTR* name, PROPID* propID, VARTYPE* varType) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetNumberOfArchiveProperties(UINT32* numProperties) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetArchivePropertyInfo(UINT32 index, BSTR* name, PROPID* propID, VARTYPE* varType) = 0;
};

struct ISequentialOutStream : IUnknown { virtual HRESULT STDMETHODCALLTYPE Write(const void* data, UINT32 size, UINT32* processedSize) = 0; };

static const PROPID kpidPath = 3, kpidIsDir = 6, kpidSize = 12, kpidPackSize = 13, kpidEncrypted = 16;

struct IArchiveExtractCallback : IUnknown {
    virtual HRESULT STDMETHODCALLTYPE SetTotal(UINT64 total) = 0;
    virtual HRESULT STDMETHODCALLTYPE SetCompleted(const UINT64* completeValue) = 0;
    virtual HRESULT STDMETHODCALLTYPE GetStream(UINT32 index, ISequentialOutStream** outStream, INT32 askExtractMode) = 0;
    virtual HRESULT STDMETHODCALLTYPE PrepareOperation(INT32 askExtractMode) = 0;
    virtual HRESULT STDMETHODCALLTYPE SetOperationResult(INT32 resultEOperationResult) = 0;
};

static const GUID IID_IInStream = { 0x23170F69, 0x40C1, 0x278A, { 0x00, 0x00, 0x00, 0x03, 0x00, 0x03, 0x00, 0x00 } };
struct IInStream : IUnknown {
    virtual HRESULT STDMETHODCALLTYPE Read(void* data, UINT32 size, UINT32* processedSize) = 0;
    virtual HRESULT STDMETHODCALLTYPE Seek(INT64 offset, UINT32 seekOrigin, UINT64* newPosition) = 0;
};

class FileInStream : public IInStream {
    ULONG refCount_ = 1;
    FILE* f_;
public:
    explicit FileInStream(FILE* f) : f_(f) {}
    ~FileInStream() { if (f_) { fclose(f_); f_ = nullptr; } }

    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** ppv) override {
        if (iid == IID_IUnknown || iid == IID_IInStream) { *ppv = this; AddRef(); return S_OK; }
        *ppv = nullptr; return E_NOINTERFACE;
    }
    ULONG STDMETHODCALLTYPE AddRef() override { return ++refCount_; }
    ULONG STDMETHODCALLTYPE Release() override { ULONG r = --refCount_; if (!r) delete this; return r; }

    HRESULT STDMETHODCALLTYPE Read(void* data, UINT32 size, UINT32* processed) override {
        *processed = static_cast<UINT32>(fread(data, 1, size, f_));
        return S_OK;
    }
    HRESULT STDMETHODCALLTYPE Seek(INT64 offset, UINT32 origin, UINT64* newPos) override {
        int whence = (origin == 0) ? SEEK_SET : (origin == 1 ? SEEK_CUR : SEEK_END);
        _fseeki64(f_, offset, whence);
        if (newPos) *newPos = static_cast<UINT64>(_ftelli64(f_));
        return S_OK;
    }
};

class FileOutStream : public ISequentialOutStream {
    ULONG refCount_ = 1;
    FILE* f_;
public:
    explicit FileOutStream(FILE* f) : f_(f) {}
    ~FileOutStream() { if (f_) { fclose(f_); f_ = nullptr; } }

    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** ppv) override {
        if (iid == IID_IUnknown || iid == IID_ISequentialOutStream) { *ppv = this; AddRef(); return S_OK; }
        *ppv = nullptr; return E_NOINTERFACE;
    }
    ULONG STDMETHODCALLTYPE AddRef() override { return ++refCount_; }
    ULONG STDMETHODCALLTYPE Release() override { ULONG r = --refCount_; if (!r) delete this; return r; }

    HRESULT STDMETHODCALLTYPE Write(const void* data, UINT32 size, UINT32* processed) override {
        *processed = static_cast<UINT32>(fwrite(data, 1, size, f_));
        return S_OK;
    }
};

class ExtractCallback : public IArchiveExtractCallback {
    ULONG refCount_ = 1;
    IInArchive* archive_;
    const wstring& destDir_;
    ExtractionResult& result_;
    const ArchiveLimits& limits_;
    wstring currentPath_;

public:
    ExtractCallback(IInArchive* arc, const wstring& destDir, ExtractionResult& res, const ArchiveLimits& lim) : archive_(arc), destDir_(destDir), result_(res), limits_(lim) {}

    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** ppv) override {
        if (iid == IID_IUnknown || iid == IID_IArchiveExtractCallback) *ppv = this; AddRef(); return S_OK;
        *ppv = nullptr; return E_NOINTERFACE;
    }
    ULONG STDMETHODCALLTYPE AddRef() override { return ++refCount_; }
    ULONG STDMETHODCALLTYPE Release() override { ULONG r = --refCount_; if (!r) delete this; return r; }

    HRESULT STDMETHODCALLTYPE SetTotal(UINT64) override { return S_OK; }
    HRESULT STDMETHODCALLTYPE SetCompleted(const UINT64*) override { return S_OK; }
    HRESULT STDMETHODCALLTYPE PrepareOperation(INT32) override { return S_OK; }
    HRESULT STDMETHODCALLTYPE SetOperationResult(INT32) override { return S_OK; }

    HRESULT STDMETHODCALLTYPE GetStream(UINT32 index, ISequentialOutStream** outStream, INT32 askExtractMode) override {
        *outStream = nullptr;
        if (askExtractMode != 0) return S_OK;

        PROPVARIANT pv = {};
        if (FAILED(archive_->GetProperty(index, kpidPath, &pv))) return S_OK;

        wstring relPath;
        if (pv.vt == VT_BSTR && pv.bstrVal) relPath = pv.bstrVal;
        PropVariantClear(&pv);

        PROPVARIANT isDir = {};
        archive_->GetProperty(index, kpidIsDir, &isDir);
        bool bIsDir = (isDir.vt == VT_BOOL && isDir.boolVal != 0);
        PropVariantClear(&isDir);
        if (bIsDir) return S_OK;

        for (auto& ch : relPath) { if (ch == L'/') ch = L'\\'; }
        while (!relPath.empty() && (relPath[0] == L'\\' || relPath[0] == L'/')) relPath = relPath.substr(1);
        if (relPath.size() >= 2 && relPath[1] == L':') relPath = relPath.substr(2);
        if (relPath.empty()) return S_OK;

        currentPath_ = destDir_ + relPath;

        try { fs::create_directories(fs::path(currentPath_).parent_path()); }
        catch (...) { return S_OK; }

        FILE* f = nullptr;
        _wfopen_s(&f, currentPath_.c_str(), L"wb");
        if (!f) return S_OK;

        FileOutStream* stream = new FileOutStream(f);
        *outStream = stream;

        ExtractedFile ef;
        ef.inner_path = relPath;
        ef.local_path = currentPath_;
        result_.files.push_back(ef);
        return S_OK;
    }
};

SevenZipExtractor::SevenZipExtractor(const wstring& dll_dir) {
    wstring dllPath = dll_dir + L"7z.dll";
    dll_ = LoadLibraryW(dllPath.c_str());
    if (!dll_) return;
    createObject_ = reinterpret_cast<CreateObjectFunc>(GetProcAddress(dll_, "CreateObject"));
    if (!createObject_) { FreeLibrary(dll_); dll_ = nullptr; }
}

SevenZipExtractor::~SevenZipExtractor() { if (dll_) FreeLibrary(dll_); dll_ = nullptr; }

bool SevenZipExtractor::hasExtension(const wstring& path, const wstring& ext) const {
    if (path.size() < ext.size()) return false;
    wstring tail = path.substr(path.size() - ext.size());
    transform(tail.begin(), tail.end(), tail.begin(), ::towlower);
    return tail == ext;
}

bool SevenZipExtractor::canHandle(const wstring& path) const {
    if (!dll_) return false;
    return hasExtension(path, L".7z") || hasExtension(path, L".rar") || hasExtension(path, L".tar") || hasExtension(path, L".gz") || hasExtension(path, L".bz2");
}

ExtractionResult SevenZipExtractor::extract(const wstring& path, const wstring& dest_dir, const ArchiveLimits& limits) {
    ExtractionResult res;
    if (!dll_ || !createObject_) { res.error = "dll_unavailable"; return res; }

    const GUID* clsid = &CLSID_CFormat7z;
    if (hasExtension(path, L".rar")) clsid = &CLSID_CFormatRar;

    IInArchive* archive = nullptr;
    if (FAILED(createObject_(clsid, &IID_IInArchive, reinterpret_cast<void**>(&archive))) || !archive) {
        res.error = "format_unavailable";
        return res;
    }

    FILE* f = nullptr;
    _wfopen_s(&f, path.c_str(), L"rb");
    if (!f) { archive->Release(); res.error = "read_error"; return res; }

    FileInStream* inStream = new FileInStream(f);

    if (FAILED(archive->Open(inStream, nullptr, nullptr))) {
        inStream->Release();
        archive->Release();
        res.error = "read_error";
        return res;
    }

    UINT32 numItems = 0;
    archive->GetNumberOfItems(&numItems);

    if (static_cast<int>(numItems) > limits.max_files) {
        archive->Close();
        inStream->Release();
        archive->Release();
        res.error = "zip_bomb_count";
        return res;
    }

    ExtractCallback* cb = new ExtractCallback(archive, dest_dir, res, limits);
    archive->Extract(nullptr, static_cast<UINT32>(-1), 0, cb);
    cb->Release();

    archive->Close();
    inStream->Release();
    archive->Release();

    res.ok = true;
    return res;
}
