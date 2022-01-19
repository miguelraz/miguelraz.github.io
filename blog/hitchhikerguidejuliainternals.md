@def title = "🚧WIP🚧: Hitchhiker's guide to Julia Internals"
# The monster at the bottom of Julia's internals

[Monster at the end of this book](https://www.youtube.com/watch?v=r3947-T_hHw).

### Map

    - [This tool to see](https://discourse.julialang.org/t/this-tool-for-understanding-repos-is-brilliant/67226/5)
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
    - Julia runtime
    - REPL
    - Broadcasting... ?
    - Machine code (assembly)
    
### Reading source files
- `clang -E foo.c` will let you look at what code look slike after macro expansion.
- Demo of a C function in `gc.c`

### Tools, tools, tools
- ripgrep/ack for scouring the codebase
- gdb + sysimg jeff trick

