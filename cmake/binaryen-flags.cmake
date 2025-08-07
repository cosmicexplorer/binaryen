if(MSVC)
  if(BYN_ENABLE_ASSERTIONS)
    # On non-Debug builds cmake automatically defines NDEBUG, so we
    # explicitly undefine it:
    add_compile_options("$<$<CONFIG:RELEASE>:/UNDEBUG>") # Keep asserts.
    patch_out_msvc_d_ndebug_flags()
  endif()

else()

  if(BUILD_FUZZTEST)
    add_compile_definitions("FUZZTEST")
    fuzztest_setup_fuzzing_flags()
    # Enabling fuzzing mode turns on sanitizers, which turn on additional
    # warnings. To keep the build working, do not treat these warnings as
    # errors.
    add_compile_options(
      "-Wno-error=maybe-uninitialized"
      "-Wno-error=uninitialized"
      "-Wno-error=array-bounds"
      "-Wno-error=stringop-overread"
      "-Wno-error=missing-field-initializers"
    )
  else()
    # fuzztest depends on RTTIs.
    add_compile_options("-fno-rtti")
  endif()

  # NB: -fsanitize is specifically coming from the above fuzztest setup.
  if(NOT APPLE AND NOT CMAKE_CXX_FLAGS MATCHES "-fsanitize")
    set_shared_library_only_flags("LINKER:--no-undefined")
  endif()

  if(BYN_ENABLE_ASSERTIONS)
    # On non-Debug builds cmake automatically defines NDEBUG, so we
    # explicitly undefine it:
    add_compile_options("$<$<CONFIG:RELEASE>:-UNDEBUG>")
  endif()
endif()

if(BUILD_LLVM_DWARF)
  add_compile_definitions(BUILD_LLVM_DWARF)
endif()
