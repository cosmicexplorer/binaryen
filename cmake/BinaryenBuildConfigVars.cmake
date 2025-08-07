# We default to assertions enabled whenever we build executables, even in release builds so that we
# get more useful error reports from users.
option(BYN_ENABLE_ASSERTIONS "Enable assertions" ${BUILD_TOOLS})

option(BYN_ENABLE_LTO "Build with LTO" ${EMSCRIPTEN})
