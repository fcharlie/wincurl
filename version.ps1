#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.3.1"
$ZLIB_HASH = "38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"

$ZLIBNG_VERSION = "2.2.2"
$ZLIBNG_HASH = "fcb41dd59a3f17002aeb1bb21f04696c9b721404890bb945c5ab39d2cb69654c"

$OPENSSL_VERSION = "3.3.2"
$OPENSSL_HASH = "2e8a40b01979afe8be0bbfb3de5dc1c6709fedb46d6c89c10da114ab5fc3d281"

$BROTLI_VERSION = "1.1.0"
$BROTLI_HASH = "e720a6ca29428b803f4ad165371771f5398faba397edf6778837a18599ea13ff"

$LIBSSH2_VERSION = "1.11.0"
$LIBSSH2_HASH = "a488a22625296342ddae862de1d59633e6d446eff8417398e06674a49be3d7c2"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.63.0"
$NGHTTP2_HASH = "4879c75dd32a74421b9857924449460b8341796c0613ba114ab2188e4622354b"

$ZSTD_VERSION = "1.5.6"
$ZSTD_HASH = "8c29e06cf42aacc1eafc4077ae2ec6c6fcb96a626157e0593d5e82a34fd403c1"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.10.0"
$CURL_HASH = "e6b142f0e85e954759d37e26a3627e2278137595be80e3a860c4353e4335e5a0"

# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "1.5.0"
$NGHTTP3_HASH = "8c00e3910ea2ad1218dafebcf8dd2ffdf030c992d9ceb65834d29e5e5278dd0d"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "1.7.0"
$NGTCP2_HASH = "e07c79090f96f6738fabab2129657c53f0cc05164de3662592581ca5425617b1"

# openssl-${QUICTLS_VERSION}+quic.tar.gz
$QUICTLS_VERSION = "3.1.5"
$QUICTLS_HASH = "a9d261a0a85d141052534aac3f67872093e37c004255eb4288df52f3beaf6e6f"


# Filename
$ZLIB_FILENAME = "zlib-${ZLIB_VERSION}"
$ZLIB_URL = "https://zlib.net/zlib-${ZLIB_VERSION}.tar.xz"

$ZLIBNG_URL = "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIBNG_VERSION}.tar.gz"
$ZLIBNG_FILE = "zlib-ng-${ZLIBNG_VERSION}"

$OPENSSL_URL = "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz"
$OPENSSL_FILE = "openssl-${OPENSSL_VERSION}"

$BROTLI_URL = "https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz"
$BROTLI_FILE = "brotli-${BROTLI_VERSION}"

$NGHTTP2_URL = "https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.xz"
$NGHTTP2_FILE = "nghttp2-${NGHTTP2_VERSION}"

$LIBSSH2_URL = "https://www.libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.xz"
$LIBSSH2_FILE = "libssh2-${LIBSSH2_VERSION}"

$ZSTD_URL = "https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz"
$ZSTD_FILE = "zstd-${ZSTD_VERSION}"

$CURL_URL = "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.xz"
$CURL_FILE = "curl-${CURL_VERSION}"

#curl-ca-bundle
$CA_BUNDLE_URL = "https://curl.se/ca/cacert.pem"

$NGHTTP3_URL = "https://github.com/ngtcp2/nghttp3/releases/download/v${NGHTTP3_VERSION}/nghttp3-${NGHTTP3_VERSION}.tar.xz"
$NGHTTP3_FILE = "nghttp3-${NGHTTP3_VERSION}"

$NGTCP2_URL = "https://github.com/ngtcp2/ngtcp2/releases/download/v${NGTCP2_VERSION}/ngtcp2-${NGTCP2_VERSION}.tar.xz"
$NGTCP2_FILE = "ngtcp2-${NGTCP2_VERSION}"

$QUICTLS_URL = "https://github.com/quictls/openssl/archive/refs/heads/openssl-${QUICTLS_VERSION}+quic.tar.gz"
$QUICTLS_FILE = "openssl-${QUICTLS_VERSION}+quic"
$QUICTLS_DIR = "openssl-openssl-${QUICTLS_VERSION}-quic"



Write-Host "zstd: $ZSTD_URL"

Function DumpLocal {
    $dumptext = $ZLIB_VERSION + $ZLIB_HASH + $ZLIB_FILENAME + $ZLIB_URL 
    + $ZLIBNG_VERSION + $ZLIBNG_HASH + $ZLIBNG_URL + $ZLIBNG_FILE
    + $OPENSSL_HASH + $OPENSSL_URL + $OPENSSL_FILE
    + $BROTLI_HASH + $BROTLI_URL + $BROTLI_FILE 
    + $NGHTTP2_HASH + $NGHTTP2_URL + $NGHTTP2_FILE 
    + $LIBSSH2_HASH + $LIBSSH2_URL + $LIBSSH2_FILE
    + $CURL_HASH + $CURL_FILE + $CURL_URL + $CA_BUNDLE_URL + $ZSTD_URL + $ZSTD_FILE + $ZSTD_HASH
    + $NGHTTP3_HASH + $NGHTTP3_URL + $NGHTTP3_FILE
    + $NGTCP2_HASH + $NGTCP2_URL + $NGTCP2_FILE
    + $QUICTLS_HASH + $QUICTLS_URL + $QUICTLS_FILE + $QUICTLS_DIR
    Write-Host $dumptext
}

Write-Host -ForegroundColor Cyan "zlib: $ZLIB_VERSION $ZLIB_HASH
openssl: $OPENSSL_VERSION $OPENSSL_HASH
brotli: $BROTLI_VERSION
libssh2: $LIBSSH2_VERSION
nghttp2: $NGHTTP2_VERSION
zstd: $ZSTD_VERSION
curl: $CURL_VERSION"
