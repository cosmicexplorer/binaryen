include(FlagHandling)

function(calculate_floating_point_math_flags)
  if(MSVC)
    if(MSVC_VERSION VERSION_LESS "19.0")
      # VS2013 and older explicitly need /arch:sse2 set, VS2015 no longer has that option, but
      # always enabled.
      list(APPEND flags "/arch:sse2")
    endif()
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^i.86$")
    # wasm doesn't allow for x87 floating point math
    list(APPEND flags "-msse2" "-mfpmath=sse")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^armv(.+)$")
    if(("${CMAKE_MATCH_1}" VERSION_LESS_EQUAL 6)
        AND ("${CMAKE_MATCH_1}" VERSION_GREATER_EQUAL 2))
      list(APPEND flags "-mfpu=vfpv3")
    else()
      message(WARNING
        "could not identify fpu optimization flags for ARM processor ${CMAKE_SYSTEM_PROCESSOR}")
    endif()
  endif()
  set("${ARGV0}" ${flags} PARENT_SCOPE)
endfunction()
extract_upvar_method_call_into_cache_var(BINARYEN_FP_MATH_FLAGS
  calculate_floating_point_math_flags)

function(calculate_msvc_cxx_compat_flags)
  # workaround for https://github.com/WebAssembly/binaryen/issues/3661
  list(APPEND flags "/D_SILENCE_CXX17_ITERATOR_BASE_CLASS_DEPRECATION_WARNING")
  # Visual Studio 2018 15.8 implemented conformant support for std::aligned_storage, but the conformant support is only enabled when the following flag is passed, to avoid
  # breaking backwards compatibility with code that relied on the non-conformant behavior (the old nonconformant behavior is not used with Binaryen)
  # (editor's note: std::aligned_storage is only consumed from third_party/llvm/include)
  list(APPEND flags "/D_ENABLE_EXTENDED_ALIGNED_STORAGE")
  # Don't warn about using "strdup" as a reserved name.
  list(APPEND flags "/D_CRT_NONSTDC_NO_DEPRECATE")
  set("${ARGV0}" ${flags} PARENT_SCOPE)
endfunction()
extract_upvar_method_call_into_cache_var(BINARYEN_MSVC_CXX_COMPAT_FLAGS
  calculate_msvc_cxx_compat_flags)

function(apply_msvc_binaryen_default_options)
  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # multi-core build (not available on clang)
    add_compile_options("/MP")
  endif()

  add_compile_options(
    "$<$<CONFIG:DEBUG>:/Od>"
    "$<$<CONFIG:RELEASE>:/O2>"
  )
  add_link_options("/STACK:8388608")

  # Compile with `/MT` in release configurations to link against `libcmt.lib`, removing a dependency
  # on `msvcrt.dll`. May result in slightly larger binaries but they should be more portable
  # across systems.
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:DebugDLL>")
endfunction()

function(patch_out_msvc_d_ndebug_flags)
  # Conditionally remove /D NDEBUG to avoid MSVC warnings about conflicting defines.
  if(CMAKE_BUILD_TYPE MATCHES "Debug")
    return()
  endif()
  # (editor's note: It's unclear where this comes from if not injected by msvc itself. It seems to
  # be referring to a conflict with the /UNDEBUG we inject elsewhere when assertions are enabled.)
  # (editor's note: This doesn't use generator expressions, but it's not quite clear how we'd do
  # that in the first place, and in any case it's likely for the specific case of the visual studio
  # project generator as opposed to the more general cases we're using generator expressions for.)
  foreach(flags_var_to_scrub
      CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_RELWITHDEBINFO
      CMAKE_CXX_FLAGS_MINSIZEREL
      CMAKE_C_FLAGS_RELEASE
      CMAKE_C_FLAGS_RELWITHDEBINFO
      CMAKE_C_FLAGS_MINSIZEREL)
    string(REGEX REPLACE "(^| )[/-]D *NDEBUG($| )" " "
      "${flags_var_to_scrub}" "${${flags_var_to_scrub}}")
  endforeach()
endfunction()

function(apply_msvc_binaryen_default_warnings)
  add_compile_options(
    # Ignore warning "warning C4146: unary minus operator applied to unsigned type, result still unsigned", this pattern is used somewhat commonly in the code.
    "/wd4146"
    # 4267 and 4244 are conversion/truncation warnings. We might want to fix these but they are currently pervasive.
    "/wd4267"
    "/wd4244"
    # 4722 warns that destructors never return, even with [[noreturn]].
    "/wd4722"
    # "destructor was implicitly defined as deleted" caused by LLVM headers.
    "/wd4624"
    "/WX-"
    "/D_CRT_SECURE_NO_WARNINGS"
    "/D_SCL_SECURE_NO_WARNINGS"
  )

  # This does not appear to exist or be defined anywhere; perhaps a default from visual studio?
  if(RUN_STATIC_ANALYZER)
    # There is no guarantee in the docs that a leading / is removed for add_compile_definitions():
    # https://cmake.org/cmake/help/latest/command/add_compile_definitions.html#command:add_compile_definitions
    add_definitions(/analyze)
  endif()
endfunction()

function(apply_win32_binaryen_default_options)
  add_compile_definitions("_GNU_SOURCE" "__STDC_FORMAT_MACROS")
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_link_options("-Wl,/stack:8388608")
  else()
    add_link_options("-Wl,--stack,8388608")
  endif()
endfunction()

function(apply_standard_binaryen_default_options)
  add_compile_options(
    "-fno-omit-frame-pointer"
    "$<$<CONFIG:DEBUG>:-g3>"
  )
endfunction()

function(apply_standard_binaryen_default_warnings)
  add_compile_options(
    "-Wall"
    "-Wextra"
    "-Wno-unused-parameter"
    # false positive in gcc
    # (editor's note: really?)
    "-Wno-dangling-pointer"
    # TODO(https://github.com/WebAssembly/binaryen/pull/2314): Remove these two
    # flags once we resolve the issue.
    "-Wno-implicit-int-float-conversion"
    "-Wno-unknown-warning-option"
    # we explicitly expect this in the code
    "-Wswitch"
    "-Wimplicit-fallthrough"
    "-Wnon-virtual-dtor"
  )
endfunction()

function(apply_standard_clang_binaryen_default_warnings)
  add_compile_options(
    # Google style requires this, so make sure we compile cleanly with it.
    "-Wctad-maybe-unsupported"
    # Disable a warning that started to happen on system headers (so we can't
    # fix it in our codebase) on github CI:
    # https://github.com/WebAssembly/binaryen/pull/6597
    "-Wno-deprecated-declarations"
  )
endfunction()

function(apply_unix_binaryen_default_options)
  # Print colored diagnostics from Ninja.
  if(CMAKE_GENERATOR STREQUAL "Ninja")
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      add_compile_options("-fdiagnostics-color=always")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      # clang doesn't always support colored diagnostics when invoked from Ninja.
      add_compile_options("-fcolor-diagnostics")
    endif()
  endif()
endfunction()

function(set_shared_library_only_flags)
  message(TRACE "set_shared_library_only_flags(${ARGV})")
  add_link_options("$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${ARGV}>")
endfunction()
