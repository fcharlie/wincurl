#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.2.13"
$ZLIB_HASH = "d14c38e313afc35a9a8760dadf26042f51ea0f5d154b0630a31da0540107fb98"

$OPENSSL_VERSION = "3.1.1"
$OPENSSL_HASH = "b3aa61334233b852b63ddb048df181177c2c659eb9d4376008118f9c08d07674"

$BROTLI_VERSION = "1.0.9"
$BROTLI_HASH = "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46"

$LIBSSH2_VERSION = "1.11.0"
$LIBSSH2_HASH = "a488a22625296342ddae862de1d59633e6d446eff8417398e06674a49be3d7c2"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.55.1"
$NGHTTP2_HASH = "19490b7c8c2ded1cf7c3e3a54ef4304e3a7876ae2d950d60a81d0dc6053be419"

$ZSTD_VERSION = "1.5.5"
$ZSTD_HASH = "9c4396cc829cfae319a6e2615202e82aad41372073482fce286fac78646d3ee4"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.2.0"
$CURL_HASH = "2859ec79e2cd96e976a99493547359b8001af1d1e21f3a3a3b846544ef54500f"


# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "0.13.0"
$NGHTTP3_HASH = "2b01b69c83f4506e7be3bc1a615b1818a92e762ec4be197a7931946e2ae005a0"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "0.17.0"
$NGTCP2_HASH = "c652e44788c1cbab6f9bab0f38b139712ab25a6f9f8c4287e409f1e1f30ec441"

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
