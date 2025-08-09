file(GLOB analysis_HEADERS *.h lattices/*.h)
set(analysis_SOURCES
  cfg.cpp
  ${analysis_HEADERS}
)
add_library(analysis OBJECT ${analysis_SOURCES})
target_link_libraries(analysis PUBLIC binaryen-base)
# target_precompile_headers(analysis REUSE_FROM binaryen-base)

add_library(iface_analysis INTERFACE)
target_link_libraries(iface_analysis INTERFACE analysis $<TARGET_OBJECTS:analysis>)
