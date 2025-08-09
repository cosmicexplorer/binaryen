FILE(GLOB suffix_tree_HEADERS *.h)
set(suffix_tree_SOURCES
  suffix_tree_node.cpp
  suffix_tree.cpp
  ${suffix_tree_HEADERS}
)
add_library(suffix-tree OBJECT ${suffix_tree_SOURCES})

target_link_libraries(suffix-tree PUBLIC
  propagate-include-root-from-here
  iface_llvm_dwarf
)

add_library(iface_suffix-tree INTERFACE)
target_link_libraries(iface_suffix-tree INTERFACE suffix-tree $<TARGET_OBJECTS:suffix-tree>)
