FILE(GLOB support_global_HEADERS *.h)
set(support_global_SOURCES
  # parts of archive.cpp too, sigh
  colors.cpp
  command-line.cpp
  debug.cpp
  file.cpp
  # the interning should probably be done in a slightly better way than global state
  # istring.cpp
  path.cpp
  ${support_global_HEADERS}
)

add_library(global OBJECT ${support_global_SOURCES})

# Declare _SOURCE_TAGGED_VERSION cache var with a tag from the git info.
include(ConfigVersion)
declare_source_tagged_version(TAG_GLOB version_*)

file(WRITE config.h.in "\
#cmakedefine PROJECT_VERSION \"@binaryen_SOURCE_TAGGED_VERSION@\"")
configure_file(config.h.in binaryen-global-config.h @ONLY)

# Add output directory to include path so config.h can be found
target_include_directories(global PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
