FILE(GLOB emscripten_optimizer_HEADERS *.h)
set(emscripten-optimizer_SOURCES
  optimizer-shared.cpp
  parser.cpp
  simple_ast.cpp
  ${emscripten_optimizer_HEADERS}
)
add_library(emscripten-optimizer OBJECT ${emscripten_optimizer_SOURCES})
