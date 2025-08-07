# The oldest version of Ubuntu they even display on their site is jammy (22.04LTS), which uses 3.22:
# https://packages.ubuntu.com/jammy/cmake
cmake_minimum_required(VERSION 3.22..4.0)
# Deduplicate library link lines according to the prowess of the linker.
cmake_policy(SET CMP0156 NEW)   # shared
cmake_policy(SET CMP0179 NEW)   # static
# Allow parsing and re-quoting link lines.
cmake_policy(SET CMP0181 NEW)
# Always set a value for an empty single-value arg in cmake_parse_arguments().
cmake_policy(SET CMP0174 NEW)

# Assert build environment prerequisites that must be set before the project() call.
include("cmake/cmake-env-requirements.cmake")

project(binaryen
  VERSION 0.0.0
  LANGUAGES CXX
  DESCRIPTION "A compiler and toolchain infrastructure library for WebAssembly."
  HOMEPAGE_URL "https://github.com/WebAssembly/binaryen"
)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")


## Process user-specified build configuration options.

# Declare global build configuration options.
include(BinaryenVars)
# Declare options that identify which library targets to build and any runtime dependencies.
include(BinaryenLibVars)
# Declare options that identify which executables to build.
include(BinaryenExeVars)
# Declare options that identify which tests to build, including any third-party test dependencies.
include(BinaryenTestVars)
# Set default compile and link options for this subdirectory, including warnings.
# These flags will also be applied to any third-party dependencies we end up building
# from submodules.
include(BinaryenDefaultFlags)

## Time for the exciting part:
# - Search for the specified third-party dependencies,
# - Attempt to build them from this repo if unavailable.
# Error if any deps could not be located or built.
include(BinaryenSearchDeps)

# Set compile/link flags which depend on user-specified options and/or the specified
# third-party dependencies.
include("cmake/binaryen-flags.cmake")

# Setup configuration for builds of binaryen through emscripten (in particular, emcmake).
if(EMSCRIPTEN)
  # Declare any options specific to emscripten builds.
  include(EmscriptenVars)
  # Set flags which depend on the emscripten-specific build options.
  include("cmake/emscripten-flags.cmake")
endif()


## Now we can finally describe this codebase and how to build it together!

# Declare the absolute minimum C++ standard required to build.
include(RequiredCxxStd)
declare_required_cxx_standard()

