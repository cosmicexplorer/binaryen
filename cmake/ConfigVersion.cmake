include(GitInfo)

function(define_version_tag_glob)
  if(ARGC GREATER 0 AND ARGV0)
    set(default_glob "${ARGV0}")
  endif()
  set("${PROJECT_NAME}_VERSION_TAG_GLOB" ${default_glob} CACHE STRING
    "A glob pattern matching tags for the current git repo, if available. \
If a visible tag matches this glob, the tag name will be used instead of the full revision hash. \
This is used in the default setting for ${PROJECT_NAME}_SOURCE_TAGGED_VERSION.")
endfunction()

function(define_source_tagged_version)
  git_version_suffix(
    TAG_GLOB "${${PROJECT_NAME}_VERSION_TAG_GLOB}"
    OUTPUT_VAR default_source_tag)
  set("${PROJECT_NAME}_SOURCE_TAGGED_VERSION" ${default_source_tag} CACHE STRING
    "A version string corresponding to builds from source. \
This should incorporate the PROJECT_VERSION.")
endfunction()

function(declare_source_tagged_version)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "TAG_GLOB" "")
  define_version_tag_glob("${arg_TAG_GLOB}")
  define_source_tagged_version()
endfunction()
