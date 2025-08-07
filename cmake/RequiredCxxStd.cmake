function(declare_required_cxx_standard)
  if(ARGC GREATER 0 AND ARGV0)
    set(standard_file "${ARGV0}")
  else()
    set(standard_file "${PROJECT_SOURCE_DIR}/cxx-standard.txt")
  endif()
  file(READ "${standard_file}" required_cxx_standard)
  string(STRIP "${required_cxx_standard}" required_cxx_standard)

  set("${PROJECT_NAME}_REQUIRED_CXX_STANDARD" "${required_cxx_standard}" CACHE STRING
    "Required minimum C++ standard for the current project. \
Use with cxx_std_\${${PROJECT_NAME}_REQUIRED_CXX_STANDARD}. \
This default is set from the file '${standard_file}'.")
endfunction()