add_library(binaryen-library-requirements INTERFACE)
# All our sources must be -fPIC
set_target_properties(binaryen-library-requirements
  PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
target_compile_features(binaryen-library-requirements INTERFACE
  cxx_std_${binaryen_REQUIRED_CXX_STANDARD})


## Declare our exported library artifacts.
if(BUILD_SHARED_LIB)
  message(STATUS "Building libbinaryen.so as a shared library.")
  add_library(binaryen-shared SHARED)

  set_target_properties(binaryen-shared PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    OUTPUT_NAME ${PROJECT_NAME}
    # This is needed because we construct these without any source files of their own, so cmake is
    # unable to infer it as it would expect to.
    LINKER_LANGUAGE CXX
  )

  # Disable interposition and resolve Binaryen symbols locally.
  target_link_options(binaryen-shared PRIVATE
    $<$<PLATFORM_ID:LINUX>:-Bsymbolic>
  )

  # Ensure we propagate any dependencies of the exported shared library to anything else that
  # depends on the shared lib, since the shared lib does not contain its transitive deps.
  target_link_libraries(binaryen-shared PUBLIC
    Threads::Threads
    $<$<BOOL:${BUILD_MIMALLOC}>:mimalloc>
    $<$<BOOL:${BUILD_LLVM_DWARF}>:llvm_dwarf>
  )
endif()

if(BUILD_STATIC_LIB)
  message(STATUS "Building libbinaryen.a as a statically linked library.")
  add_library(binaryen-static STATIC)

  set_target_properties(binaryen-static PROPERTIES
    OUTPUT_NAME ${PROJECT_NAME}
    # This is needed because we construct these without any source files of their own, so cmake is
    # unable to infer it as it would expect to.
    LINKER_LANGUAGE CXX
  )

  # FIXME: we need to specify sources here!
  target_compile_definitions(binaryen-static PRIVATE BUILD_STATIC_LIBRARY)

  # Conversely, we can keep all these deps to ourself in the static library.
  target_link_libraries(binaryen-shared PUBLIC
    Threads::Threads
    # Match static/dynamic linking between libbinaryen and mimalloc.
    $<$<BOOL:${BUILD_MIMALLOC}>:mimalloc-static>
    $<$<BOOL:${BUILD_LLVM_DWARF}>:llvm_dwarf>
  )
endif()

# Any executables or emscripten .js outputs need a specific one of the available outputs to depend
# against. We default to the shared library if available as dynamic linking reduces executable size.
set(ALL_BINARY_INSTALLABLE_TARGETS)
if(BUILD_SHARED_LIB)
  list(APPEND ALL_BINARY_INSTALLABLE_TARGETS binaryen-shared)
  add_library(binaryen-default ALIAS binaryen-shared)
elseif(BUILD_STATIC_LIB)
  list(APPEND ALL_BINARY_INSTALLABLE_TARGETS binaryen-static)
  add_library(binaryen-default ALIAS binaryen-static)
endif()


function(binaryen_add_executable)
  list(POP_FRONT ARGV name)
  add_executable("${name}" ${ARGV})
  target_link_libraries("${name}" PRIVATE binaryen-default)
  setup_rpath_for_target("${name}")
  install(TARGETS "${name}" DESTINATION ${CMAKE_INSTALL_BINDIR})
endfunction()


## Perform the bulk of the build process, including the generation of executables.
add_subdirectory(src)


# Sources.
function(extract_sources_and_headers_from_api_target from_target to_target)
  # Extract the specially-marked headers.
  get_target_property(delegations ${from_target} HEADER_SET_delegations)
  get_target_property(headers ${from_target} HEADER_SET)

  # Now write the publicly exported headers.
  target_sources(${to_target} PUBLIC
    FILE_SET HEADERS FILES ${headers}
    FILE_SET delegations TYPE HEADERS FILES ${delegations}
  )
  # Now link the objects which have been accumulating this whole time.
  target_link_libraries(${to_target} PRIVATE $<TARGET_OBJECTS:${from_target}>)
endfunction()

if(BUILD_SHARED_LIB)
  extract_sources_and_headers_from_api_target(binaryen-c binaryen-shared)
endif()
if(BUILD_STATIC_LIB)
  extract_sources_and_headers_from_api_target(binaryen-c binaryen-static)
endif()

include(GNUInstallDirs)
install(TARGETS ${ALL_BINARY_INSTALLABLE_TARGETS}
  EXPORT ${PROJECT_NAME}
  RUNTIME COMPONENT Runtime
  LIBRARY COMPONENT Runtime NAMELINK_COMPONENT Development
  ARCHIVE COMPONENT Development
  FILE_SET delegations COMPONENT Development
  FILE_SET HEADERS COMPONENT Development
)
install(EXPORT ${PROJECT_NAME}
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}-${PROJECT_VERSION}
)

# Configure lit tests
if(BUILD_LIT_TESTS)
  add_subdirectory(test/lit)
  configure_file(scripts/binaryen-lit.in ${CMAKE_BINARY_DIR}/bin/binaryen-lit @ONLY)
endif()

if(BUILD_TESTS)
  # Configure GTest unit tests
  add_subdirectory(test/gtest)
endif()

