#pragma once

#include "miniz_export.h"

#if defined(__STRICT_ANSI__)
#define MZ_FORCEINLINE
#elif defined(_MSC_VER)
#define MZ_FORCEINLINE __forceinline
#elif defined(__GNUC__)
#define MZ_FORCEINLINE __inline__ __attribute__((__always_inline__))
#else
#define MZ_FORCEINLINE inline
#endif

#ifdef MINIZ_NO_INFLATE_APIS
#define MINIZ_NO_ARCHIVE_APIS
#endif

#ifdef MINIZ_NO_DEFLATE_APIS
#define MINIZ_NO_ARCHIVE_WRITING_APIS
#endif

#if defined(__TINYC__) && (defined(__linux) || defined(__linux__))
#define MINIZ_NO_TIME
#endif

#include <stddef.h>

#if !defined(MINIZ_NO_TIME) && !defined(MINIZ_NO_ARCHIVE_APIS)
#include <time.h>
#endif

#if defined(_M_IX86) || defined(_M_X64) || defined(__i386__) || defined(__i386) || defined(__i486__) || defined(__i486) || defined(i386) || defined(__ia64__) || defined(__x86_64__)
#define MINIZ_X86_OR_X64_CPU 1
#else
#define MINIZ_X86_OR_X64_CPU 0
#endif

#if !defined(MINIZ_LITTLE_ENDIAN)
#if defined(__BYTE_ORDER__) && defined(__ORDER_LITTLE_ENDIAN__)

#if (__BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__)
#define MINIZ_LITTLE_ENDIAN 1
#else
#define MINIZ_LITTLE_ENDIAN 0
#endif

#else

#if MINIZ_X86_OR_X64_CPU
#define MINIZ_LITTLE_ENDIAN 1
#else
#define MINIZ_LITTLE_ENDIAN 0
#endif

#endif
#endif

#if defined(__has_feature)
#if __has_feature(undefined_behavior_sanitizer)
#define MINIZ_USE_UNALIGNED_LOADS_AND_STORES 0
#endif
#endif

#if !defined(MINIZ_USE_UNALIGNED_LOADS_AND_STORES)
#if MINIZ_X86_OR_X64_CPU
#define MINIZ_USE_UNALIGNED_LOADS_AND_STORES 0
#define MINIZ_UNALIGNED_USE_MEMCPY
#else
#define MINIZ_USE_UNALIGNED_LOADS_AND_STORES 0
#endif
#endif

#if defined(_M_X64) || defined(_WIN64) || defined(__MINGW64__) || defined(_LP64) || defined(__LP64__) || defined(__ia64__) || defined(__x86_64__)
#define MINIZ_HAS_64BIT_REGISTERS 1
#else
#define MINIZ_HAS_64BIT_REGISTERS 0
#endif

