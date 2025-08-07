FILE(GLOB asmjs_HEADERS *.h)
set(asmjs_SOURCES
  asm_v_wasm.cpp
  asmangle.cpp
  shared-constants.cpp
  ${asmjs_HEADERS}
)
add_library(asmjs OBJECT ${asmjs_SOURCES})
target_link_libraries(asmjs PUBLIC binaryen-base)

add_library(iface_asmjs INTERFACE)
target_link_libraries(iface_asmjs INTERFACE asmjs $<TARGET_OBJECTS:asmjs>)