# binaryen.js
#
# Note that we can't emit binaryen.js directly, as there is libbinaryen already
# declared earlier, so we create binaryen_wasm/js.js, which must then be copied.
if(EMSCRIPTEN)
  # binaryen.js WebAssembly variant
  add_executable(binaryen_wasm ${binaryen_SOURCES})
  target_link_libraries(binaryen_wasm PRIVATE binaryen-default)
  target_link_libraries(binaryen_wasm PRIVATE "-sFILESYSTEM")
  target_link_libraries(binaryen_wasm PRIVATE "-sEXPORT_NAME=Binaryen")
  target_link_libraries(binaryen_wasm PRIVATE "-sNODERAWFS=0")
  # Do not error on the repeated NODERAWFS argument
  target_link_libraries(binaryen_wasm PRIVATE "-Wno-unused-command-line-argument")
  # Emit a single file for convenience of people using binaryen.js as a library,
  # so they only need to distribute a single file.
  if(EMSCRIPTEN_ENABLE_SINGLE_FILE)
    target_link_libraries(binaryen_wasm PRIVATE "-sSINGLE_FILE")
  endif()
  target_link_libraries(binaryen_wasm PRIVATE "-sEXPORT_ES6")
  target_link_libraries(binaryen_wasm PRIVATE "-sEXPORTED_RUNTIME_METHODS=stringToUTF8OnStack,stringToAscii")
  target_link_libraries(binaryen_wasm PRIVATE "-sEXPORTED_FUNCTIONS=_malloc,_free")
  target_link_libraries(binaryen_wasm PRIVATE "--post-js=${CMAKE_CURRENT_SOURCE_DIR}/src/js/binaryen.js-post.js")
  target_link_libraries(binaryen_wasm PRIVATE "-msign-ext")
  target_link_libraries(binaryen_wasm PRIVATE "-mbulk-memory")
  target_link_libraries(binaryen_wasm PRIVATE optimized "--closure=1")
  # TODO: Fix closure warnings! (#5062)
  target_link_libraries(binaryen_wasm PRIVATE optimized "-Wno-error=closure")
  if (BYN_ENABLE_LTO)
    target_link_libraries(binaryen_wasm PRIVATE optimized "-flto")
  endif()
  target_link_libraries(binaryen_wasm PRIVATE debug "--profiling")
  # Avoid catching exit as that can confuse error reporting in Node,
  # see https://github.com/emscripten-core/emscripten/issues/17228
  target_link_libraries(binaryen_wasm PRIVATE "-sNODEJS_CATCH_EXIT=0")
  install(TARGETS binaryen_wasm DESTINATION ${CMAKE_INSTALL_BINDIR})

  # binaryen.js JavaScript variant
  add_executable(binaryen_js ${binaryen_SOURCES})
  target_link_libraries(binaryen_js PRIVATE binaryen-default)
  target_link_libraries(binaryen_js PRIVATE "-sWASM=0")
  target_link_libraries(binaryen_js PRIVATE "-sWASM_ASYNC_COMPILATION=0")

  if(${CMAKE_CXX_COMPILER_VERSION} STREQUAL "6.0.1")
    # only valid with fastcomp and WASM=0
    target_link_libraries(binaryen_js PRIVATE "-sELIMINATE_DUPLICATE_FUNCTIONS")
  endif()
  # Disabling filesystem and setting web environment for js_of_ocaml
  # so it doesn't try to detect the "node" environment
  if(JS_OF_OCAML)
    target_link_libraries(binaryen_js PRIVATE "-sFILESYSTEM=0")
    target_link_libraries(binaryen_js PRIVATE "-sENVIRONMENT=web,worker")
  else()
    target_link_libraries(binaryen_js PRIVATE "-sFILESYSTEM=1")
  endif()
  target_link_libraries(binaryen_js PRIVATE "-sNODERAWFS=0")
  # Do not error on the repeated NODERAWFS argument
  target_link_libraries(binaryen_js PRIVATE "-Wno-unused-command-line-argument")
  if(EMSCRIPTEN_ENABLE_SINGLE_FILE)
    target_link_libraries(binaryen_js PRIVATE "-sSINGLE_FILE")
  endif()
  target_link_libraries(binaryen_js PRIVATE "-sEXPORT_NAME=Binaryen")
  # Currently, js_of_ocaml can only process ES5 code
  if(JS_OF_OCAML)
    target_link_libraries(binaryen_js PRIVATE "-sEXPORT_ES6=0")
  else()
    target_link_libraries(binaryen_js PRIVATE "-sEXPORT_ES6=1")
  endif()
  target_link_libraries(binaryen_js PRIVATE "-sEXPORTED_RUNTIME_METHODS=stringToUTF8OnStack,stringToAscii")
  target_link_libraries(binaryen_js PRIVATE "-sEXPORTED_FUNCTIONS=_malloc,_free")
  target_link_libraries(binaryen_js PRIVATE "--post-js=${CMAKE_CURRENT_SOURCE_DIR}/src/js/binaryen.js-post.js")
  # js_of_ocaml needs a specified variable with special comment to provide the library to consumers
  if(JS_OF_OCAML)
    target_link_libraries(binaryen_js PRIVATE "--extern-pre-js=${CMAKE_CURRENT_SOURCE_DIR}/src/js/binaryen.jsoo-extern-pre.js")
  endif()
  target_link_libraries(binaryen_js PRIVATE optimized "--closure=1")
  # Currently, js_of_ocaml can only process ES5 code
  if(JS_OF_OCAML)
    target_link_libraries(binaryen_js PRIVATE optimized "--closure-args=\"--language_out=ECMASCRIPT5\"")
  endif()
  # TODO: Fix closure warnings! (#5062)
  target_link_libraries(binaryen_js PRIVATE optimized "-Wno-error=closure")
  if(BYN_ENABLE_LTO)
    target_link_libraries(binaryen_js PRIVATE optimized "-flto")
  endif()
  target_link_libraries(binaryen_js PRIVATE debug "--profiling")
  target_link_libraries(binaryen_js PRIVATE debug "-sASSERTIONS")
  # Avoid catching exit as that can confuse error reporting in Node,
  # see https://github.com/emscripten-core/emscripten/issues/17228
  target_link_libraries(binaryen_js PRIVATE "-sNODEJS_CATCH_EXIT=0")
  install(TARGETS binaryen_js DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
