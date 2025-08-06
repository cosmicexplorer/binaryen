FILE(GLOB compat_HEADERS *.h)
set(compat_SOURCES
  ${compat_HEADERS}
)

add_library(compat OBJECT ${compat_SOURCES})
