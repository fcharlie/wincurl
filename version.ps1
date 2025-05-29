#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.3.1"
$ZLIB_HASH = "38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"

$ZLIBNG_VERSION = "2.2.4"
$ZLIBNG_HASH = "a73343c3093e5cdc50d9377997c3815b878fd110bf6511c2c7759f2afb90f5a3"

$OPENSSL_VERSION = "3.5.0"
$OPENSSL_HASH = "344d0a79f1a9b08029b0744e2cc401a43f9c90acd1044d09a530b4885a8e9fc0"

$BROTLI_VERSION = "1.1.0"
$BROTLI_HASH = "e720a6ca29428b803f4ad165371771f5398faba397edf6778837a18599ea13ff"

$LIBSSH2_VERSION = "1.11.1"
$LIBSSH2_HASH = "9954cb54c4f548198a7cbebad248bdc87dd64bd26185708a294b2b50771e3769"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.65.0"
$NGHTTP2_HASH = "f1b9df5f02e9942b31247e3d415483553bc4ac501c87aa39340b6d19c92a9331"

$ZSTD_VERSION = "1.5.7"
$ZSTD_HASH = "eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.14.0"
$CURL_HASH = "b3634cfc538c72c9c6ca794ef4c73d7fdbd171e8dee2db837d83a5e45231002a"

# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "1.10.1"
$NGHTTP3_HASH = "e6b8ebaadf8e57cba77a3e34ee8de465fe952481fbf77c4f98d48737bdf50e03"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "1.13.0"
$NGTCP2_HASH = "cc98cdd7d0ce0050b5589c99f89ac72fb34aee6ff88bb3351f239407a65699fe"

# openssl-${QUICTLS_VERSION}+quic.tar.gz
$QUICTLS_VERSION = "3.3.0"
$QUICTLS_HASH = "392b6784ca12b9f068582212a9498366ffd3dd1bafe79507046bdd1a6a138cc9"


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
