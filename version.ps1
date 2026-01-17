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

# ngtcp2-${NGTCP2_VERSION}.tar.xz
$NGTCP2_VERSION = "1.19.0"
$NGTCP2_HASH = "f11f7da5065f2298f8b5f079a11f1a6f72389271b8dedd893c8eb26aba94bce9"

# curl-${CURL_VERSION}.tar.xz
$CURL_VERSION = "8.18.0"
$CURL_HASH = "40df79166e74aa20149365e11ee4c798a46ad57c34e4f68fd13100e2c9a91946"

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
