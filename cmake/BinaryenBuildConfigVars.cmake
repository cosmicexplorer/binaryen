# We default to assertions enabled, even in release builds so that we get
# more useful error reports from users.
option(BYN_ENABLE_ASSERTIONS "Enable assertions" ON)

option(BYN_ENABLE_LTO "Build with LTO" ${EMSCRIPTEN})
