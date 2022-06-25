cmake_minimum_required(VERSION 3.22)

project(brotli C)

if(MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS=1 -utf-8 -W3 -DUNICODE=1 -D_UNICODE=1 -wd26812")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS=1 -utf-8 -W3 -permissive- -Zc:__cplusplus -DUNICODE=1 -D_UNICODE=1 -wd26812"
  )
  set(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} -c65001")
endif(MSVC)

set(BROTLI_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/c/include")
mark_as_advanced(BROTLI_INCLUDE_DIRS)
file(
  GLOB
  BROTLI_SOURCES
  c/common/*.c
  c/dec/*.c
  c/enc/*.c)
add_library(brotli STATIC ${BROTLI_SOURCES})
target_include_directories(brotli PRIVATE ${BROTLI_INCLUDE_DIRS})

include(GNUInstallDirs)
install(TARGETS brotli RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(DIRECTORY ${BROTLI_INCLUDE_DIRS}/brotli DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
