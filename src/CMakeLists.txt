# Define a wrapper for all the common header files in the root used everywhere.
file(GLOB binaryen_base_HEADERS *.h)
add_library(binaryen-base OBJECT
  ${binaryen_base_HEADERS}
)
# Need to add these .def files which are used like headers in order to track invalidation, but which
# add_library() errors out with when used as the initial sources argument.
file(GLOB binaryen_base_DEFS *.def)
# Adding these as headers avoids trying to compile against them (setting HEADER_FILE_ONLY).
target_sources(binaryen-base PRIVATE
  FILE_SET HEADERS FILES ${binaryen_base_DEFS}
)
target_link_libraries(binaryen-base PUBLIC
  binaryen-library-requirements
  compat
)
target_include_directories(binaryen-base PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

add_subdirectory(analysis)
add_subdirectory(asmjs)
add_subdirectory(cfg)
add_subdirectory(compat)
add_subdirectory(emscripten-optimizer)
add_subdirectory(interpreter)
add_subdirectory(ir)
add_subdirectory(parser)
add_subdirectory(passes)
add_subdirectory(support)
add_subdirectory(wasm)

if(BUILD_TOOLS)
  # Build binaryen tools
  add_subdirectory(tools)
endif()

set(binaryen_c_HEADERS binaryen-c.h)
add_library(binaryen-c OBJECT binaryen-c.cpp)
target_sources(binaryen-c PUBLIC
  FILE_SET HEADERS FILES ${binaryen_c_HEADERS}
  FILE_SET delegations TYPE HEADERS FILES wasm-delegations.def
)

target_link_libraries(binaryen-c PUBLIC
  binaryen-base
  iface_analysis
  iface_asmjs
  iface_emscripten-optimizer
  iface_relooper
  iface_passes
  iface_wasm
  iface_fatal
  iface_global
  iface_support
  iface_parser
  iface_llvm_dwarf
  iface_ir
)
