cmake_minimum_required(VERSION 3.22)

project(zlib C)

set(VERSION "1.2.13")

if(MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS=1 -utf-8 -W3 -DUNICODE=1 -D_UNICODE=1 -wd26812")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS=1 -utf-8 -W3 -permissive- -Zc:__cplusplus -DUNICODE=1 -D_UNICODE=1 -wd26812"
  )
  set(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} -c65001")
endif(MSVC)

option(ASM686 "Enable building i686 assembly implementation")
option(AMD64 "Enable building amd64 assembly implementation")

include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckCSourceCompiles)
enable_testing()

check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stddef.h HAVE_STDDEF_H)

#
# Check to see if we have large file support
#
set(CMAKE_REQUIRED_DEFINITIONS -D_LARGEFILE64_SOURCE=1)
# We add these other definitions here because CheckTypeSize.cmake in CMake 2.4.x does not automatically do so and we
# want compatibility with CMake 2.4.x.
if(HAVE_SYS_TYPES_H)
  list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_SYS_TYPES_H)
endif()
if(HAVE_STDINT_H)
  list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_STDINT_H)
endif()
if(HAVE_STDDEF_H)
  list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_STDDEF_H)
endif()
check_type_size(off64_t OFF64_T)
if(HAVE_OFF64_T)
  add_definitions(-D_LARGEFILE64_SOURCE=1)
endif()
set(CMAKE_REQUIRED_DEFINITIONS) # clear variable

#
# Check for fseeko
#
check_function_exists(fseeko HAVE_FSEEKO)
if(NOT HAVE_FSEEKO)
  add_definitions(-DNO_FSEEKO)
endif()

#
# Check for unistd.h
#
check_include_file(unistd.h Z_HAVE_UNISTD_H)

if(MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
  add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
  include_directories(${CMAKE_CURRENT_SOURCE_DIR})
endif()

if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
  # If we're doing an out of source build and the user has a zconf.h in their source tree...
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zconf.h)
    message(STATUS "Renaming")
    message(STATUS "    ${CMAKE_CURRENT_SOURCE_DIR}/zconf.h")
    message(STATUS "to 'zconf.h.included' because this file is included with zlib")
    message(STATUS "but CMake generates it automatically in the build directory.")
    file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/zconf.h ${CMAKE_CURRENT_SOURCE_DIR}/zconf.h.included)
  endif()
endif()

set(ZLIB_PC ${CMAKE_CURRENT_BINARY_DIR}/zlib.pc)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/zlib.pc.cmakein ${ZLIB_PC} @ONLY)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/zconf.h.cmakein ${CMAKE_CURRENT_BINARY_DIR}/zconf.h @ONLY)
include_directories(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_SOURCE_DIR})

# ============================================================================
# zlib
# ============================================================================

set(ZLIB_PUBLIC_HDRS ${CMAKE_CURRENT_BINARY_DIR}/zconf.h zlib.h)
set(ZLIB_PRIVATE_HDRS
    crc32.h
    deflate.h
    gzguts.h
    inffast.h
    inffixed.h
    inflate.h
    inftrees.h
    trees.h
    zutil.h)
set(ZLIB_SRCS
    adler32.c
    compress.c
    crc32.c
    deflate.c
    gzclose.c
    gzlib.c
    gzread.c
    gzwrite.c
    inflate.c
    infback.c
    inftrees.c
    inffast.c
    trees.c
    uncompr.c
    zutil.c)

if(CMAKE_COMPILER_IS_GNUCC)
  if(ASM686)
    set(ZLIB_ASMS contrib/asm686/match.S)
  elseif(AMD64)
    set(ZLIB_ASMS contrib/amd64/amd64-match.S)
  endif()

  if(ZLIB_ASMS)
    add_definitions(-DASMV)
    set_source_files_properties(${ZLIB_ASMS} PROPERTIES LANGUAGE C COMPILE_FLAGS -DNO_UNDERLINE)
  endif()
endif()

if(MSVC)
  if(ASM686)
    enable_language(ASM_MASM)
    set(ZLIB_ASMS contrib/masmx86/inffas32.asm contrib/masmx86/match686.asm)
  elseif(AMD64)
    enable_language(ASM_MASM)
    set(ZLIB_ASMS contrib/masmx64/gvmat64.asm contrib/masmx64/inffasx64.asm)
  endif()

  if(ZLIB_ASMS)
    add_definitions(-DASMV -DASMINF)
  endif()
endif()

# parse the full version number from zlib.h and include in ZLIB_FULL_VERSION
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/zlib.h _zlib_h_contents)
string(REGEX REPLACE ".*#define[ \t]+ZLIB_VERSION[ \t]+\"([-0-9A-Za-z.]+)\".*" "\\1" ZLIB_FULL_VERSION
                     ${_zlib_h_contents})
add_library(zlib STATIC ${ZLIB_SRCS} ${ZLIB_ASMS} ${ZLIB_PUBLIC_HDRS} ${ZLIB_PRIVATE_HDRS})

include(GNUInstallDirs)
install(TARGETS zlib RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES "zlib.h" "zutil.h" "${CMAKE_CURRENT_BINARY_DIR}/zconf.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
