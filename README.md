# CPLamP

A modular C++ deep learning framework inspired by PyTorch.

## Requirements

- CMake 3.17 or newer
- A C++17 compiler (MSVC, GCC, or Clang)

## Dependencies

By default, **Eigen**, **fmt**, and **spdlog** are fetched with CMake `FetchContent` at configure time (pinned tags in the root `CMakeLists.txt`).

To use system packages instead:

```bash
cmake -B build -DCPLAMP_USE_SYSTEM_DEPS=ON
```

You must have `Eigen3`, `fmt`, and `spdlog` available as CMake config packages (`find_package(... CONFIG)`).

## Configure and build

```bash
cmake -B build
cmake --build build
```

On Windows with multi-config generators (Visual Studio), pick a configuration explicitly:

```powershell
cmake --build build --config Debug
```

### Tests

Tests are enabled by default (`CPLAMP_BUILD_TESTS=ON`). After building:

```powershell
ctest --test-dir build -C Debug
```

On single-config generators (Ninja, Unix Makefiles), omit `-C` or use the same value as your `CMAKE_BUILD_TYPE`.

## Install

CPLamP installs a static library, public headers, and CMake package files (`CPLamPConfig.cmake`, a version file, and `CPLamPTargets.cmake`).

Install rules use the **`CPLamP` component** so that `cmake --install` can install only this project and avoid pulling in unrelated dependency install rules (for example Eigen’s own install).

**Recommended** (Windows, Debug):

```powershell
cmake --install build --config Debug --prefix "C:/path/to/install" --component CPLamP
```

Linux / macOS (single-config, Release example):

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
cmake --install build --prefix /path/to/install --component CPLamP
```

Typical layout under the prefix:

- `include/cplamp/…` — public headers
- `lib/` — static library (`cplamp_ai.lib` on MSVC, `libcplamp_ai.a` on typical Unix)
- `lib/cmake/CPLamP/` — `CPLamPConfig.cmake`, `CPLamPConfigVersion.cmake`, `CPLamPTargets*.cmake`

## Using CPLamP from another CMake project

Set `CMAKE_PREFIX_PATH` to the install prefix (or pass `-DCMAKE_PREFIX_PATH=...` when configuring the consumer):

```cmake
find_package(CPLamP CONFIG REQUIRED)

add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE CPLamP::ai)
```

`CPLamPConfig.cmake` runs `find_dependency` for Eigen3, fmt, and spdlog, then links them to `CPLamP::ai` so consumers link correctly with the static library.

## CMake options

| Option | Default | Meaning |
|--------|---------|---------|
| `CPLAMP_BUILD_TESTS` | `ON` | Build GoogleTest-based tests |
| `CPLAMP_USE_SYSTEM_DEPS` | `OFF` | Use `FetchContent` vs system Eigen / fmt / spdlog |
| `CPLAMP_ENABLE_SANITIZERS` | `OFF` | Sanitizer flags (see `cmake/Sanitize.cmake`) |

## License

MIT — see [LICENSE](LICENSE).
