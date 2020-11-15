@def title = "The Grind"
@def hascode = true

@def tags = ["diary", "code"]

# Virtual diary for progress on all fronts

### 15/11/2020

26. Al final empecé el manual en español. Parece que `Laura Ventosa` va a ser buena mancuerna para este proyecto. Qué chido. La [traduccion del manual esta en este link](https://github.com/miguelraz/julia-es-manual).
```bash
wc src/index.mc src/manual/getting-started.md src/manual/variables.md
  109   986  7546 src/index.md
  100   731  5084 src/manual/getting-started.md
  138   932  6102 src/manual/variables.md
  347  2649 18732 total
```
CONTEO: 2640

### 14/11/2020

25. Found an absolutely amazing post about learning Z3 as if it were [Lisp syntactically](https://www.craigstuntz.com/posts/2015-03-05-provable-optimization-with-microsoft-z3.html).
Should definitely look into this further. I think some Z3 and TLA+ are more than enough formal methods for a while...
There's even an online [editor that seems useful for prototyping](https://rise4fun.com/Z3/7VZh)


### 13/11/2020

18. Counting neighbours / minesweeping? Ran into this problem on the [Exercsim](https://exercism.io/my/solutions/fae14489bd9b4de1bc5283815f0e66ac) earlier today:

```julia
sum(arr[i][j] .== "*") #where j = 1:3
```
is a no-no. First, we have to remember to compare `Char`s to `Char`s, since
```julia
"*" == '*' # false
'*' == '*' # true
```
A correct approach looks like:
```julia
sum(arr[i][j] == '*' for j in idxs)
```
by use of some spiffy generator syntax.

19. Maybe time for someone to write a fast `neighbours(arr, i, j)` function in a package and PR it to LinAlg? Credit to Sascha Mann. Use views to make it fast.
Kick it up a notch: make it N-Dimensional, and performant!

20. You can't do `a = "abc"; a[2] = '3';`, or `'3' != Char(3)`, because STRINGS ARE IMMUTABLE!

21. [`Vyu`](https://exercism.io/tracks/julia/exercises/minesweeper/solutions/2c776b090173426eb160cea17a85e536#solution-comment-170293) has an amazing solution for summing up neighbours in a Matrix:
```julia
function sumAdjacent(array, xy::CartesianIndex{2})
    x, y = xy.I
    lenX, lenY = size(array)
    v = view(
        array,
        max(1, x - 1):min(lenX, x + 1),
        max(1 ,y - 1):min(lenY, y + 1)
    )
    sum(v)
end
```
22. [bovine3dom]() has a solution for a hypercube minefield:
```julia
# This function works for hypercube minefields too, which is pretty cool.
# If you decide to construct your own hypercube minefield, bear in mind that
# the curse of dimensionality means that mines become useless as the number of
# dimensions increases to even moderate numbers.
#
# (A more useful metric for 'danger from mines' is the percentage of neighbouring
# cells which contain mines).
function flag_mines(matrix::Array)
    flagged = zeros(Int,size(matrix))
    @inbounds for inds in Tuple.(CartesianIndices(matrix))
        flagged[inds...] = matrix[inds...] == 1 ? -1 : sum(window(matrix,inds,ones(Int,length(size(matrix)))))
    end
    flagged
end
```
23. The cleanest minefield answer might be `OTDE`...
```julia
annotate(minefield) = [
    replace(    
        join(
            w[c] == '*' ? '*' :
            count(get(get(minefield, y, ""), x, "") == '*'
            for x in (c - 1):(c + 1)
                for y in (r - 1):(r + 1)
                    if x != c || y != r)
        for c in 1:length(w)),
    '0' => ' ')
    for (r, w) in enumerate(minefield)
]
```
Lessons:
- a nested generator can be quite powerful
- don't be afraind to use dictionary combos with `for (r, w) in enumerate(xs)`
- This looks intimidating as hell. I don't think I could recode this in a few months.

24. DID NOT KNOW you could iterate a dictionary if you didn't care about order:
```julia
samples = Dict(
	"I" => 1,
	"II" => 2,
	"V" => 5,
	)
for sample in samples
	@test to_roman(sample[1]) == sample[2]
end
```

### 12/11/2020

17. Invaluable git trick: if you committed some changes locally, but someone else pushed to master, use the [auto-rebase autostash trick](https://cscheng.info/2017/01/26/git-tip-autostash-with-git-pull-rebase.html):

```
git config --global pull.rebase true
git config --global rebase.atuoStash true
```
so that you don't need to do `git pull --rebase --autostash` and can just `git pull`.


### 08/11/2020

10. Try and order starter kit / computer parts from newegg.com

11. Before you spend a day trying to scrape / download files, make sure the author did not already kindly include a zipped version of the files :clown_face:

12. I think I found a possible thesis project - SymbolicUtils.jl as a backend for SymbolicTensors.jl. I should message the author and set something up.

13. Ran into rulebasedintegration.org. Downloaded the Mathematica notebooks, found a way to parse and dump them into text with PDFIO.jl.

14. Remembered how to setup an `artifact` with ArtifactUtils.jl. That thing is useful.

15. Found a killer command from SOverflow on how to recursively copy all files in a tree of folders that match an extension into a target directory:

 - whelp I think I lost it. Will fish it back but it was an easy google.

 16. Polytomous recommended ["Taguette"](www.taguette.org) for highlighting documents and its open source. Super cool! Should send to Ponzi.

### 06/11/2020

9. If you want to make your startup super fast, use `PackageCompiler.jl`:
```julia-repl
julia> using PackageCompiler
julia> create_sysimage([:Revise, :OhMyREPL, :BenchmarkTools], replace_default = true)
```
Super charge that combo with the `~/.julia/config/startup.jl`:
```julia-repl
julia> try
           using Revise
       catch e
	   @warn(e)	
       end
```


### 04/11/2020

7. Trump is likely gonna lose the election - crazy times. Been working a bit on scaffolding for LightGraphsIO.jl. Solid integration with Parsers.jl will mean a lot of speed coming up for the LightGraphs.jl ecosystem.

8. In order to not get punked by the output of 

```julia-repl
julia> print.(sq(i) for i in 1:10)
14916253649648110010-element Vector{Nothing}:
nothing
nothing
nothing
nothing
nothing
nothing
nothing
nothing
nothing
nothing
```

`@pabloferz` suggested the `foreach`, which returns a `nothing`, and thus doesn't print.

```julia-repl
julia> foreach(x -> println(x^2), 1:3:7)
1
9
49
```


### 31/10/2020

6. Today I finally got around to rewriting `GraphsIO.jl`. It suffered from a few ailments:
 - Very, very wonky pythonic dispatch
 - Small performance hits when writing (ie, not using `io = IOBuffer()`, `write(io, s1, s2)` instead of the allocating `write(io, "$s1$s2")`, etc.
 - Very awkward test scaffolding. Figuring out which functions are being called is just not fun.
 - Bulky directory structure. I'll just monorepo it for now and see what sticks.
 - Poor documentation.

I adopted the `Blue Style` guidelines because they came in with PkgTemplates.jl and screw it, why not try and follow them.
Here's what I got done today:
 - Testing scaffolding mostly setup. (Files, how to run the tests, etc.)
 - Writing graphs in DOT, and I think 3 other formats.
 - Minor performance improvements.

Tomorrow I should start something fun with the Parsers.jl library for maximum speedups. Wish me luck!

### 29/10/2020

1. Closures! Defining a function within a function is a type of closure. They take variables from one scope above them. `@masonprotter` and `@fredrikekre` helped me figure out why having this is desirable:

```julia-repl
julia> function f(x, y, z)
           data = compute(x, y, z)

           g() = data^2 # closure over data    
           g() # call g here maybe?    
           # ...    
           g() # maybe again here?
end
```

Mason says:"Almost all usages of closures can be replaced with 'top level' functions that take extra arguments (one for each captured field), but it's syntactically less pleasing and can end up causing you to have a bunch of function names in your namespace you don't want."
Of course [there's a Discourse post on it](https://discourse.julialang.org/t/closures-section-in-documentation-is-not-clear-enough/18717/13).
 
2. Wow! [Function composition and piping](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping) lets you do some amazing stuff with `\circ<TAB>` and friends!

```julia-repl
julia> (sqrt ∘ +)(3, 6)
3.0
julia> map(first ∘ reverse ∘ uppercase, split("you can compose functions like this")
6-element Array{Char,1}:
 'U': ASCII/Unicode U+0055 (category Lu: Letter, uppercase)
 'N': ASCII/Unicode U+004E (category Lu: Letter, uppercase)
 'E': ASCII/Unicode U+0045 (category Lu: Letter, uppercase)
...
julia> 1:10 |> sum |> sqrt
7.416...
julia> (sqrt ∘ sum)(1:10)
7.41...
julia> [ "a", "list", "of", "strings"] .|> [uppercase, reverse, titlecase, length]
4-element Array{Any,1}:
  "A"
  "tsil"
  "Of"
 7
julia> (^2, sqrt, inv).([2,4,4])
[4,2, .25]
```

3. Rust allows for defining anonymous functions!

```rust
fn raindrops(n: u32) -> String {
	let is_factor = |f| x % f == 0;
	...
}
```

4. Rust match is very powerful... try and setup the anonymous functions in a tuple after the `match` and then filter by `(each, available, case) => action`.
```rust
pub fn raindrops(num: i64) -> String {
    let mut raindrop = String::new();

    match (num % 3, num % 5, num % 7) {
        (0, 0, 0) => raindrop.push_str("PlingPlangPlong"),
        (0, 0, _) => raindrop.push_str("PlingPlang"),
        (0, _, 0) => raindrop.push_str("PlingPlong"),
        (_, 0, 0) => raindrop.push_str("PlangPlong"),
        (0, _, _) => raindrop.push_str("Pling"),
        (_, 0, _) => raindrop.push_str("Plang"),
        (_, _, 0) => raindrop.push_str("Plong"),
        (_, _, _) => raindrop = num.to_string()
    }

    return raindrop
}
```

5. This was a good use of match

```rust
pub fn square(s: u32) -> u64 {
    match s {
        1...64 => 1u64.wrapping_shl(s-1),
// This also works
//      1u64 << (s - 1)
        _ => panic!("Square must be between 1 and 64"),
    }
}

pub fn total() -> u64 {
    (1..65).map(square).sum()
// Lol thanks philip98
// u64::max_value
}
```
Credit to Wow-BOB-Wow.


### 27/10/2020

Today I got my website setup!
