FILE(GLOB wasm_split_HEADERS *.h)
set(wasm_split_SOURCES
  wasm-split.cpp
  split-options.cpp
  instrumenter.cpp
  ${wasm_split_HEADERS}
)
add_executable(wasm-split ${wasm_split_SOURCES})

get_directory_property(exe_lib BINARYEN_DEFAULT_LIB)
set_property(TARGET ${exe_lib} APPEND PROPERTY BINARYEN_DEPENDENT_EXES
  wasm-split
)
