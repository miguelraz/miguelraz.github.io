@def title = "Hitchhiker's guide to Julia Internals"

### Map
    - Building Julia + LLVM
    - Parser
    - GC
    - Subtyping and inference
    - JIT and method tables
    - Optimizations + LLVM IR
    - Inliner
    - Parallel task runtime
    - Core and boot strapping
    - C ABI
    - Base and stdlibs + Pkg.jl
    - Machine code (assembly)
    - Julia runtime
    - REPL
    


### Reading source files
- `clang -E foo.c` will let you look at what code look slike after macro expansion.
- Demo of a C function in `gc.c`

### Tools, tools, tools
- ripgrep/ack for scouring the codebase
- gdb + sysimg jeff trick
