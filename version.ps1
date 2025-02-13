#!/usr/bin/env pwsh

$ZLIB_VERSION = "1.3.1"
$ZLIB_HASH = "38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"

$ZLIBNG_VERSION = "2.2.4"
$ZLIBNG_HASH = "a73343c3093e5cdc50d9377997c3815b878fd110bf6511c2c7759f2afb90f5a3"

$OPENSSL_VERSION = "3.4.1"
$OPENSSL_HASH = "002a2d6b30b58bf4bea46c43bdd96365aaf8daa6c428782aa4feee06da197df3"

$BROTLI_VERSION = "1.1.0"
$BROTLI_HASH = "e720a6ca29428b803f4ad165371771f5398faba397edf6778837a18599ea13ff"

$LIBSSH2_VERSION = "1.11.1"
$LIBSSH2_HASH = "9954cb54c4f548198a7cbebad248bdc87dd64bd26185708a294b2b50771e3769"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.64.0"
$NGHTTP2_HASH = "88bb94c9e4fd1c499967f83dece36a78122af7d5fb40da2019c56b9ccc6eb9dd"

$ZSTD_VERSION = "1.5.6"
$ZSTD_HASH = "8c29e06cf42aacc1eafc4077ae2ec6c6fcb96a626157e0593d5e82a34fd403c1"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.12.1"
$CURL_HASH = "0341f1ed97a26c811abaebd37d62b833956792b7607ea3f15d001613c76de202"

# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "1.7.0"
$NGHTTP3_HASH = "b4eb6bceb99293d9a9df2031c1aad166af3d57b3e33655aca0699397b6f0d751"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "1.10.0"
$NGTCP2_HASH = "4f8dc1d61957205d01c3d6aa6f1c96c7b2bac1feea71fdaf972d86db5f6465df"

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
