function(emscripten_cmake_internal_optimization_smoke_test_assertion)
  if(CMAKE_BUILD_TYPE MATCHES "Release")
    # Extra check that cmake has set -O3 in its release flags.
    # This is really as an assertion that cmake is behaving as we expect.
    if(NOT CMAKE_CXX_FLAGS_RELEASE_INIT MATCHES "-O3")
      message(FATAL_ERROR "Expected -O3 to be in release link flags \
(see discussion at https://github.com/WebAssembly/binaryen/pull/5103)")
    endif()
  endif()
endfunction()

# Note: to debug with DWARF you will usually want to enable BIGINT support, as
# that helps avoid running Binaryen on the wasm after link. Binaryen's DWARF
# rewriting has known limitations, so avoiding it during link is recommended
# where possible (like local debugging).
#
# Note that this is debug info for Binaryen itself, that is, when you are
# debugging Binaryen source code. This flag has no impact on what Binaryen
# does when run on wasm files.
option(ENABLE_BIGINT "Enable wasm BigInt support" OFF)

# Turn this on to use the Wasm EH feature instead of emscripten EH in the wasm/BinaryenJS builds
option(EMSCRIPTEN_ENABLE_WASM_EH "Enable Wasm EH feature in emscripten build" OFF)

option(EMSCRIPTEN_ENABLE_WASM64 "Enable memory64 in emscripten build" OFF)

# Turn this on to use pthreads feature in the wasm/BinaryenJS builds
option(EMSCRIPTEN_ENABLE_PTHREADS "Enable pthreads in emscripten build" OFF)

# Turn this on to compile binaryen toolchain utilities for the browser.
option(BUILD_FOR_BROWSER "Build binaryen toolchain utilities for the browser" OFF)

# Turn this on to build binaryen.js as ES5, with additional compatibility configuration for js_of_ocaml.
option(JS_OF_OCAML "Build binaryen.js for js_of_ocaml" OFF)

# Turn this off to generate a separate .wasm file instead of packaging it into the JS.
# This is useful for debugging, performance analysis, and other testing.
option(EMSCRIPTEN_ENABLE_SINGLE_FILE "Enable SINGLE_FILE mode in emscripten build" ON)
