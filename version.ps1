#!/usr/bin/env pwsh

$ZLIBNG_VERSION = "2.3.2"
$ZLIBNG_HASH = "6a0561b50b8f5f6434a6a9e667a67026f2b2064a1ffa959c6b2dae320161c2a8"

$BROTLI_VERSION = "1.2.0"
$BROTLI_HASH = "816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec"

$ZSTD_VERSION = "1.5.7"
$ZSTD_HASH = "eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3"

$OPENSSL_VERSION = "3.6.0"
$OPENSSL_HASH = "b6a5f44b7eb69e3fa35dbf15524405b44837a481d43d81daddde3ff21fcbb8e9"

# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "1.14.0"
$NGHTTP3_HASH = "b3083dae2ff30cf00d24d5fedd432479532c7b17d993d384103527b36c1ec82d"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.68.0"
$NGHTTP2_HASH = "5511d3128850e01b5b26ec92bf39df15381c767a63441438b25ad6235def902c"

$LIBSSH2_VERSION = "1.11.1"
$LIBSSH2_HASH = "9954cb54c4f548198a7cbebad248bdc87dd64bd26185708a294b2b50771e3769"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.17.0"
$CURL_HASH = "955f6e729ad6b3566260e8fef68620e76ba3c31acf0a18524416a185acf77992"

$ZLIBNG_URL = "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIBNG_VERSION}.tar.gz"
$ZLIBNG_DIRNAME = "zlib-ng-${ZLIBNG_VERSION}"

$BROTLI_URL = "https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz"
$BROTLI_DIRNAME = "brotli-${BROTLI_VERSION}"

$ZSTD_URL = "https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz"
$ZSTD_DIRNAME = "zstd-${ZSTD_VERSION}"

$OPENSSL_URL = "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz"
$OPENSSL_DIRNAME = "openssl-${OPENSSL_VERSION}"

$NGHTTP3_URL = "https://github.com/ngtcp2/nghttp3/releases/download/v${NGHTTP3_VERSION}/nghttp3-${NGHTTP3_VERSION}.tar.xz"
$NGHTTP3_DIRNAME = "nghttp3-${NGHTTP3_VERSION}"

$NGHTTP2_URL = "https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.xz"
$NGHTTP2_DIRNAME = "nghttp2-${NGHTTP2_VERSION}"

$LIBSSH2_URL = "https://www.libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.xz"
$LIBSSH2_DIRNAME = "libssh2-${LIBSSH2_VERSION}"

$CURL_URL = "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.xz"
$CURL_DIRNAME = "curl-${CURL_VERSION}"

#curl-ca-bundle
$CA_BUNDLE_URL = "https://curl.se/ca/cacert.pem"

$NGHTTP3_URL = "https://github.com/ngtcp2/nghttp3/releases/download/v${NGHTTP3_VERSION}/nghttp3-${NGHTTP3_VERSION}.tar.xz"
$NGHTTP3_DIRNAME = "nghttp3-${NGHTTP3_VERSION}"

Write-Host "zstd: $ZSTD_URL"

Function UnusedSuppress {
    $unusedKeys = @(
        $ZLIBNG_VERSION, $ZLIBNG_HASH, $ZLIBNG_URL, $ZLIBNG_DIRNAME, 
        $BROTLI_HASH, $BROTLI_URL, $BROTLI_DIRNAME ,
        $ZSTD_URL, $ZSTD_DIRNAME, $ZSTD_HASH,
        $OPENSSL_HASH, $OPENSSL_URL, $OPENSSL_DIRNAME, 
        $NGHTTP3_HASH, $NGHTTP3_URL, $NGHTTP3_DIRNAME,
        $NGHTTP2_HASH, $NGHTTP2_URL, $NGHTTP2_DIRNAME ,
        $LIBSSH2_HASH, $LIBSSH2_URL, $LIBSSH2_DIRNAME,
        $CURL_HASH, $CURL_DIRNAME, $CURL_URL,
        $CA_BUNDLE_URL
    )
    Write-Host $unusedKeys
}

Write-Host -ForegroundColor Cyan "zlib: $ZLIB_VERSION $ZLIB_HASH
openssl: $OPENSSL_VERSION $OPENSSL_HASH
brotli: $BROTLI_VERSION
libssh2: $LIBSSH2_VERSION
nghttp2: $NGHTTP2_VERSION
zstd: $ZSTD_VERSION
curl: $CURL_VERSION"
