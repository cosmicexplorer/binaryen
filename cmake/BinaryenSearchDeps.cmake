include(RepoBuildDeps)

# Configure threads library.
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Attempt to locate any dependencies with find_package() first to support downstream packagers
# building from a release tarball instead of the git repo.
if(BUILD_MIMALLOC)
  message(STATUS "Building with mimalloc allocator.")
  bootstrap_repo_dep(mimalloc)
endif()
if(BUILD_FUZZTEST)
  message(STATUS "Building with fuzztest testing.")
  bootstrap_repo_dep(fuzztest)
endif()
if(BUILD_TESTS)
  message(STATUS "Building with gtest testing.")
  bootstrap_repo_dep(googletest)
endif()

# Add targets and sources for 3P code.
add_subdirectory(third_party)

# Use SYSTEM to avoid warnings and errors.
include_directories(SYSTEM ${CMAKE_CURRENT_SOURCE_DIR}/third_party/FP16/include)
