include(JoinPaths)
include(GNUInstallDirs)

join_paths(by_pc_includedir "\${prefix}" ${CMAKE_INSTALL_INCLUDEDIR})
join_paths(by_pc_libdir "\${prefix}" ${CMAKE_INSTALL_LIBDIR})

set(${PROJECT_NAME}_PKG_CONFIG_OUTPUT  ${PROJECT_SOURCE_DIR}/cmake/${PROJECT_NAME}.pc
  CACHE INTERNAL "")

# This may be empty--it's the necessary flags to use threading. gtest has a good example of this.
set(by_pc_libraries "${CMAKE_THREAD_LIBS_INIT}")
if(BUILD_MIMALLOC)
  # mimalloc also produces a pkg-config output file when built with cmake.
  set(by_pc_requires "mimalloc >= 2")
endif()
configure_file(${${PROJECT_NAME}_PKG_CONFIG_OUTPUT}.in ${${PROJECT_NAME}_PKG_CONFIG_OUTPUT} @ONLY)

message(STATUS "wrote pkg-config output for ${PROJECT_NAME} to ${${PROJECT_NAME}_PKG_CONFIG_OUTPUT}")
