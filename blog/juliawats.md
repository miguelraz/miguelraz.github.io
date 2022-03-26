@def title = "🚧 WIP 🚧 A most refined collection of Julia WATs "

> This talk is inspired by the classic [Wat](https://www.destroyallsoftware.com/talks/wat) talk by Gary Bernhardt, applied to Julia.

Huge thanks to Mason Protter, many of the inital specimens are his.

Why collect a huge array of scary footguns? [Others have ranted](https://viralinstruction.com/posts/badjulia/) before on all the things that [are bad about Julia](https://www.youtube.com/watch?v=TPuJsgyu87U&t=28s), profusely! Enthusiastically! I think there's good value in knowing precisely why [you should hate your tools](https://www.hillelwayne.com/hate-your-tools/). I'm clearly in the "Julia will take over the world camp", and that effusiveness can work great for some projects, but it's good to understand the limitations of the tools we use. There's well known effective ways to come across in a reasoned manner when pitching Julia for a particular use case, but being able to specify *many* of these limitations and the pain points they inflict will generally show that you're willing to take criticism in a healthy manner.

As always, if you want to support me writing more of these Julia horror stories, please consider [sponsoring me on GitHub](https://github.com/sponsors/miguelraz/).

### Empty collections and truthiness
`TODO`
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
- RNG seed set by `@testset`: (Credit to Michael Abbott)

```julia-repl
julia> @testset begin
         x = rand()
         @testset for i in 1:10
           y = rand()
           @test x == y
         end
       end;
Test Summary: | Pass  Total  Time
test set      |   10     10  0.0s
```

### Parsing is hard
- Operator precedene with ranges: (Credit to Oscar Smith)
```julia-repl
julia> -5:5 .+ .5
-5.0:1.0:5.0

julia> (-5:5) .+ .5
-4.5:1.0:5.5
```
- Another few examples from [Bogumił Kamiński's Blog "Confused by Julia"](https://bkamins.github.io/julialang/2022/03/04/wat.html) (which I will include for the completeness of this list, but leave you to visit his blog for the explainers)
```julia-repl
julia> :a => x -> x => :b
:a => var"#1#2"()
```
```julia-repl
julia> 1 == 3 & 1 == 1
true
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

julia> 2e+5 # This should be 20001.0, and yet...
200000.0

julia> 2e + 5 # note the spacing
200001.0
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
Credit to `Jakob Nybo Nissen`:
```julia-repl
julia> :1234567890123456789 == 1234567890123456789
true

julia> :12345678901234567890 == 12345678901234567890
false
```
See also [this issue](https://github.com/JuliaLang/julia/issues/43054).

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
```julia-repl
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

Lowering is hard, credit to `Jonnie Diegelman`:
```julia-repl
julia> nums = zeros(Int, 10);

julia> for nums[rand(1:10)] in 1:20
       end

julia> nums
10-element Vector{Int64}:
 12
 16
  7
 20
 19
 18
 15
  0
 13
 17
```
(Python suffers from [something](https://twitter.com/jonniedie/status/1503881984514400261?s=20&t=3GH8TA-92Kr_eDyGepIsaA) [similar](https://twitter.com/nedbat/status/1498426481906786305?s=20&t=1fmfRPR3rpzGVp2y4_vMoQ)).
Explanation: As `Jabon Nissen` pointed out, "It's because for i in 1:20 lowers to for i = 1:20 in Julia. Here, it's nums[rand(1:10)] = 1:20"
This is another one [for the road](https://twitter.com/jonniedie/status/1503881984514400261)
```julia-repl
julia> nums = [1, 3, 5, 7, 9];
julia> gen = (n for n in nums if n in nums);
julia> collect(gen)
5-element Vector{Int64}:
 1
 3
 5
 7
 9

julia> nums = [1, 3, 5, 7, 9];
julia> gen = (n for n in nums if n in nums);
julia> nums = [1, 2, 3, 4];
julia> collect(gen)
2-element Vector{Int64}:
 1
 3
```
Why does this happen: Jeff points out that the thing to iterate over is evaluated once; everything inside has to be evaluated for each iteration and so can change. However, a cleverly place `let` binding can avoid some of these headaches:
```julia-repl

julia> gen = let nums = 1:2:9
           (n for n  in nums if n in nums)
       end;
julia> nums = 1:4;
julia> collect(gen)
5-element Vector{Int64}:
 1
 3
 5
 7
 9
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
```julia-repl
julia> function (YOLO)
    YOLO + 1
end
```

### Conversions and promotions
Credit to `Miha Zgubič`
```julia-repl
julia> append!([1, 2, 3], "4")
4-element Vector{Int64}:
  1
  2
  3
 52
```
Explanation: `convert` is called implicitly to make `"4"` into `Char`, and since `Int('4') == 52`, you get the result above.

You can get similar results with 
```julia
push!([1, 2, 3], '4') 

x = [1, 2, 3]; 
x[3] = '4'; 
x

copyto!([1,2,3], "456")
```
Credit to `Michael Abott` for those.

Not that the general Julia idiom of `[x, y]` will try to promote to a common element type of possible, but only if it equals one of the input types. This is a constraint that homogenous array representation demands, but can lead to some interesting cases like: (Credit to `MIlan Bouchet-Valat`)
```julia-repl
julia> [BigInt[1], [1.0]]
2-element Vector{Vector}:
 BigInt[1]
 [1.0]

julia> [[1], [1.0]]
2-element Vector{Vector{Float64}}:
 [1.0]
 [1.0]
```

### Strings are hard
Credit to `Vasily Pisarev`.
```julia-repl
julia> countlines("""
       Mary had a little lamb,
          Its fleece was white as snow,
       And every where that Mary went
          The lamb was sure to go
       """)
ERROR: SystemError: opening file "Mary had a little lamb,\n   Its fleece was white as snow,\nAnd every where that Mary went\n   The lamb was sure to go\n": No such file or directory
```

### Types are hard
```julia-repl
julia> threetuple = (3, 3.0, 3f0)
(3, 3.0, 3.0f0)

julia> threetuple isa NTuple
false

julia> threetuple isa NTuple{3,Number}
true
```


-----

#### Credits
- Mark Kittisopikul
- 
