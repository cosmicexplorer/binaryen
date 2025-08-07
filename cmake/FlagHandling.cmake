# For methods which accept a single argument and write their output into it as a variable name in
# the parent scope, cache their result into the provided name as an internal cache variable.
function(extract_upvar_method_call_into_cache_var cache_var method)
  if(NOT ARGC GREATER_EQUAL 2)
    message(FATAL_ERROR
      "require at least 2 args to extract_upvar_method_call_into_cache_var(): got ${ARGV}")
  endif()
  if(ARGC GREATER 2)
    cmake_language(CALL "${ARGV1}")
    set("${ARGV0}" ${${ARGV2}} CACHE INTERNAL "")
  else()
    cmake_language(CALL "${ARGV1}" _upvar)
    set("${ARGV0}" ${_upvar} CACHE INTERNAL "")
  endif()
  message(VERBOSE
    "cached the execution of idempotent upvar method ${ARGV1} into internal var ${ARGV0}")
  message(DEBUG "value of ${ARGV0} is now: '${${ARGV0}}'")
endfunction()

function(declare_negated_condition_option)
  if(NOT ARGC EQUAL 3)
    message(FATAL_ERROR "need exactly 3 args to declare_negated_condition_option(): got '${ARGV}'")
  endif()
  if(${ARGV0})
    set(_default OFF)
  else()
    set(_default ON)
  endif()
  option("${ARGV1}" "${ARGV2}" "${_default}")
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
