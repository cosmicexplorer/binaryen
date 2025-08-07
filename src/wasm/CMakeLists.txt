file(GLOB wasm_HEADERS ../*.h)
set(wasm_SOURCES
  literal.cpp
  parsing.cpp
  source-map.cpp
  wasm.cpp
  wasm-binary.cpp
  wasm-debug.cpp
  wasm-emscripten.cpp
  wasm-interpreter.cpp
  wasm-io.cpp
  wasm-ir-builder.cpp
  wasm-stack.cpp
  wasm-stack-opts.cpp
  wasm-type.cpp
  wasm-type-shape.cpp
  wasm-validator.cpp
  ${wasm_HEADERS}
)
add_library(wasm OBJECT ${wasm_SOURCES})

target_link_libraries(wasm PUBLIC
  binaryen-base
  llvm_dwarf
)
