@echo off
setlocal EnableDelayedExpansion

:: Build lz4 shared library using CMake (supports win-64 and win-arm64)
mkdir %SRC_DIR%\build_shared
cd %SRC_DIR%\build_shared
if errorlevel 1 exit 1

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DLZ4_BUILD_CLI=ON ^
    -DLZ4_BUILD_LEGACY_LZ4C=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_STATIC_LIBS=OFF ^
    %SRC_DIR%\build\cmake
if errorlevel 1 exit 1

cmake --build . --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: Run tests only if not cross-compiling
if not "%CONDA_BUILD_CROSS_COMPILATION%"=="1" (
    echo Running tests...
    lz4 -i1b lz4.exe
    if errorlevel 1 exit 1
    lz4 -i1b5 lz4.exe
    if errorlevel 1 exit 1
)

:: Install shared library
cmake --install . --config Release
if errorlevel 1 exit 1

:: Also build static library (for lz4-c-static output to copy later)
mkdir %SRC_DIR%\build_static
cd %SRC_DIR%\build_static
if errorlevel 1 exit 1

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DLZ4_BUILD_CLI=OFF ^
    -DLZ4_BUILD_LEGACY_LZ4C=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DBUILD_STATIC_LIBS=ON ^
    %SRC_DIR%\build\cmake
if errorlevel 1 exit 1

cmake --build . --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1
