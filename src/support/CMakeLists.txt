# The below condition is intended for removal once the suffix_tree and
# suffix_tree_node source files no longer depend on LLVM code in the
# third_party folder
if(BUILD_LLVM_DWARF)
  add_subdirectory(suffix-tree)
endif()

# An attempt to sequester the handling of fatal errors into a more modular form.
# FIXME: library users should be able to robustly recover from a fatal error without immediately
#        exiting the process!
add_subdirectory(fatal)

# Various interactions with global state that can be separated from the less stateful compilation
# logic.
# FIXME:
# (1) use generic ostreams everywhere possible instead of file handles and ttys
# (2) and make all filesystem interactions go through a virtualization layer that can be mocked out
#     and specialized to different performance scenarios.
# (3) string interning is still in the current "support" directory--this should be equally able to
#     intern values into heap memory instead of using a single static variable across the
#     whole process. perhaps this can be feature-gated like we do for ~Fatal()?
add_subdirectory(global)

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
add_library(support OBJECT ${support_SOURCES})

target_link_libraries(support PUBLIC
  binaryen-base
)
# target_precompile_headers(support REUSE_FROM binaryen-base)

add_library(iface_support INTERFACE)
target_link_libraries(iface_support INTERFACE support $<TARGET_OBJECTS:support>)
