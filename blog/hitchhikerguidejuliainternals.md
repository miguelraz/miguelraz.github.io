@def title = "🚧WIP🚧: Hitchhiker's guide to Julia Internals"

### Map
    - Building Julia + LLVM
    - Parser
    - GC
      https://www.cs.cornell.edu/courses/cs6120/2019fa/blog/unified-theory-gc/
    - Subtyping and inference
    - JIT and method tables
    - World age
    - Optimizations + LLVM IR
    - Inliner heuristics
    - Parallel task runtime
    - Core and boot strapping
    - C ABI
    - Base and stdlibs + Pkg.jl
    - Machine code (assembly)
    - Julia runtime
    - REPL
    - Broadcasting... ?
    
### Reading source files
- `clang -E foo.c` will let you look at what code look slike after macro expansion.
- Demo of a C function in `gc.c`

### Tools, tools, tools
- ripgrep/ack for scouring the codebase
- gdb + sysimg jeff trick
