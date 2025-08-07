include(BinaryenSetupFlags)

# Provide any specialized fpu-specific operations.
if(NOT EMSCRIPTEN)
  add_compile_options(${BINARYEN_FP_MATH_FLAGS})
endif()

# Setup default dir-level flags.
if(MSVC)
  add_compile_options(${BINARYEN_MSVC_CXX_COMPAT_FLAGS})

  apply_msvc_binaryen_default_options()
  apply_msvc_binaryen_default_warnings()

else()

  apply_standard_binaryen_default_options()
  if(WIN32)
    apply_win32_binaryen_default_options()
  elseif(UNIX)
    apply_unix_binaryen_default_options()
  endif()

  apply_standard_binaryen_default_warnings()

  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    apply_standard_clang_binaryen_default_warnings()
  endif()

  if(NOT APPLE AND NOT CMAKE_CXX_FLAGS MATCHES "-fsanitize")
    set_shared_library_only_flags("LINKER:--no-undefined")
    # set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
  endif()
endif()
