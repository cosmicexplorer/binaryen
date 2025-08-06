/*
 * Copyright 2016 WebAssembly Community Group participants
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef wasm_support_fatal_unreachable_h
#define wasm_support_fatal_unreachable_h

#include "compiler-support.h"

namespace wasm {

[[noreturn]] void handle_unreachable(const char* msg = nullptr,
                                     const char* file = nullptr,
                                     unsigned line = 0);

// If control flow reaches the point of the WASM_UNREACHABLE(), the program is
// undefined.
#ifndef NDEBUG
#define WASM_UNREACHABLE(msg) wasm::handle_unreachable(msg, __FILE__, __LINE__)
#elif defined(WASM_BUILTIN_UNREACHABLE)
#define WASM_UNREACHABLE(msg) WASM_BUILTIN_UNREACHABLE
#else
#define WASM_UNREACHABLE(msg) wasm::handle_unreachable()
#endif

} // namespace wasm

#endif // wasm_support_fatal_unreachable_h
