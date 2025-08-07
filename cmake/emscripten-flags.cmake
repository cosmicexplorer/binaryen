emscripten_cmake_internal_optimization_smoke_test_assertion()

add_link_options(
  "-sALLOW_MEMORY_GROWTH"
  "-sSTACK_SIZE=5MB"
)

if(ENABLE_BIGINT)
  add_link_options("-sWASM_BIGINT")
else()
  add_link_options("-sWASM_BIGINT=0")
endif()

if(EMSCRIPTEN_ENABLE_WASM_EH)
  add_compile_options("-fwasm-exceptions")
else()
  add_compile_options("-sDISABLE_EXCEPTION_CATCHING=0")
  add_link_options("-sDISABLE_EXCEPTION_CATCHING=0")
endif()

if(EMSCRIPTEN_ENABLE_PTHREADS)
  add_compile_options("-pthread")
  add_link_options(
    "-pthread"
    # Use mimalloc to avoid a 5x slowdown:
    # https://github.com/emscripten-core/emscripten/issues/15727#issuecomment-1960295018
    # (editor's note: this is quite unclear, but this flag appears to index into emscripten's *own*
    # mimalloc, regardless of whether the current build specifies BUILD_MIMALLOC)
    "-sMALLOC=mimalloc"
    # Disable the warning on pthreads+memory growth (we are not much affected by
    # it as there is little wasm-JS transfer of data, almost all work is inside
    # the wasm).
    "-Wno-pthreads-mem-growth"
  )
endif()

# In the browser, there is no natural place to provide commandline arguments
# for a commandline tool, so let the user run the main entry point themselves
# and pass in the arguments there.
if(BUILD_FOR_BROWSER)
  add_link_options(
    "-sENVIRONMENT=web,worker"
    "-sINVOKE_RUN=0"
    "-sEXPORTED_RUNTIME_METHODS=run,callMain,FS"
    "-sMODULARIZE"
    "-sEXPORT_ES6"
    "-sFILESYSTEM"
    "-sFORCE_FILESYSTEM"
  )
else()
  # On Node.js, make the tools immediately usable.
  add_link_options("-sNODERAWFS")
endif()

if(EMSCRIPTEN_ENABLE_WASM64)
  add_compile_options("-sMEMORY64" "-Wno-experimental")
  add_link_options("-sMEMORY64")
endif()

if(BYN_ENABLE_LTO)
  # in opt builds, LTO helps so much (>20%) it's worth slow compile times
  add_compile_options("$<$<CONFIG:RELEASE>:-flto>")
endif()
