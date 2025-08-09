# Define a wrapper for all the common header files in the root used everywhere.
file(GLOB binaryen_base_HEADERS *.h)
list(REMOVE_ITEM binaryen_base_HEADERS binaryen-c.h)
add_library(binaryen-base OBJECT
  ${binaryen_base_HEADERS}
)
# target_precompile_headers(binaryen-base
#   PRIVATE ${binaryen_base_HEADERS}
# )

# Need to add these .def files which are used like headers in order to track invalidation, but which
# add_library() errors out with when used as the initial sources argument.
file(GLOB binaryen_base_DEFS *.def)
# Adding these as headers avoids trying to compile against them (setting HEADER_FILE_ONLY).
target_sources(binaryen-base PRIVATE
  FILE_SET HEADERS FILES ${binaryen_base_DEFS}
)

add_library(propagate-include-root-from-here INTERFACE)
target_link_libraries(propagate-include-root-from-here INTERFACE
  binaryen-library-requirements
)
target_include_directories(propagate-include-root-from-here INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

target_link_libraries(binaryen-base PUBLIC propagate-include-root-from-here)

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
