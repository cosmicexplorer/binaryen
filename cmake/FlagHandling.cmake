# For methods which accept a single argument and write their output into it as a variable name in
# the parent scope, cache their result into the provided name as an internal cache variable.
function(extract_upvar_method_call_into_cache_var cache_var method)
  cmake_language(CALL ${method} _upvar)
  set(${cache_var} ${_upvar} CACHE INTERNAL "")
  message(VERBOSE
    "cached the execution of idempotent upvar method ${method} into internal var ${cache_var}")
  message(DEBUG "value of ${cache_var} is now: '${${cache_var}}'")
endfunction()

function(setup_rpath_for_target name)
  if(CMAKE_INSTALL_RPATH)
    return()
  endif()

  if(APPLE)
    set(_install_rpath "@loader_path/../lib")
    # This sets INSTALL_NAME_DIR to @rpath:
    # https://cmake.org/cmake/help/latest/prop_tgt/MACOSX_RPATH.html#prop_tgt:MACOSX_RPATH
    set_target_properties(${name} PROPERTIES
                          MACOSX_RPATH TRUE)
  elseif(UNIX)
    set(_install_rpath "\$ORIGIN/../lib")
    if(${CMAKE_SYSTEM_NAME} MATCHES "(FreeBSD|DragonFly)")
      # This syntax expands to -Wl,-z,origin:
      # https://cmake.org/cmake/help/latest/command/target_link_options.html#handling-compiler-driver-differences
      target_link_options(${name} PRIVATE "LINKER:SHELL:-z origin")
    endif()
  else()
    return()
  endif()

  set_target_properties(${name} PROPERTIES
                        BUILD_WITH_INSTALL_RPATH ON
                        INSTALL_RPATH "${_install_rpath}")
endfunction()
