/*
 * Copyright 2025 WebAssembly Community Group participants
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

#ifndef wasm_support_fatal_fatal_h
#define wasm_support_fatal_fatal_h

#ifdef THROW_ON_FATAL
#include <stdexcept>
#else
#include <cstdlib>
#include <iostream>
#endif

#include <sstream>

namespace wasm {
// For fatal errors which could arise from input (i.e. not assertion failures)
class Fatal {
private:
  std::stringstream buffer;

public:
  Fatal() { buffer << "Fatal: "; }
  template<typename T> Fatal& operator<<(T&& arg) {
    buffer << arg;
    return *this;
  }
#ifndef THROW_ON_FATAL
  [[noreturn]] ~Fatal() {
    std::cerr << buffer.str() << std::endl;
    // Use _Exit here to avoid calling static destructors. This avoids deadlocks
    // in (for example) the thread worker pool, where workers hold a lock while
    // performing their work.
    _Exit(EXIT_FAILURE);
  }
#else
  // This variation is a best-effort attempt to make fatal errors recoverable
  // for embedders of Binaryen as a library, namely wasm-opt-rs.
  //
  // Throwing in destructors is strongly discouraged, since it is easy to
  // accidentally throw during unwinding, which will trigger an abort. Since
  // `Fatal` is a special type that only occurs on error paths, we are hoping it
  // is never constructed during unwinding or while destructing another type.
  [[noreturn]] ~Fatal() noexcept(false) {
    throw std::runtime_error(buffer.str());
  }
#endif
};
} // namespace wasm

#endif // wasm_support_fatal_fatal_h
