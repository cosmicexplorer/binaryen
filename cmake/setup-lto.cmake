function(setup_gcc_lto)
  -flto -ffat-lto-objects        # for compilation of static libraries that can be LTOed
  # apparently -fno-fat-lto-objects will work if the linker plugin exists
  -flto-incremental=path         # lto cache here
  -flto-incremental-cache-size=n
  -flto-compression-level=0-19[zstd],0-9[zlib]

  -flto=auto -fuse-linker-plugin # for link time
endfunction()




# add_library(thin-lto INTERFACE)
# target_link_options(thin-lto INTERFACE -fuse-ld=lld)
# target_compile_options(thin-lto INTERFACE -flto=thin)
# set(THIN_LTO_LINK_JOBS 2 CACHE STRING
#   "Max number of parallel link jobs used for ThinLTO with Ninja.")
# set_property(GLOBAL APPEND PROPERTY JOB_POOLS lto_job_pool=2)

# set_target_properties(thin-lto PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
# set_target_properties(${name} PROPERTIES JOB_POOL_LINK thin_lto)

# if(BYN_ENABLE_LTO)
#   if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
#     message(FATAL_ERROR "ThinLTO is only supported by clang")
#   endif()
#   add_link_flag("-fuse-ld=lld")
#   set_property(GLOBAL APPEND PROPERTY JOB_POOLS link_job_pool=2)
#   set(CMAKE_JOB_POOL_LINK link_job_pool)
#   add_compile_flag("-flto=thin")
# endif()
