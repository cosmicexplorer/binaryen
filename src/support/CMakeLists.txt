FILE(GLOB support_HEADERS *.h)
set(support_SOURCES
  archive.cpp
  bits.cpp
  dfa_minimization.cpp
  intervals.cpp
  istring.cpp
  json.cpp
  name.cpp
  safe_integer.cpp
  string.cpp
  threads.cpp
  ${support_HEADERS}
)

# The below condition is intended for removal once the suffix_tree and
# suffix_tree_node source files no longer depend on LLVM code in the
# third_party folder
if(EMSCRIPTEN)
  add_library(support OBJECT ${support_SOURCES})
else()
  set(support_with_suffix_tree_SOURCES
    suffix_tree.cpp
    suffix_tree_node.cpp
    ${support_SOURCES}
  )
  add_library(support OBJECT ${support_with_suffix_tree_SOURCES})
endif()

target_link_libraries(support PUBLIC
  binaryen-base
  iface_llvm_dwarf
)

add_subdirectory(fatal)
add_subdirectory(global)

add_library(iface_support INTERFACE)
target_link_libraries(iface_support INTERFACE support $<TARGET_OBJECTS:support>)
