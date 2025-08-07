include_directories(fuzzing)
FILE(GLOB fuzzing_HEADERS fuzzing/*.h)
set(fuzzing_SOURCES
  fuzzing/fuzzing.cpp
  fuzzing/heap-types.cpp
  fuzzing/parameters.cpp
  fuzzing/random.cpp
  ${fuzzing_HEADERS}
)

add_executable(wasm-opt ${fuzzing_SOURCES} wasm-opt.cpp)
add_executable(wasm-metadce wasm-metadce.cpp)
add_executable(wasm2js wasm2js.cpp)
add_executable(wasm-emscripten-finalize wasm-emscripten-finalize.cpp)
add_executable(wasm-as wasm-as.cpp)
add_executable(wasm-dis wasm-dis.cpp)
add_executable(wasm-ctor-eval wasm-ctor-eval.cpp)

get_directory_property(exe_lib BINARYEN_DEFAULT_LIB)
set_property(TARGET ${exe_lib} APPEND PROPERTY BINARYEN_DEPENDENT_EXES
  wasm-opt wasm-metadce wasm2js wasm-emscripten-finalize wasm-as wasm-dis wasm-ctor-eval
)

if(NOT BUILD_EMSCRIPTEN_TOOLS_ONLY)
  add_executable(wasm-shell wasm-shell.cpp)
  add_executable(wasm-reduce wasm-reduce.cpp)
  add_executable(wasm-merge wasm-merge.cpp)
  add_executable(wasm-fuzz-types ${fuzzing_SOURCES} wasm-fuzz-types.cpp)
  add_executable(wasm-fuzz-lattices ${fuzzing_SOURCES} wasm-fuzz-lattices.cpp)

  set_property(TARGET ${exe_lib} APPEND PROPERTY BINARYEN_DEPENDENT_EXES
    wasm-shell wasm-reduce wasm-merge wasm-fuzz-types wasm-fuzz-lattices
  )
endif()

add_subdirectory(wasm-split)
