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
target_link_libraries(wasm-opt PRIVATE
  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

add_executable(wasm-metadce wasm-metadce.cpp)
target_link_libraries(wasm-metadce PRIVATE
  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

# Note: the current build assumes all binaries are built without linking in the library. Because we
# do that, this is the single executable which doesn't link in the library, and the single one we
# address distinctly by name before the install(EXPORT) call.
add_executable(wasm2js wasm2js.cpp)
target_link_libraries(wasm2js PRIVATE
  binaryen-base

  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

add_executable(wasm-emscripten-finalize wasm-emscripten-finalize.cpp)
target_link_libraries(wasm-emscripten-finalize PRIVATE
  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

add_executable(wasm-as wasm-as.cpp)
target_link_libraries(wasm-as PRIVATE
  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

add_executable(wasm-dis wasm-dis.cpp)
target_link_libraries(wasm-dis PRIVATE
  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

add_executable(wasm-ctor-eval wasm-ctor-eval.cpp)
target_link_libraries(wasm-ctor-eval PRIVATE
  analysis
  asmjs
  emscripten-optimizer
  fatal
  global
  ir
  parser
  passes
  relooper
  support
  wasm
)

get_directory_property(exe_lib BINARYEN_DEFAULT_LIB)
set_property(TARGET ${exe_lib} APPEND PROPERTY BINARYEN_DEPENDENT_EXES
  wasm-opt wasm-metadce wasm-emscripten-finalize wasm-as wasm-dis wasm-ctor-eval
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
