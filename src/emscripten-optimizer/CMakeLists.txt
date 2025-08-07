FILE(GLOB emscripten_optimizer_HEADERS *.h)
set(emscripten_optimizer_SOURCES
  optimizer-shared.cpp
  parser.cpp
  simple_ast.cpp
  ${emscripten_optimizer_HEADERS}
)
add_library(emscripten-optimizer OBJECT ${emscripten_optimizer_SOURCES})

target_link_libraries(emscripten-optimizer PUBLIC binaryen-base)

add_library(iface_emscripten-optimizer INTERFACE)
target_link_libraries(iface_emscripten-optimizer INTERFACE
  emscripten-optimizer $<TARGET_OBJECTS:emscripten-optimizer>)
