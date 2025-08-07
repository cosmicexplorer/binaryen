include(FlagHandling)
include(RepoBuildDeps)

declare_negated_condition_option(MSVC BUILD_SHARED_LIB "Build a shared library")
if(MSVC AND BUILD_SHARED_LIB)
  message(FATAL_ERROR "We don't have dllexport declarations set up for Windows yet.")
endif()

option(BUILD_STATIC_LIB "Build as a static library" ON)
if(NOT BUILD_SHARED_LIB AND NOT BUILD_STATIC_LIB)
  message(FATAL_ERROR "At least one of BUILD_STATIC_LIB or BUILD_SHARED_LIB must be enabled.")
endif()

# For now, don't include full DWARF support in JS builds, for size.
declare_negated_condition_option(EMSCRIPTEN BUILD_LLVM_DWARF
  "Enable full DWARF support. \
Note that this can take up significantly more space, especially for emscripten (JS) builds.")

# Advised to turn on when statically linking against musl libc (e.g., in the
# Alpine Linux build we use for producing official Linux binaries), because
# musl libc's allocator has
#
# (editor's note: used to have)
#
# very bad performance on heavily multi-threaded
# workloads / high core count machines. But it also works with dynamic linking
# with a small performance advantage in some cases over the glibc allocator.
# See https://github.com/WebAssembly/binaryen/issues/5561.
declare_default_option_if_submodules_available(BUILD_MIMALLOC "Build with mimalloc allocator")
