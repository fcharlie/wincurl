#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.2.13"
$ZLIB_HASH = "d14c38e313afc35a9a8760dadf26042f51ea0f5d154b0630a31da0540107fb98"

$OPENSSL_VERSION = "3.0.7"
$OPENSSL_HASH = "83049d042a260e696f62406ac5c08bf706fd84383f945cf21bd61e9ed95c396e"

$BROTLI_VERSION = "1.0.9"
$BROTLI_HASH = "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46"

$LIBSSH2_VERSION = "1.10.0"
$LIBSSH2_HASH = "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.51.0"
$NGHTTP2_HASH = "66aa76d97c143f42295405a31413e5e7d157968dad9f957bb4b015b598882e6b"

$ZSTD_VERSION = "1.5.2"
$ZSTD_HASH = "7c42d56fac126929a6a85dbc73ff1db2411d04f104fae9bdea51305663a83fd0"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "7.87.0"
$CURL_HASH = "ee5f1a1955b0ed413435ef79db28b834ea5f0fb7c8cfb1ce47175cc3bee08fff"


# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "0.8.0"
$NGHTTP3_HASH = "360dff3a914136a3394cd4fe52cb2c7df2528ddbbd8a61231538bf46ab74b2d7"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "0.13.0"
$NGTCP2_HASH = "2e25642b9a6305890124cfc3f2ba45ef826f7cd69292418c0bf45ae1ee5c3238"

# openssl-${OPENSSL_QUIC_VERSION}+quic.tar.gz
$OPENSSL_QUIC_VERSION = "3.0.7"
$OPENSSL_QUIC_HASH = "dcdf14cb7840980217fcb467c56b15cc59a5d44338129e43cf41ec3d4309b6ad"


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

$OPENSSL_QUIC_URL = "https://github.com/quictls/openssl/archive/refs/heads/openssl-${OPENSSL_QUIC_VERSION}+quic.tar.gz"
$OPENSSL_QUIC_FILE = "openssl-${OPENSSL_QUIC_VERSION}+quic"
$OPENSSL_QUIC_DIR = "openssl-openssl-${OPENSSL_QUIC_VERSION}-quic"

Function DumpLocal {
    $dumptext = $ZLIB_VERSION + $ZLIB_HASH + $ZLIB_FILENAME + $ZLIB_URL 
    + $OPENSSL_HASH + $OPENSSL_URL + $OPENSSL_FILE
    + $BROTLI_HASH + $BROTLI_URL + $BROTLI_FILE 
    + $NGHTTP2_HASH + $NGHTTP2_URL + $NGHTTP2_FILE 
    + $LIBSSH2_HASH + $LIBSSH2_URL + $LIBSSH2_FILE
    + $CURL_HASH + $CURL_FILE + $CURL_URL + $CA_BUNDLE_URL + $ZSTD_URL + $ZSTD_FILE + $ZSTD_HASH
    + $NGHTTP3_HASH + $NGHTTP3_URL + $NGHTTP3_FILE
    + $NGTCP2_HASH + $NGTCP2_URL + $NGTCP2_FILE
    + $OPENSSL_QUIC_HASH + $OPENSSL_QUIC_URL + $OPENSSL_QUIC_FILE + $OPENSSL_QUIC_DIR
    Write-Host $dumptext
}

Write-Host -ForegroundColor Cyan "zlib: $ZLIB_VERSION $ZLIB_HASH
openssl: $OPENSSL_VERSION $OPENSSL_HASH
brotli: $BROTLI_VERSION
libssh2: $LIBSSH2_VERSION
nghttp2: $NGHTTP2_VERSION
zstd: $ZSTD_VERSION
curl: $CURL_VERSION"
