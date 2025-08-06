FILE(GLOB support_fatal_HEADERS *.h)
set(support_fatal_SOURCES
  handle-unreachable.cpp
  ${support_fatal_HEADERS}
)

add_library(fatal OBJECT ${support_fatal_SOURCES})
