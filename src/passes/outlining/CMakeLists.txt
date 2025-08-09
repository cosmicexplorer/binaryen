FILE(GLOB outlining_HEADERS *.h)
set(outlining_SOURCES
  $<$<BOOL:${BUILD_LLVM_DWARF}>:hash-stringify-walker.cpp>
  Outlining.cpp
  ${outlining_HEADERS}
)
add_library(outlining OBJECT ${outlining_SOURCES})

target_link_libraries(outlining PUBLIC
  binaryen-base
  $<$<BOOL:${BUILD_LLVM_DWARF}>:iface_suffix-tree>
  $<$<BOOL:${BUILD_LLVM_DWARF}>:iface_llvm_dwarf>
)
# target_precompile_headers(outlining REUSE_FROM binaryen-base)

add_library(iface_outlining INTERFACE)
target_link_libraries(iface_outlining INTERFACE outlining $<TARGET_OBJECTS:outlining>)
