cmake_minimum_required(VERSION 3.17)

project(CPLamP VERSION 0.1.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")

include(GNUInstallDirs)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Warnings.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Sanitize.cmake")
include(FetchContent)
include(CTest)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(CPLAMP_BUILD_TESTS "Build CPLamP tests" ON)
option(CPLAMP_USE_SYSTEM_DEPS "Use system-installed dependencies" OFF)

# --------------------------------------------------
# Dependencies
# --------------------------------------------------

if(CPLAMP_USE_SYSTEM_DEPS)
    find_package(Eigen3 REQUIRED CONFIG)
    find_package(fmt REQUIRED CONFIG)
    find_package(spdlog REQUIRED CONFIG)
else()
    # Avoid polluting `cmake --install` with dependency packages (use
    # `cmake --install ... --component CPLamP` for this project only).
    set(FMT_INSTALL OFF CACHE BOOL "" FORCE)
    set(SPDLOG_INSTALL OFF CACHE BOOL "" FORCE)

    # Eigen
    FetchContent_Declare(
        eigen
        GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
        GIT_TAG 5.0.0
    )

    # fmt
    FetchContent_Declare(
        fmt
        GIT_REPOSITORY https://github.com/fmtlib/fmt.git
        GIT_TAG 10.2.1
    )

    # spdlog - external fmt kullanacak
    set(SPDLOG_FMT_EXTERNAL ON CACHE BOOL "" FORCE)

    FetchContent_Declare(
        spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG v1.14.1
    )

    FetchContent_MakeAvailable(eigen fmt spdlog)
endif()

if(CPLAMP_BUILD_TESTS)
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG v1.14.0
    )

    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)
endif()

# --------------------------------------------------
# Main library
# --------------------------------------------------

# Object library holds real compile/link deps (FetchContent targets). The final STATIC
# target is built only from objects so install(EXPORT) does not pull eigen/spdlog into
# the export set; consumers get transitive deps via INTERFACE + CPLamPConfig.cmake.
add_library(cplamp_ai_obj OBJECT
    src/ai/dummy.cc
)

target_include_directories(cplamp_ai_obj PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
)

target_link_libraries(cplamp_ai_obj PRIVATE
    cplamp_warnings
    Eigen3::Eigen
    fmt::fmt
    spdlog::spdlog
)

if(CPLAMP_ENABLE_SANITIZERS)
    target_link_libraries(cplamp_ai_obj PRIVATE
        cplamp_sanitize
    )
endif()

add_library(cplamp_ai STATIC
    $<TARGET_OBJECTS:cplamp_ai_obj>
)

add_library(CPLamP::ai ALIAS cplamp_ai)

set_target_properties(cplamp_ai PROPERTIES
    EXPORT_NAME ai
)

target_include_directories(cplamp_ai PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

# Transitive deps for consumers are appended in CPLamPConfig.cmake after
# include(CPLamPTargets.cmake) so install(EXPORT) does not reference FetchContent targets.

# --------------------------------------------------
# Tests
# --------------------------------------------------

if(CPLAMP_BUILD_TESTS)
    add_executable(cplamp_ai_tests
        tests/test_dummy.cpp
    )

    target_link_libraries(cplamp_ai_tests PRIVATE
        cplamp_ai
        cplamp_warnings
        GTest::gtest_main
        fmt::fmt
        spdlog::spdlog
    )

    include(GoogleTest)
    gtest_discover_tests(cplamp_ai_tests)
endif()

# --------------------------------------------------
# Install and CMake package config
# --------------------------------------------------

include(CMakePackageConfigHelpers)

install(TARGETS cplamp_ai
    EXPORT CPLamPTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT CPLamP
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT CPLamP
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT CPLamP
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT CPLamP
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPLamPConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CPLamPConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CPLamP
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/CPLamPConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/CPLamPConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/CPLamPConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CPLamP
    COMPONENT CPLamP
)

install(EXPORT CPLamPTargets
    FILE CPLamPTargets.cmake
    NAMESPACE CPLamP::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/CPLamP
    COMPONENT CPLamP
)