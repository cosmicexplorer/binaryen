file(READ wasm-intrinsics.wat WASM_INTRINSICS_WAT HEX)
set(CMAKE_CONFIGURE_DEPENDS wasm-intrinsics.wat)

string(REGEX MATCHALL "([A-Fa-f0-9][A-Fa-f0-9])" SEPARATED_HEX ${WASM_INTRINSICS_WAT})

foreach (hex IN LISTS SEPARATED_HEX)
  string(APPEND WASM_INTRINSICS_EMBED "0x${hex},")
endforeach ()
string(APPEND WASM_INTRINSICS_EMBED "0x00")

configure_file(WasmIntrinsics.cpp.in WasmIntrinsics.cpp @ONLY)

add_library(gen-intrinsics OBJECT WasmIntrinsics.cpp)
# Because the templated file begins by accessing a header file in what happens to be the parent
# directory of this one.
target_link_libraries(gen-intrinsics PRIVATE propagate-include-root-from-here)

add_library(iface_gen-intrinsics INTERFACE)
target_link_libraries(iface_gen-intrinsics INTERFACE
  gen-intrinsics $<TARGET_OBJECTS:gen-intrinsics>)
