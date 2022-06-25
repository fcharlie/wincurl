cmake_minimum_required(VERSION 3.22)

project(zstd C)

if(MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS=1 -utf-8 -W3 -DUNICODE=1 -D_UNICODE=1 -wd26812")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS=1 -utf-8 -W3 -permissive- -Zc:__cplusplus -DUNICODE=1 -D_UNICODE=1 -wd26812"
  )
  set(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} -c65001")
endif(MSVC)

file(
  GLOB
  ZSTD_SOURCES
  lib/common/*.c
  lib/compress/*.c
  lib/decompress/*.c
  lib/dictBuilder/*.c)

add_library(zstd STATIC ${ZSTD_SOURCES})

target_compile_definitions(zstd PRIVATE XXH_PRIVATE_API ZSTD_MULTITHREAD ZSTD_DISABLE_ASM)
target_include_directories(zstd PRIVATE zstd zstd/common)

include(GNUInstallDirs)
install(TARGETS zstd RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES "lib/zstd.h" "lib/zdict.h" "lib/zstd_errors.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