#ifdef __cplusplus
extern "C"
{
#endif

    typedef unsigned long mz_ulong;

    MINIZ_EXPORT void mz_free(void *p);

#define MZ_ADLER32_INIT (1)
    MINIZ_EXPORT mz_ulong mz_adler32(mz_ulong adler, const unsigned char *ptr, size_t buf_len);

#define MZ_CRC32_INIT (0)
    MINIZ_EXPORT mz_ulong mz_crc32(mz_ulong crc, const unsigned char *ptr, size_t buf_len);

    enum {
        MZ_DEFAULT_STRATEGY = 0,
        MZ_FILTERED = 1,
        MZ_HUFFMAN_ONLY = 2,
        MZ_RLE = 3,
        MZ_FIXED = 4
    };

#define MZ_DEFLATED 8

    typedef void *(*mz_alloc_func)(void *opaque, size_t items, size_t size);
    typedef void (*mz_free_func)(void *opaque, void *address);
    typedef void *(*mz_realloc_func)(void *opaque, void *address, size_t items, size_t size);

    enum {
        MZ_NO_COMPRESSION = 0,
        MZ_BEST_SPEED = 1,
        MZ_BEST_COMPRESSION = 9,
        MZ_UBER_COMPRESSION = 10,
        MZ_DEFAULT_LEVEL = 6,
        MZ_DEFAULT_COMPRESSION = -1
    };

#define MZ_VERSION "11.3.1"
#define MZ_VERNUM 0xB301
#define MZ_VER_MAJOR 11
#define MZ_VER_MINOR 3
#define MZ_VER_REVISION 1
#define MZ_VER_SUBREVISION 0

#ifndef MINIZ_NO_ZLIB_APIS

    enum {
        MZ_NO_FLUSH = 0,
        MZ_PARTIAL_FLUSH = 1,
        MZ_SYNC_FLUSH = 2,
        MZ_FULL_FLUSH = 3,
        MZ_FINISH = 4,
        MZ_BLOCK = 5
    };

    enum {
        MZ_OK = 0,
        MZ_STREAM_END = 1,
        MZ_NEED_DICT = 2,
        MZ_ERRNO = -1,
        MZ_STREAM_ERROR = -2,
        MZ_DATA_ERROR = -3,
        MZ_MEM_ERROR = -4,
        MZ_BUF_ERROR = -5,
        MZ_VERSION_ERROR = -6,
        MZ_PARAM_ERROR = -10000
    };

#define MZ_DEFAULT_WINDOW_BITS 15

    struct mz_internal_state;

    typedef struct mz_stream_s {
        const unsigned char *next_in;
        unsigned int avail_in;
        mz_ulong total_in;

        unsigned char *next_out;
        unsigned int avail_out;
        mz_ulong total_out;

        char *msg;
        struct mz_internal_state *state;

        mz_alloc_func zalloc;
        mz_free_func zfree;
        void *opaque;

        int data_type;
        mz_ulong adler;
        mz_ulong reserved;
    } mz_stream;

    typedef mz_stream *mz_streamp;

    MINIZ_EXPORT const char *mz_version(void);

#ifndef MINIZ_NO_DEFLATE_APIS

    MINIZ_EXPORT int mz_deflateInit(mz_streamp pStream, int level);
    MINIZ_EXPORT int mz_deflateInit2(mz_streamp pStream, int level, int method, int window_bits, int mem_level, int strategy);
    MINIZ_EXPORT int mz_deflateReset(mz_streamp pStream);
    MINIZ_EXPORT int mz_deflate(mz_streamp pStream, int flush);
    MINIZ_EXPORT int mz_deflateEnd(mz_streamp pStream);
    MINIZ_EXPORT mz_ulong mz_deflateBound(mz_streamp pStream, mz_ulong source_len);
    MINIZ_EXPORT int mz_compress(unsigned char *pDest, mz_ulong *pDest_len, const unsigned char *pSource, mz_ulong source_len);
    MINIZ_EXPORT int mz_compress2(unsigned char *pDest, mz_ulong *pDest_len, const unsigned char *pSource, mz_ulong source_len, int level);
    MINIZ_EXPORT mz_ulong mz_compressBound(mz_ulong source_len);

#endif

#ifndef MINIZ_NO_INFLATE_APIS

    MINIZ_EXPORT int mz_inflateInit(mz_streamp pStream);
    MINIZ_EXPORT int mz_inflateInit2(mz_streamp pStream, int window_bits);
    MINIZ_EXPORT int mz_inflateReset(mz_streamp pStream);

    MINIZ_EXPORT int mz_inflate(mz_streamp pStream, int flush);

    MINIZ_EXPORT int mz_inflateEnd(mz_streamp pStream);

    MINIZ_EXPORT int mz_uncompress(unsigned char *pDest, mz_ulong *pDest_len, const unsigned char *pSource, mz_ulong source_len);
    MINIZ_EXPORT int mz_uncompress2(unsigned char *pDest, mz_ulong *pDest_len, const unsigned char *pSource, mz_ulong *pSource_len);
#endif

    MINIZ_EXPORT const char *mz_error(int err);

#ifndef MINIZ_NO_ZLIB_COMPATIBLE_NAMES
    typedef unsigned char Byte;
    typedef unsigned int uInt;
    typedef mz_ulong uLong;
    typedef Byte Bytef;
    typedef uInt uIntf;
    typedef char charf;
    typedef int intf;
    typedef void *voidpf;
    typedef uLong uLongf;
    typedef void *voidp;
    typedef void *const voidpc;
#define Z_NULL 0
#define Z_NO_FLUSH MZ_NO_FLUSH
#define Z_PARTIAL_FLUSH MZ_PARTIAL_FLUSH
#define Z_SYNC_FLUSH MZ_SYNC_FLUSH
#define Z_FULL_FLUSH MZ_FULL_FLUSH
#define Z_FINISH MZ_FINISH
#define Z_BLOCK MZ_BLOCK
#define Z_OK MZ_OK
#define Z_STREAM_END MZ_STREAM_END
#define Z_NEED_DICT MZ_NEED_DICT
#define Z_ERRNO MZ_ERRNO
#define Z_STREAM_ERROR MZ_STREAM_ERROR
#define Z_DATA_ERROR MZ_DATA_ERROR
#define Z_MEM_ERROR MZ_MEM_ERROR
#define Z_BUF_ERROR MZ_BUF_ERROR
#define Z_VERSION_ERROR MZ_VERSION_ERROR
#define Z_PARAM_ERROR MZ_PARAM_ERROR
#define Z_NO_COMPRESSION MZ_NO_COMPRESSION
#define Z_BEST_SPEED MZ_BEST_SPEED
#define Z_BEST_COMPRESSION MZ_BEST_COMPRESSION
#define Z_DEFAULT_COMPRESSION MZ_DEFAULT_COMPRESSION
#define Z_DEFAULT_STRATEGY MZ_DEFAULT_STRATEGY
#define Z_FILTERED MZ_FILTERED
#define Z_HUFFMAN_ONLY MZ_HUFFMAN_ONLY
#define Z_RLE MZ_RLE
#define Z_FIXED MZ_FIXED
#define Z_DEFLATED MZ_DEFLATED
#define Z_DEFAULT_WINDOW_BITS MZ_DEFAULT_WINDOW_BITS
    typedef void *(*alloc_func)(void *opaque, size_t items, size_t size);
    typedef void (*free_func)(void *opaque, void *address);

#define internal_state mz_internal_state
#define z_stream mz_stream

#ifndef MINIZ_NO_DEFLATE_APIS
    static MZ_FORCEINLINE int deflateInit(mz_streamp pStream, int level) { return mz_deflateInit(pStream, level); }
    static MZ_FORCEINLINE int deflateInit2(mz_streamp pStream, int level, int method, int window_bits, int mem_level, int strategy) { return mz_deflateInit2(pStream, level, method, window_bits, mem_level, strategy); }
    static MZ_FORCEINLINE int deflateReset(mz_streamp pStream) { return mz_deflateReset(pStream); }
    static MZ_FORCEINLINE int deflate(mz_streamp pStream, int flush) { return mz_deflate(pStream, flush); }
    static MZ_FORCEINLINE int deflateEnd(mz_streamp pStream) { return mz_deflateEnd(pStream); }
    static MZ_FORCEINLINE mz_ulong deflateBound(mz_streamp pStream, mz_ulong source_len) { return mz_deflateBound(pStream, source_len); }
    static MZ_FORCEINLINE int compress(unsigned char *pDest, mz_ulong *pDest_len, const unsigned char *pSource, mz_ulong source_len) { return mz_compress(pDest, pDest_len, pSource, source_len); }
    static MZ_FORCEINLINE int compress2(unsigned char *pDest, mz_ulong *pDest_len, const unsigned char *pSource, mz_ulong source_len, int level) { return mz_compress2(pDest, pDest_len, pSource, source_len, level); }
    static MZ_FORCEINLINE mz_ulong compressBound(mz_ulong source_len) { return mz_compressBound(source_len); }
#endif

#ifndef MINIZ_NO_INFLATE_APIS
    static MZ_FORCEINLINE int inflateInit(mz_streamp pStream) { return mz_inflateInit(pStream); }
    static MZ_FORCEINLINE int inflateInit2(mz_streamp pStream, int window_bits) { return mz_inflateInit2(pStream, window_bits); }

    static MZ_FORCEINLINE int inflateReset(mz_streamp pStream) { return mz_inflateReset(pStream); }

    static MZ_FORCEINLINE int inflate(mz_streamp pStream, int flush) { return mz_inflate(pStream, flush); }

    static MZ_FORCEINLINE int inflateEnd(mz_streamp pStream) { return mz_inflateEnd(pStream); }

    static MZ_FORCEINLINE int uncompress(unsigned char* pDest, mz_ulong* pDest_len, const unsigned char* pSource, mz_ulong source_len) { return mz_uncompress(pDest, pDest_len, pSource, source_len); }

    static MZ_FORCEINLINE int uncompress2(unsigned char* pDest, mz_ulong* pDest_len, const unsigned char* pSource, mz_ulong* pSource_len) { return mz_uncompress2(pDest, pDest_len, pSource, pSource_len); }
#endif

    static MZ_FORCEINLINE mz_ulong crc32(mz_ulong crc, const unsigned char *ptr, size_t buf_len) { return mz_crc32(crc, ptr, buf_len); }

    static MZ_FORCEINLINE mz_ulong adler32(mz_ulong adler, const unsigned char *ptr, size_t buf_len) { return mz_adler32(adler, ptr, buf_len); }
    
#define MAX_WBITS 15
#define MAX_MEM_LEVEL 9

    static MZ_FORCEINLINE const char* zError(int err) { return mz_error(err); }
#define ZLIB_VERSION MZ_VERSION
#define ZLIB_VERNUM MZ_VERNUM
#define ZLIB_VER_MAJOR MZ_VER_MAJOR
#define ZLIB_VER_MINOR MZ_VER_MINOR
#define ZLIB_VER_REVISION MZ_VER_REVISION
#define ZLIB_VER_SUBREVISION MZ_VER_SUBREVISION

#define zlibVersion mz_version
#define zlib_version mz_version()
#endif

#endif

#ifdef __cplusplus
}
#endif

#include "miniz_common.h"
#include "miniz_tdef.h"
#include "miniz_tinfl.h"
#include "miniz_zip.h"