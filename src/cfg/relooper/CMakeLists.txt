FILE(GLOB relooper_HEADERS *.h)
set(relooper_SOURCES
  Relooper.cpp
  ${relooper_HEADERS}
)
add_library(relooper OBJECT ${relooper_SOURCES})

target_link_libraries(relooper PUBLIC
  binaryen-base
  ir
  support
)
# target_precompile_headers(relooper REUSE_FROM binaryen-base)

add_library(iface_relooper INTERFACE)
target_link_libraries(iface_relooper INTERFACE relooper $<TARGET_OBJECTS:relooper>)
