cmake_minimum_required(VERSION 3.16)
set(PROJECT_VERSION_NAME "v0.0.1")

# Split and sanatize the project version so it can be uses as pars and used as
# the project version "v1.1.1" is not a valida version number
string(REPLACE "v" "" PROJECT_VERSION ${PROJECT_VERSION_NAME})
string(REPLACE "." ";" VERSION_LIST ${PROJECT_VERSION})
list(GET VERSION_LIST 0 PROJECT_VERSION_MAJOR)
list(GET VERSION_LIST 1 PROJECT_VERSION_MINOR)
list(GET VERSION_LIST 2 PROJECT_VERSION_PATCH)

project ("Ivy" VERSION ${PROJECT_VERSION})
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set the build type if its not test
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

# Ensure the build type is valid
if(NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug" AND
   NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Release" AND
   NOT "${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel" AND
   NOT "${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    message(FATAL_ERROR "Unknown build type \"${CMAKE_BUILD_TYPE}\". Allowed values are Debug, Release, RelWithDebInfo, and MinSizeRel.")
endif()

# detect operating system and host processor
message(STATUS "We are on a ${CMAKE_SYSTEM_NAME} system")
message(STATUS "The host processor is ${CMAKE_HOST_SYSTEM_PROCESSOR}")

# Place binaries and libraries according to GNU standards. For example
# executables created with `add_executable` will be built into the `bin`
# directory
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

# Set the default compiler flags for GNU
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wunreachable-code -Wno-unknown-pragmas -Wno-sign-compare -Wwrite-strings -Wno-unused")
    set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
endif()

find_package(PkgConfig REQUIRED)
find_package(Threads REQUIRED)

file(GLOB_RECURSE IVY_HEADER "${CMAKE_CURRENT_LIST_DIR}/cpp/*.hpp")
file(GLOB_RECURSE IVY_SOURCE "${CMAKE_CURRENT_LIST_DIR}/cpp/*.cpp")
list(FILTER IVY_SOURCE EXCLUDE REGEX "_test\\.cpp$")
list(FILTER IVY_SOURCE EXCLUDE REGEX "cli\\.cpp$")

add_library(ivy SHARED ${IVY_SOURCE} ${IVY_HEADER})
target_link_libraries(ivy Threads::Threads)

add_executable(ivycli ${IVY_SOURCE} ${IVY_HEADER} ${CMAKE_CURRENT_LIST_DIR}/cpp/cli.cpp)
target_link_libraries(ivycli Threads::Threads)
