#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.2.11"
$ZLIB_HASH = "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff"

$OPENSSL_VERSION = "1.1.1k"
$OPENSSL_HASH = "892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5"

$BROTLI_VERSION = "1.0.9"
$BROTLI_HASH = "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46"

$LIBSSH2_VERSION = "1.9.0"
$LIBSSH2_HASH = "d5fb8bd563305fd1074dda90bd053fb2d29fc4bce048d182f96eaa466dfadafd"

$NGHTTP2_VERSION = "1.43.0"
$NGHTTP2_HASH = "f4a9be08d22f5ad9b4bf36c491f1be58e54dc35a1592eaf4e3f79567e4894d0c"

$ZSTD_VERSION = "1.5.0"
$ZSTD_HASH = "5194fbfa781fcf45b98c5e849651aa7b3b0a008c6b72d4a0db760f3002291e94"

# We use tar.gz because Windows tar not support tar.xz
$CURL_VERSION = "7.77.0"
$CURL_HASH = "b0a3428acb60fa59044c4d0baae4e4fc09ae9af1d8a3aa84b2e3fbcd99841f77"

# Filename
$ZLIB_FILENAME = "zlib-${ZLIB_VERSION}"
$ZLIB_URL = "https://github.com/madler/zlib/archive/v${ZLIB_VERSION}.tar.gz"
#$ZLIB_URL = "https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz"

$OPENSSL_URL = "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
$OPENSSL_FILE = "openssl-${OPENSSL_VERSION}"

$BROTLI_URL = "https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz"
$BROTLI_FILE = "brotli-${BROTLI_VERSION}"

$NGHTTP2_URL = "https://github.com/nghttp2/nghttp2/archive/v${NGHTTP2_VERSION}.tar.gz"
$NGHTTP2_FILE = "nghttp2-${NGHTTP2_VERSION}"

$LIBSSH2_URL = "https://www.libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.gz"
$LIBSSH2_FILE = "libssh2-${LIBSSH2_VERSION}"

$ZSTD_URL = "https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz"
$ZSTD_FILE = "zstd-${ZSTD_VERSION}"

$CURL_URL = "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz"
$CURL_FILE = "curl-${CURL_VERSION}"

#curl-ca-bundle
$CA_BUNDLE_URL = "https://curl.se/ca/cacert-2021-05-25.pem"

Function DumpLocal {
    $dumptext = $ZLIB_VERSION + $ZLIB_HASH + $ZLIB_FILENAME + $ZLIB_URL 
    + $OPENSSL_HASH + $OPENSSL_URL + $OPENSSL_FILE
    + $BROTLI_HASH + $BROTLI_URL + $BROTLI_FILE 
    + $NGHTTP2_HASH + $NGHTTP2_URL + $NGHTTP2_FILE 
    + $LIBSSH2_HASH + $LIBSSH2_URL + $LIBSSH2_FILE
    + $CURL_HASH + $CURL_FILE + $CURL_URL + $CA_BUNDLE_URL + $ZSTD_URL + $ZSTD_FILE + $ZSTD_HASH
    Write-Host $dumptext
}

Write-Host -ForegroundColor Cyan "zlib: $ZLIB_VERSION $ZLIB_HASH
openssl: $OPENSSL_VERSION $OPENSSL_HASH
brotli: $BROTLI_VERSION
libssh2: $LIBSSH2_VERSION
nghttp2: $NGHTTP2_VERSION
zstd: $ZSTD_VERSION
curl: $CURL_VERSION"
