#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.2.12"
$ZLIB_HASH = "d8688496ea40fb61787500e863cc63c9afcbc524468cedeb478068924eb54932"

$OPENSSL_VERSION = "3.0.5"
$OPENSSL_HASH = "aa7d8d9bef71ad6525c55ba11e5f4397889ce49c2c9349dcea6d3e4f0b024a7a"

$BROTLI_VERSION = "1.0.9"
$BROTLI_HASH = "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46"

$LIBSSH2_VERSION = "1.10.0"
$LIBSSH2_HASH = "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.48.0"
$NGHTTP2_HASH = "47d8f30ee4f1bc621566d10362ca1b3ac83a335c63da7144947c806772d016e4"

$ZSTD_VERSION = "1.5.2"
$ZSTD_HASH = "7c42d56fac126929a6a85dbc73ff1db2411d04f104fae9bdea51305663a83fd0"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "7.84.0"
$CURL_HASH = "2d118b43f547bfe5bae806d8d47b4e596ea5b25a6c1f080aef49fbcd817c5db8"


# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "0.6.0"
$NGHTTP3_HASH = "6a8fea4cdc5387458d274f66efde65681e36209f6cae038393e04cdcf9c1036f"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "0.7.0"
$NGTCP2_HASH = "cccdf0381acc82bf8e2a3a2fe99de66b6123c5a01798db4b2a4f35bbdf606bd3"

# openssl-${OPENSSL_QUIC_VERSION}+quic.tar.gz
$OPENSSL_QUIC_VERSION = "3.0.5"
$OPENSSL_QUIC_HASH = "766878d2c97d13ea36254ae3b1bf553939ac111f3f1b3449b8d777aca7671366"


# Filename
$ZLIB_FILENAME = "zlib-${ZLIB_VERSION}"
$ZLIB_URL = "https://github.com/madler/zlib/archive/v${ZLIB_VERSION}.tar.gz"

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
