@def title = "🚧 WIP 🚧 A most refined collection of Julia WATs "

This talk is inspired by the classic [Wat](https://www.destroyallsoftware.com/talks/wat) talk by Gary Bernhardt, applied to Julia.

Huge thanks to Mason Protter, most of these are his.

- and, or on empty collections
- broadcasting shenanigans: (Credit to Mosè Giordano)
```julia
julia> all([] .== [42])
true

julia> all([] .≈ [42])
true
``` 
- RNG seed set by `@testset`
- Operator precedene with ranges: (Credit to Oscar Smith)
```julia
julia> -5:5 .+ .5
-5.0:1.0:5.0

julia> (-5:5) .+ .5
-4.5:1.0:5.5
```
- 
- `var"N+1"` and other sneaky shenanigans like stealing the pipe operator with an even uglier syntax 
```julia
struct PseudoClass{T}
    data::T
end(o::PseudoClass)(f, args...; kwargs...) = f(o.data, args...; kwargs...)
var"'ᶜ" = PseudoClass
my_thing'ᶜ(stuff)'ᶜ(more_stuff, an_argument)'ᶜ(final_stuff; a_keyword_argument)
```

- `isequal` vs `egal` vs `==`

