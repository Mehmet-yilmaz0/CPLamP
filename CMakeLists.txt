cmake_minimum_required(VERSION 3.17)

project(CPLamP LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Warnings.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Sanitize.cmake")
include(FetchContent)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

#dependencies
if(CPLAMP_USE_SYSTEM_DEPS)
    find_package(Eigen3 REQUIRED CONFIG)
    find_package(fmt REQUIRED CONFIG)
    find_package(spdlog REQUIRED CONFIG)
else()
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

add_library(cplamp_ai STATIC
    src/ai/dummy.cc
)

add_library(CPLamP::ai ALIAS cplamp_ai)

target_include_directories(cplamp_ai PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_link_libraries(cplamp_ai PRIVATE
    cplamp_warnings
    Eigen3::Eigen
    fmt::fmt
    spdlog::spdlog
)

if(CPLAMP_ENABLE_SANITIZERS)
    target_link_libraries(cplamp_ai PRIVATE
        cplamp_sanitize
    )
endif()