@def title = "🚧 WIP 🚧 Julia REPL Tips and Tricks"
@def tags = ["REPL"]


#### Cool packages that we all should know about

\toc


### Template for a *possible future workshop*

This workshop will be a jam-packed, hands-on tour of the Julia REPL so that beginners and experts alike can learn a few tips and tricks.
Every Julia user spends a significant amount of coding time interacting with the REPL -
my claim for this workshop is that all Julia users can save themselves more than 3
hours of productive coding time over their careers should they attend this workshop, so why not invest in yourself now?

##### Plan (pending review) for the material that will be covered:
* Navigation 
  - moving around,
  - basic commands,
  - variables,
  - shortcuts and keyboard combinations,
  - cross language comparison of REPL features,
  - Vim Mode **project**
* Internals and configuration 
  - Basic APIs,
  - display control codes,
  - terminals and font support,
  - startup file options, prompt changing,
  - flag configurations
* REPL Modes 
  - Shell mode,
  - Pkg mode,
  - help mode,
  - workflow demos for contributing code fixes,
  - REPLMaker.jl BuildYourOwnMode demo,
##### Tools and packages 
  - OhMyREPL.jl, 
  - PkgTemplates.jl, 
  - Eyeball.jl, 
  - TerminalPager.jl, 
  - AbstractTrees.jl,
  - Debugger.jl,
  - UnicodePlots.jl,
  - ProgressMeters.jl,
  - PlutoREPL.jl (???) **project**
  - Term.jl


### Miscelanea
- TerminalMenus.jl in base
- VideosInTerminal.jl + ImagesInTerminal.jl like Jesse Betancourt's 
- DoctorDoctrings.jl and hijacking REPL history
- InteractiveErrors.jl
- AbbreviatedStackTraces.jl
- pkg prompt with temp directory
- TerminalPager.jl for DataFrames.jl stuff

- `] add Foo; undo`!
- Latex shortcuts via [Keno](https://twitter.com/KenoFischer/status/1402828171213479936)

- Jacob Quinn: ?foo gives you help, but ??foo gives you the stuff under "# Extended help"
https://julialang.slack.com/archives/C6FGJ8REC/p1623860727294500

- `LLVM_JULIA_ARGS=-time-passes ./julia -e 'using Plots; plot(1:10)'`
- switch repl modes via menu https://github.com/JuliaLang/julia/pull/33875
- fzf reverse search
- https://github.com/JuliaLang/julia/pull/38791

- Reverse latex/emoji lookup with `?\partial`

- Stack traces with `CTRL+Q`, but also `methods(foo) + 1 + CTRL+Q`.

- Change your prompt:
```julia-repl
julia> Base.active_repl.interface.modes[1].prompt = "julia 😷>"
```

- `] activate @juliaimages`
