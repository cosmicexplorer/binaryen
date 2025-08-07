include(RepoBuildDeps)

declare_default_option_if_submodules_available(BUILD_TESTS
  "Build GTest-based tests. Turn this off to avoid the dependency on gtest.")

option(BUILD_LIT_TESTS "Build lit tests" OFF)

declare_default_option_if_submodules_available(BUILD_FUZZTEST
  "Build fuzztest-based tests and fuzzers")
