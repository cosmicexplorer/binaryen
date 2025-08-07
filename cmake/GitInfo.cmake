# We already require cmake >= 3.14, which is noted to have the Git::Git target from the git package:
# https://cmake.org/cmake/help/latest/module/FindGit.html.
find_package(Git QUIET REQUIRED)

function(extract_git_rev)
  cmake_parse_arguments(PARSE_ARGV 0 arg QUIET GIT_DIR "")
  if(arg_GIT_DIR)
    set(git_dir_args "--git-dir=${arg_GIT_DIR}")
  endif()
  if(arg_QUIET)
    set(err_args ERROR_QUIET)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ${git_dir_args} rev-parse HEAD
    RESULT_VARIABLE _git_result
    OUTPUT_VARIABLE GIT_REV
    ${err_args}
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_git_result)
    if(NOT arg_QUIET)
      message(WARNING "Unexpected error running git to get current rev for ${git_dir}")
    endif()
  else()
    set(GIT_REV "${GIT_REV}" PARENT_SCOPE)
  endif()
endfunction()

function(extract_git_version git_dir)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "GIT_DIR;MATCH_GLOB" "")
  if(arg_GIT_DIR)
    set(git_dir_args "--git-dir=${arg_GIT_DIR}")
  endif()
  if(arg_MATCH_GLOB)
    set(match_args --match "${arg_MATCH_GLOB}")
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ${git_dir_args} describe --tags ${match_args}
    RESULT_VARIABLE _git_result
    OUTPUT_VARIABLE GIT_VERSION
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT _git_result)
    set(GIT_VERSION ${GIT_VERSION} PARENT_SCOPE)
  endif()
endfunction()

function(git_version_suffix)
  set(args BASE_VERSION GIT_DIR TAG_GLOB OUTPUT_VAR)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "${args}" "")
  if(NOT arg_BASE_VERSION)
    set(arg_BASE_VERSION "${PROJECT_VERSION}")
  endif()
  if(NOT arg_GIT_DIR)
    set(arg_GIT_DIR "${PROJECT_SOURCE_DIR}/.git")
  endif()
  if(NOT arg_OUTPUT_VAR)
    message(FATAL_ERROR "must provide OUTPUT_VAR argument for git_version_suffix() (argv: ${ARGV})")
  endif()

  if(Git_FOUND AND IS_DIRECTORY "${arg_GIT_DIR}")
    extract_git_rev("${arg_GIT_DIR}")
    extract_git_version("${arg_GIT_DIR}" "${arg_TAG_GLOB}")
    if(GIT_VERSION)
      set("${arg_OUTPUT_VAR}" "${arg_BASE_VERSION} (${GIT_VERSION})" PARENT_SCOPE)
    elseif(GIT_REV)
      set("${arg_OUTPUT_VAR}" "${arg_BASE_VERSION} (${GIT_REV})" PARENT_SCOPE)
    else()
      set("${arg_OUTPUT_VAR}" "${arg_BASE_VERSION}" PARENT_SCOPE)
    endif()
  else()
    set("${arg_OUTPUT_VAR}" "${arg_BASE_VERSION}" PARENT_SCOPE)
  endif()
endfunction()
