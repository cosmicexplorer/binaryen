FILE(GLOB relooper_HEADERS *.h)
set(relooper_SOURCES
  Relooper.cpp
  ${relooper_HEADERS}
)
add_library(relooper OBJECT ${relooper_SOURCES})
