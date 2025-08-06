FILE(GLOB cfg_HEADERS *.h)
set(cfg_SOURCES
  ${cfg_HEADERS}
)
add_library(cfg OBJECT ${cfg_SOURCES})

add_subdirectory(relooper)
