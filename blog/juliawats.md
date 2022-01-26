@def title = "🚧 WIP 🚧 A most refined collection of Julia WATs "

This talk is inspired by the classic [Wat](https://www.destroyallsoftware.com/talks/wat) talk by Gary Bernhardt, applied to Julia.

Huge thanks to Mason Protter, most of these are his.

### Empty collections and truthiness
- and, or on empty collections

### Broadcasting
- broadcasting shenanigans: (Credit to Mosè Giordano)
```julia-repl
julia> all([] .== [42])
true

julia> all([] .≈ [42])
true
``` 

### RNG
- RNG seed set by `@testset`

### Parsing - it's hard!
- Operator precedene with ranges: (Credit to Oscar Smith)
```julia-repl
julia> -5:5 .+ .5
-5.0:1.0:5.0

julia> (-5:5) .+ .5
-4.5:1.0:5.5
```
- `var"N+1"` and other sneaky shenanigans like stealing the pipe operator with an even uglier syntax 
```julia-repl
struct PseudoClass{T}
    data::T
end(o::PseudoClass)(f, args...; kwargs...) = f(o.data, args...; kwargs...)
var"'ᶜ" = PseudoClass
my_thing'ᶜ(stuff)'ᶜ(more_stuff, an_argument)'ᶜ(final_stuff; a_keyword_argument)
```
- Courtesy of [Stefan Karpinski](https://github.com/miguelraz/miguelraz.github.io/issues/2#issuecomment-1022312868)
```julia-repl
julia> e = 9998.0
9998.0

julia> 2e
19996.0

julia> 2e+4
20000.0

julia> 2e+5
```

### Equality
- `isequal` vs `egal` vs `==`

### Numbers are iterable:
```julia-repl
julia> first(1,2)
1-element Vector{Int64}:
 1
```
Rationale: Partly explained in the docstring for `first`. Maybe a MATLAB-ism.
```julia-repl
julia> # Credit to Dheepak Krishnamurthy
julia> 1[1][1][1] == 1
true
```

