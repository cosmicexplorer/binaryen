file(GLOB binaryen_base_HEADERS *.h *.def)
add_library(binaryen-base OBJECT ${binaryen_base_HEADERS})
target_link_libraries(binaryen-base PUBLIC binaryen-library-requirements)
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
  FILE_SET HEADERS FILES ${binaryen_c_HEADERS} wasm-delegations.def
)

target_link_libraries(binaryen-c PUBLIC binaryen-base)
target_link_libraries(binaryen-c PUBLIC relooper)
