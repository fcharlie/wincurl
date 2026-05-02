#!/usr/bin/env pwsh

$ZLIBNG_VERSION = "2.3.3"
$ZLIBNG_HASH = "f9c65aa9c852eb8255b636fd9f07ce1c406f061ec19a2e7d508b318ca0c907d1"

$BROTLI_VERSION = "1.2.0"
$BROTLI_HASH = "816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec"

$ZSTD_VERSION = "1.5.7"
$ZSTD_HASH = "eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3"

$OPENSSL_VERSION = "4.0.0"
$OPENSSL_HASH = "c32cf49a959c4f345f9606982dd36e7d28f7c58b19c2e25d75624d2b3d2f79ac"

# nghttp3-${NGHTTP3_VERSION}.tar.xz
$NGHTTP3_VERSION = "1.15.0"
$NGHTTP3_HASH = "6da0cd06b428d32a54c58137838505d9dc0371a900bb8070a46b29e1ceaf2e0f"

# nghttp2-${NGHTTP2_VERSION}.tar.xz
$NGHTTP2_VERSION = "1.69.0"
$NGHTTP2_HASH = "1fb324b6ec2c56f6bde0658f4139ffd8209fa9e77ce98fd7a5f63af8d0e508ad"

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "1.22.1"
$NGTCP2_HASH = "dfd2c68bd64b89847c611425b9487105c46e8447b5c21e6aeb00642c8fbe2ca8"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.20.0"
$CURL_HASH = "63fe2dc148ba0ceae89922ef838f7e5c946272c2e78b7c59fab4b79d3ce2b896"

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

$NGTCP2_URL = "https://github.com/ngtcp2/ngtcp2/releases/download/v${NGTCP2_VERSION}/ngtcp2-${NGTCP2_VERSION}.tar.xz"
$NGTCP2_DIRNAME = "ngtcp2-${NGTCP2_VERSION}"

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
        $NGTCP2_HASH, $NGTCP2_URL, $NGTCP2_DIRNAME,
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
