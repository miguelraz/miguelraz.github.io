@def title = "The Grind"
@def hascode = true

@def tags = ["diary", "code"]

# Virtual diary for progress on all fronts

### 6/12/2020

51. Advent of Code 7 kicked my butt. HOWEVER! We rocked the parsing with some cool regexes.
- I couldn't solve the first one because I am not familiar with the concept of queues. Or stacks.

Again, Pablo Zubieta coming in with the fire code:
```julia
function fish(d)
    # if you only pop and append to the end of vectors, all is good
    queue = [k for (k, v) in d if haskey(v, "shiny gold")]
    found = Set(queue)
    while !isempty(queue)
        bag = pop!(queue)
        new = (k for (k, v) in d if haskey(v, bag))
        union!(found, new) # This is better than a push!
        append!(queue, new)
    end
    return length(found)
end
```
- So, the idea is I have `pop!`, `push!` and a `queue`.
- If you have a vector of `Pair`, you can sum them with `sum(last, pairs)`.
- For performant regexes [Specificity is king](https://www.loggly.com/blog/five-invaluable-techniques-to-improve-regex-performance/)
- Teo ShaoWei is using some very concise regexes and a very handy function to return named tuples:
```julia
# "nop +0"
# "acc +3"
# "jmp -99" expected inputs
function parse_input_line(line)
    m = match(r"^(\w{3}) ([-+]\d+)$", line
    return (op = m[1], val = parse(Int, m[2]))
end
```
From this we consider the following:
1. Consider having a function that parses a line at a time and passes a named tuple to the solver.
2. Don't be silly - if you already have code that finds the solution to something in part1... use it in part2. -_-.



### 5/12/2020

47. Advent of Code just keeps on rocking!

48. Exericisms review: checking if something is an isogram (no repeated letters):
```julia
isisogram(s) = allunique(i for i in lowercase(s) if isletter(i))
```

49. When defining your new types, make sure to use `promote_rule` appropriately. `Exercism:Complex Numbers:`
- `promote_rule(T1, T2) = foo(promote_type(T1,T2))`
- Remember to import `Base.abs, Base.exponent, Base.:+ ...`
- For funsies, try commenting out your `zero(x), one(x)` implementations and seeing if yoru algebra still works. (Should work regardless!)
- You can write `import Base: real, imag, conj, +, -, * ...` at the top of the file and then do `+(x::Complex, y::Complex)` without `Base.:`.
- Fooling around with rationals is no fun if you don't know the `copysign(x, y)` function: takes the magnitude of `x` with the sign of `y`. Removes
a lot of hacky logic.
- Note: `=> is for pairs, >= is boolean` o.0
- NOTE: Make sure that the tests are RIGHT. Not checking for a 0 denominator blew up in my face.
- If you want to print a custom type, overload `show` so that it `print`s what you want
```
  To customize human-readable text output for objects of type T, define
  show(io::IO, ::MIME"text/plain", ::T) instead. Checking the :compact IOContext
  property of io in such methods is recommended, since some containers show their
  elements by calling this method with :compact => true.
```
- `show(io::IO, x::RationalNumber) = print(io, num(x),"//",den(x))`
Now onto CustomSet:

- You can `merge(dict1, dict1)`.
- You can get the `keytype(d)`
- Great tip from Sascha Mann: To define `foo/foo!` combos, do `foo!(x) = ...` and then `foo(x) = foo!(copy(x))`
- When test sets fail eagerly, consider moving them "up" so that another property is tested first.
- Iteration is ~~hard~~ easier now than before, just figure out how to write the proper
```julia
iterate(s::CustomSet) = iterate(s.dict)
iterate(s::CustomSet, el) = iterate(s.dict, el)
```
50. Iterators galore! We had massive help from Sascha and Fliksel:
- LESSON: RETURN WHAT YOU WANT THE NEXT STATE TO BE
```julia-repl
julia> function Base.iterate(iter::Fibo, state = (0, (1,1))) # The 0 here will represent the "counter" 
       if state[1] > iter.n
           return nothing
       end
       f1, f2 = state[2]
       return f1+f2, (state[1]+1, (f1+f2, f1))
       end
```
51. Note about iterators:
```julia
function Base.iterate(iter::Fibo, state = ...)
				        #  ^ 
					#  |	
	counter = state[1] # <- this has to match with newstate
	if counter > iter.n
	    return nothing
	end

	# Clever calculations here
	newitem = foo(...)
	newstate = (bar(...), ...)     
	# NOTE: the tuples must match up!
	# typeof(newstate) == typeof(state)
	return newitem, newstate

end
```



### 4/12/2020

42. Pablo Zubieta just absolutely shreked his Advent of Code Day04 problem: here's the learnings.
- Parsing to integers and then applying logic can be done within a regex itself.
- Just check for the actual cases that need to be satisfied with the characters themselves, no need to lift them into ints.
- A good strategy is to separate your cases with `|` and put a word boundary at the end `\b`.
- It's zero allocations!

```julia
const input = split(String(read("input")), r"\n\n")

const fields1 = (r"byr", r"iyr", r"eyr", r"hgt", r"hcl", r"ecl", r"pid")
const fields2 = (
    r"byr:(19[2-9][0-9]|200[0-2])\b",
    r"iyr:20(1[0-9]|20)\b",
    r"eyr:20(2[0-9]|30)\b",
    r"hgt:(1([5-8][0-9]|9[0-3])cm|(59|6[0-9]|7[0-6])in)\b",
    r"hcl:#[0-9a-f]{6}\b",
    r"ecl:(amb|blu|brn|gry|grn|hzl|oth)\b",
    r"pid:\d{9}\b"
)

# Part 1
count(p -> all(t -> contains(p, t), fields1), input)

# Part 2
count(p -> all(t -> contains(p, t), fields2), input)
```

43. Instead of 
```julia
if !haskey(d, str)
    d[str] = 1
elseif
    haskey(d, str)
    d[str] += 1
else 
    ...
end
```
You can try 
```julia
d[str] = get(d, s, 0) + 1
```

44. Revisiting Exercisms is a good way to hone skills. Instead of 
```julia
a, b, c = dict[c[1]], dict[c[2]] dict[c[3]]
# vs
a, b, c = (dict[c[i]] for i in 1:3)
```

45. Remember to check for type instabilities in the code with `@code_warntype`.

46. Stacking generators within generators is tricky, but `joshua-whittemore` has a trick (Exercism-ETL)
```julia
function transform(input::Dict)
    Dict(
         lowercase(letter) => value
         for (value, letters) in input
         for letter in letters
    )
end
```



### 2/12/2020

37. Beast of a solution with great help from Colin:
```julia
function solutions(str)
    sol1, sol2 = 0, 0
    for line in readlines(str)
        lo, hi, (char,), pass = match(r"^(\d+)-(\d+) (\w): (.+)$", line).captures
        lo, hi = parse.(Int, (lo, hi))
        sol1 += lo <= count(==(char), pass) <= hi
        sol2 += (pass[lo] == char) ⊻ (pass[hi] == char)
    end
    sol1, sol2
end
```
The `match(r"...", line).captures` immediately splits and gets the appropriate strings, and `(char,)` is a tuple decomposition of a container with a single element, (similar to `(a,b) = [3 4]`).

38. Regex has many smart functions
```julia
Regex("[regex]")
r"[regex]"
match(needle, haystack)
~~matchall(needle, haystack)~~
eachmatch(needle, haystack)
ismatch(needle, haystack)
```

39. If I have `str = "Roll On The Floor"` and I want to match on each first character to get the acronym, I can use `getproperty(m, :match)` for that:
```julia
r = eachmatch(r"\b[a-zA-Z]", str)
join(getproperty(r[i], :match) for i in 1:length(r))
```

40. Count is really nifty:
```julia-repl
julia> xs = "#..##."
"#..##."

julia> count("#", xs)
3
```
These "curried" operators can be found with `rg Fix[12]`, or `help?> Fix1`

!!! You can implement this for your own methods with `Base.Fix2{typeof(func)}`: `contains(needle) = Base.Fix2(contains, needle)`

41. When dealing with parsing strings by hand, split can sometimes give useless empty strings that muck up the analysis later on. Use the `kw` `keepempty=false` to get rid of those spurious results! For an example, check the AdventOfCodeDay04 code.


### 1/12/2020

35. Advent of code day 01: cool tricks:

36. Advent of code day 02: Cool tricks:
- remember that `'a' != "a"`. If ASCII `"a"[1]` works, and in other cases, use `only()`.
- Even better, as `@tommyxr` points out, just do `==(letter)`.


### 21/11/2020

33. Credit to `@Suker`: REPL interactivity can be drastically helped (and enhanced with Revise.jl) if you have the following:
- working on a script that may have some big g Global parameter everywhere,
- put those in a function `main()` and put `!isinteractive() && main()` at the end of the file

34. Reading the SciML dev docs:
- To add a new package to the common interface, define the types
 ```julia
abstract type AnalyticAlgorithm <: DiffEqBase.AbstractAnalyticAlgorithm
 ```
 - specify type parameters for concrete algos
 ```julia
struct analytic{Simple} <: AnalyticAlgorithm{Simple} end
analytic(; simple = true) = analytic{simple}()
 ```
 - overload `__solve` from `DiffEqBase.jl`

### 19/11/2020

31. Chris de Graaf suggested instead of using `const A = [1]`, try using a `Ref`:
```julia
# access a ref with []
A = Ref(0)
A[] = 1
A[] == 1 # true
```
Takes a bit more nanoseconds to access than a 1 sized array but is sized `()`.

32. Execution matters more than hoarding ideas. [Decent Talk by John Cormack](https://www.youtube.com/watch?v=dSCBCk4xVa0). Enjoy the insight high, then get down in the mud and try to bust your own idea.

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

27. Copy pasting to the system clipboard in Vim is easier with `select the text -> "+y`. Also `t` will go to just before a character `F` will search a char backwards, and `}` will go to the end of a paragraph.

28. It seems the `Savitzky-Golay` filter is very - VERY - interesting for a lot of computing people. Really need to get into parallelizing it and figuring out the GPU part.
- [ ] Investigate why it was not 4x as fast with Float32s as with Float64s.
- [ ] Check for other applications [in this cool presentaiton](https://sites.middlebury.edu/dunham/files/2017/07/MC2-004-Signal-Processing-in-a-Physics-Experiment-2017-July-11-FINAL.pdf)

29. Started on Pochoir.jl. Godspeed.

30. Oh god. SymbolicUtils.jl can revive IntegralTransforms.jl.

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
