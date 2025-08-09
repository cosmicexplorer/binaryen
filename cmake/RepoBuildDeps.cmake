include(GitInfo)
include(FlagHandling)

function(bootstrap_repo_dep package)
  if(${package}_FOUND)
    message(DEBUG "package ${package} already found, continuing")
  endif()
  message(STATUS "attempting to locate or bootstrap dependency '${package}'")
  find_package(${package} QUIET)

  if(NOT ${package}_FOUND)
    if(NOT ${PROJECT_NAME}_GIT_SUBMODULE_STATUS EQUAL 0)
      message(FATAL_ERROR "package '${package}' could not be found with find_package(), \
and we could not read git submodule status")
    else()
      if(NOT IS_READABLE "${PROJECT_SOURCE_DIR}/third_party/${package}/.git")
        message(STATUS "${package} package not found: attempting to initialize git submodules")
        execute_process(
          COMMAND ${GIT_EXECUTABLE} --git-dir=${PROJECT_SOURCE_DIR}/.git submodule update --init
          COMMAND_ERROR_IS_FATAL ANY
        )
      endif()
    endif()
  endif()
endfunction()

function(declare_default_option_if_submodules_available option_name doc)
  declare_negated_condition_option(
    "NOT ${PROJECT_NAME}_GIT_SUBMODULE_STATUS EQUAL 0"
    "${option_name}"
    "${doc}"
  )
endfunction()
