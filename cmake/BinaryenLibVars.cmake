function(declare_shared_lib_option)
  if(MSVC)
    set(_default OFF)
  else()
    set(_default ON)
  endif()
  option(BUILD_SHARED_LIB "Build a shared library" "${_default}")
  if(MSVC AND BUILD_SHARED_LIB)
    message(FATAL_ERROR "We don't have dllexport declarations set up for Windows yet.")
  endif()
endfunction()

declare_shared_lib_option()
option(BUILD_STATIC_LIB "Build as a static library" ON)
if(NOT BUILD_SHARED_LIB AND NOT BUILD_STATIC_LIB)
  message(FATAL_ERROR "At least one of BUILD_STATIC_LIB or BUILD_SHARED_LIB must be enabled.")
endif()

function(declare_llvm_dwarf_option)
  if(EMSCRIPTEN)
    # For now, don't include full DWARF support in JS builds, for size.
    set(_default OFF)
  else()
    set(_default ON)
  endif()
  option(BUILD_LLVM_DWARF
    "Enable full DWARF support. Note that this can take up significantly more space, \
especially in JS builds."
    "${_default}")
endfunction()
declare_llvm_dwarf_option()


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
option(BUILD_MIMALLOC "Build with mimalloc allocator" OFF)
