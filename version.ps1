#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.2.13"
$ZLIB_HASH = "d14c38e313afc35a9a8760dadf26042f51ea0f5d154b0630a31da0540107fb98"

$OPENSSL_VERSION = "3.1.0"
$OPENSSL_HASH = "aaa925ad9828745c4cad9d9efeb273deca820f2cdcf2c3ac7d7c1212b7c497b4"

$BROTLI_VERSION = "1.0.9"
$BROTLI_HASH = "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46"

$LIBSSH2_VERSION = "1.10.0"
$LIBSSH2_HASH = "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.53.0"
$NGHTTP2_HASH = "b867184254e5a29b0ba68413aa14f8b0ce1142a371761374598dec092dabb809"

$ZSTD_VERSION = "1.5.5"
$ZSTD_HASH = "9c4396cc829cfae319a6e2615202e82aad41372073482fce286fac78646d3ee4"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.1.1"
$CURL_HASH = "08a948e061929645597c1ef7194e07b308b22084ff03fa7400b465e6c05149e5"


# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "0.11.0"
$NGHTTP3_HASH = "dcd85fc092eab8e08021c286d87e40eb3539bbd133b437fcd70c2b9ff460a09f"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "0.15.0"
$NGTCP2_HASH = "730b6700e4766fa70b311bcf88f1004f78ef3288f18e6e9cf42dfe9b655d412e"

# openssl-${QUICTLS_VERSION}+quic.tar.gz
$QUICTLS_VERSION = "3.1.0"
$QUICTLS_HASH = "4e356a49891adbbd74f88af065a52e151643737783874c888045ec1acf15d0ea"


# Filename
$ZLIB_FILENAME = "zlib-${ZLIB_VERSION}"
$ZLIB_URL = "https://zlib.net/zlib-${ZLIB_VERSION}.tar.xz"

$OPENSSL_URL = "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
$OPENSSL_FILE = "openssl-${OPENSSL_VERSION}"

$BROTLI_URL = "https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz"
$BROTLI_FILE = "brotli-${BROTLI_VERSION}"

$NGHTTP2_URL = "https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.xz"
$NGHTTP2_FILE = "nghttp2-${NGHTTP2_VERSION}"

$LIBSSH2_URL = "https://www.libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.gz"
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

Function DumpLocal {
    $dumptext = $ZLIB_VERSION + $ZLIB_HASH + $ZLIB_FILENAME + $ZLIB_URL 
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
