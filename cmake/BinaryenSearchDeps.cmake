# Configure threads library.
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Attempt to locate any dependencies with find_package() first to support downstream packagers
# building from a release tarball instead of the git repo.
if(BUILD_MIMALLOC)
  message(STATUS "Building with mimalloc allocator.")
  find_package(mimalloc QUIET)
endif()
if(BUILD_FUZZTEST)
  message(STATUS "Building with fuzztest testing.")
  find_package(fuzztest QUIET)
endif()
if(BUILD_TESTS)
  message(STATUS "Building with gtest testing.")
  find_package(googletest QUIET)
endif()

# Add targets and sources for 3P code, or error if they could not be found.
# For example, BUILD_TESTS requires a submodule to be initialized with `git submodule init`.
add_subdirectory(third_party)

# Use SYSTEM to avoid warnings and errors.
include_directories(SYSTEM ${CMAKE_CURRENT_SOURCE_DIR}/third_party/FP16/include)
