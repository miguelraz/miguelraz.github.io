@def title = "🚧 WIP 🚧 From Julia to LLVM C++ and C internals"

### Things I wish I'd known from the start:
- Julia's C++ is "comically unidiomatic", as said by Stefan Karpinski. Specifically, you do NOT have to worry about anything resembling
1. template metaprogramming
2. fancy containers
3. move semantics
4. gnarly object oriented shenanigans like inheritance and the like

### Greppin' around:
- To find a `struct` try: `grep "} jl_binding_t;"`.

We basically just call the C++ API with a few range based for loops and lambdas sprinkled here and there.
Let's show some examples.
- `clang` and `clangd` are NOT the same thing, nor are they bundled together. `clangd` is closer to `clippy` and it does not come preinstalled.
- `libstdc++` and `libc++` are the stdlibs pulled in by `gcc` and `clang`, respectively, make sure to update both of them before proceeding.
- If you want to compile a C++20 "Hello World like this one:
```cpp
import <iostream>
int main() {
    std::cout << "hello world" << std::endl;
}
```
- I found the `cpp reference` and `clangd` extensions for VSCode to be crucial in navigating C++.
You should pass in the flags `clang++ -std=c++20 test.cpp -o test`.
