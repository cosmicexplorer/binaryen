# Needed for C++17 (std::variant) when building with the xcode toolchain.
# See https://github.com/WebAssembly/binaryen/issues/4299: emsdk sets this to 10.11 because it
# provides its own LLVM instead of using xcode, but we can't guarantee that for all our users.
# This will not overwrite a command-line flag or the same variable specified in a parent repo:
# https://cmake.org/cmake/help/latest/command/set.html#cache
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14 CACHE STRING "Minimum OS X deployment version")

# Default to release mode when unspecified, as the default is empty which is undefined behavior:
# https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#default-and-custom-configurations
set(CMAKE_BUILD_TYPE Release CACHE STRING "Single-configuration build type")
