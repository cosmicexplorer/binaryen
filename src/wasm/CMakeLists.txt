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
)
add_library(wasm OBJECT ${wasm_SOURCES})
target_link_libraries(wasm PUBLIC
  binaryen-base
  llvm_dwarf
)

# Create an interface target which forwards all transitive objects:
# https://cmake.org/cmake/help/latest/command/target_link_libraries.html#id11

add_library(iface_wasm INTERFACE)
target_link_libraries(iface_wasm INTERFACE wasm $<TARGET_OBJECTS:wasm>)
