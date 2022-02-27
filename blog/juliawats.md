@def title = "🚧 WIP 🚧 A most refined collection of Julia WATs "

This talk is inspired by the classic [Wat](https://www.destroyallsoftware.com/talks/wat) talk by Gary Bernhardt, applied to Julia.

Huge thanks to Mason Protter, most of these are his.

### Empty collections and truthiness
- and, or on empty collections

### Broadcasting is hard
- broadcasting shenanigans: (Credit to Mosè Giordano)
```julia-repl
julia> all([] .== [42])
true

julia> all([] .≈ [42])
true
``` 

### RNG
- RNG seed set by `@testset`

### Parsing is hard
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

- Shadowing: Courtesy of [Kristoffer Carlsson](https://github.com/JuliaLang/julia/issues/15483)
```julia-repl
julia> git_tree-sha1 = "8eb7b4d4ca487caade9ba3e85932e28ce6d6e1f8";

julia> 1-2
"8eb7b4d4ca487caade9ba3e85932e28ce6d6e1f8"
```
And another example:
```julia-repl
julia> function f(x)
           my_cool-variable=3
           if x > 5
               return my_cool_variable
           else
               return 3 - 1
           end
       end
f (generic function with 1 method)

julia> f(2)
3

julia> 3-1
2
```

- Symbols and numbers: Courtesy of `Mosè Giordano`:
```julia-repl
julia> :a === "a"
false

julia> :2 === 2
true
```
As a corollary, a Pythonista stumper:
```julia-repl
julia> arr1 = reshape(1.0:4.0, 2, 2)
2×2 reshape(::StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}, Int64}, 2, 2) with eltype Float64:
 1.0  3.0
 2.0  4.0

julia> arr2 = zeros(2, 2)
2×2 Matrix{Float64}:
 0.0  0.0
 0.0  0.0

julia> arr2 .= arr1[:, :2]
2×2 Matrix{Float64}:
 3.0  3.0
 4.0  4.0
```
because `:2` is not the same as `1:2`
```julia-repl
julia> arr2 .= arr1[:, 1:2]
2×2 Matrix{Float64}:
 1.0  3.0
 2.0  4.0
```
- Callable ints by `Alexander Plavin`: [link here](https://julialang.slack.com/archives/C67TK21LJ/p1643312895067919)
```
julia> (1)(2)
2

# but
julia> x = 1
1
julia> (x)(2)
ERROR: MethodError: objects of type Int64 are not callable
```
BUT! This can be avoided, as `Mason Protter` invokes through the magic of type piracy:
```julia-repl
julia> (x::Int)(y) = x * y

julia> x = 1
1

julia> (x)(2)
2 
```
and the following super dirty:
```julia-repl
julia> (s::Symbol)(x) = getproperty(x, s)

julia> :im(1 - im)
-1
```


### Equality is hard
- `isequal` vs `egal` vs `==` vs `===`

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

### Closures and functions
- What is this syntax?
```julia
function (YOLO)
    YOLO + 1
end
```
