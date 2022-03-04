@def title = "🚧 WIP 🚧 From Julia to BQN"

### Why is BQN is cool and what we can learn from 
1. It has fast arrays
2. They love unicode
3. It has a REPL!
4. It's super at code golfing 🏌 
5. It's self hosted
6. They use JuliaMono! 💝 
7. They're building a JIT!

Name: funny bacon puns.

Getting started
- [BQN keyoard](https://mlochbaum.github.io/BQN/keymap.html)

Range:
- 15 reshape range 10 # cycles!
- transpose 3_3
- 

scripting:
online REPL or download BQN repo and open with browser `BQN/docs/try.html` from their github repo.

Everything in green is a function
everything in yellow is a 1 modifier
everything in purple/pink is a 2 modifer

Defining `Hi` function
### REPL Duel
- Problems: `palindromes`, `count different words`,
### Tutorial

### Julia vs BQN problems:

Here's a few "classic" problems in both Julia and BQN
1. Find the Hamming/edit distance between 2 strings:
```julia-repl

julia> dist(s1, s2) = count(((x,y),) -> x != y, zip(s1, s2))
dist (generic function with 1 method)

julia> dist("ACCAGGG", "ACTATGG")
2

julia> dist(s1, s2) = sum(map(!=, s1, s2)) # kudos to Michael Abbot for the broadcasting tip
dist (generic function with 1 method)

julia: dist(s1, s2) = mapreduce(!=, +, s1, s2) # kudos to J. Ling for this one

```
And in BQN
```
s1 ← "ACCAGG"
s2 ← "ACTATGG"
Sol ← +´≠
s1 Sol s2 # 4
```

This is a neat `3 char solution` that Asher will no doubt be very proud about.

2. [Increasing Array](https://cses.fi/problemset/task/1094/)
> You are given an array of n integers. You want to modify the array so that it is increasing, i.e., every element is at least as large as the previous element.
> On each move, you may increase the value of any element by one. What is the minimum number of moves required?
> Input
> The first input line contains an integer n: the size of the array.
> Then, the second line contains n integers x1,x2,…,xn: the contents of the array.
> Input:
> 5
> 3 2 5 1 7
> Output:
> 5

I like that after seeing the problem (you should go and click the link), I didn't think about a C++ but a BQN solution.
Here's my attempt:
```
a ← 3‿2‿5‿1‿7
+´a-˜⌈`a
Sol ← {+´𝕩-˜⌈`𝕩}
Sol a
```
which in Julia I would write like
```julia-repl
x = [3 2 5 1 7]
sol(x) = accumulate(max, x) - x |> sum
sol(x)
```
Which took be a bit because `scanl` is called `accumulate` in Julia. Not too shabby.

