@def title = "🚧WIP🚧: Julia REPL Tips and Tricks"
@def tags = ["REPL"]


#### Cool packages that we all should know about

\toc

- TerminalMenus.jl in base
- VideosInTerminal.jl + ImagesInTerminal.jl like Jesse Betancourt's 
- Obvi DoctorDoctrings
- InteractiveErrors.jl
- AbbreviatedStackTraces.jl
- pkg prompt with temp directory
- TerminalPager.jl for DataFrames.jl stuff

- `] add Foo; undo`!
- Latex shortcuts via [Keno ](https://twitter.com/KenoFischer/status/1402828171213479936)

- Jacob Quinn: ?foo gives you help, but ??foo gives you the stuff under "# Extended help"
https://julialang.slack.com/archives/C6FGJ8REC/p1623860727294500

- `LLVM_JULIA_ARGS=-time-passes ./julia -e 'using Plots; plot(1:10)'`
- switch repl modes via menu https://github.com/JuliaLang/julia/pull/33875
- fzf reverse search
- https://github.com/JuliaLang/julia/pull/38791


- Reverse latex/emoji lookup with `?\partial`
