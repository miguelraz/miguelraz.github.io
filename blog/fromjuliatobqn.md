@def title = "🚧 WIP 🚧 From Julia to BQN"

Here's the rough sketch of this blogpost:
1. I will give a brief intro to BQN and talk about its pros and cos
2. I will show a few Julia vs BQN code problems side by syde
3. I will argue that there's areas for Julians to draw inspiration from BQN
4. I will give a few resources at the end for you to dive deeper.

As usual, if you want to support my writings and open source work, [please consider sponsoring me on GitHub](https://github.com/sponsors/miguelraz/). I'm reaaaaally close to 50 monthly sponsors, and it makes a *huuuuge* difference in how much time/worries/resources I have for working on stuff like this.

Alright, on with the blogpost.

------

### Why is BQN is cool 
1. It has fast multidimensional arrays
2. They love unicode
3. It has a REPL!
4. It's super at code golfing 🏌 
5. It's self hosted
6. They use JuliaMono! 💝 
7. They're building a JIT!

Name: funny bacon puns.
*BQN vs APL*:

Getting started
- [BQN keyoard](https://mlochbaum.github.io/BQN/keymap.html)
- Tutorial

Range:
- 15 reshape range 10 # cycles!
- transpose 3_3
- 

scripting:
online REPL or download BQN repo and open with browser `BQN/docs/try.html` from their github repo.

Everything in green is a function
Everything in yellow is a 1 modifier
Everything in purple/pink is a 2 modifer

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
And in BQN:
```
s1 ← "XXXXGGG"
s2 ← "ACTAGGG"
Sol ← +´≠
s1 Sol s2 # 4
```

This is a neat `3 char solution` that Asher will no doubt be very proud of.

2. [Increasing Array](https://cses.fi/problemset/task/1094/)
> You should take 3 minutes to go read the problem statement.

I like that after seeing the problem (you should go and click the link), I didn't think about a C++ but a BQN solution.
Here's my attempt:
```
a ← 3‿2‿5‿1‿7
+´a-˜⌈`a
Sol ← {+´𝕩-˜⌈`𝕩}
Sol ← +´∘(⌈`-⊢) # Asher's solution
Sol a
```

which in Julia I would write like
```julia-repl
x = [3 2 5 1 7]
sol(x) = accumulate(max, x) - x |> sum
sol(x)
```
Which took be a bit because `scanl` is called `accumulate` in Julia. Not too shabby.
(Extra kudos if you can get a non-allocating version working)

3. Maximum parenthesis depth

### What Julians can learn from BQN
1. Broadcasting semantics, `Each ([¨](https://mlochbaum.github.io/BQN/doc/map.html))`, and Taking Arrays Seriously™ 
2. Data parallelism techniques
3. Bit vector optimizations
4. Flattening data recursive structures for performance
5. Array-ify all the things
6. Algorithmic thinking

### Notes and words of caution

- The syntax and symbols of BQN is a big "love it or hate it" part of the deal. I won't try to convince you to *like it*, but I have found it much easier to take a silly, mnemonic based approach to what each symbol does:
  - ` ≡ "abc"` will give you the "depth" of something, because it looks like a little ladder that you descend
  - `⌈` is taking the "highest" value (and is thus the max), `⌊` is taking the "lowest"
  - ```+´``` will be dragging all the stuff to the right of the tick towards the `+`, so it's a reduction
  - ```+```` will be dragging the `+` *towards* the stuff on the right, so it's a `scan`, from left to right.
  These are just the examples that come to mind, but I've found (completely subjectively) for BQN's symbology to be a bit friendlier/more consistent than APL's.
- Be mindful that the `‿` character to denote lists is not the same as that of arrays. The [docs say that](https://mlochbaum.github.io/BQN/doc/arrayrepr.html#brackets) newbies usually start out with these for easy manipulation examples and gradually move on to explicit array notation with the fancy brackets:
```
    3 1⊸+⊸× 5
20

    3‿1⊸+⊸× 5
⟨ 40 30 ⟩

```
As stated in the page, [general array notation is a thorny problem](https://aplwiki.com/wiki/Array_notation) in APL, and it took Julia about 10 years to finally nail down the tools [and syntax to land it in Base.](https://github.com/JuliaLang/julia/pull/33697)
- Reading BQN/APL is likely where the learning difficulty curve hits hardest when starting out - this [docs page](https://mlochbaum.github.io/BQN/doc/context.html#is-grammatical-context-really-a-problem) was very useful to grok that `˜` is a 1-modifier (as all symbols that "float higher up") and `∘` (like all symbols with unbroken circles) are 2-modifiers. Concretely, having a `context free grammar` removes ambiguity
- When I'm struggling to find out how to write my solutions to problems like the `Increasing Array`, this is my workflow:
  1. Start with thinking "I should propagate the max function" like ```⌈`a```. I'll press `Shift+Enter` on the online BQN REPL and build up the solution
  2. "I should now try to subtract it from the original array" and write ```a-⌈`a```
  3. "Ah, right - I need to add a flip thingy" and evaluate ```a-˜⌈`a```
  4. "Sweet, just have to reduce with a sum now" ```+´a-˜⌈`a```
  5. "Ok, to make it tacit I had to use those ⊣ ⊢ thingies." (I go and review the [modifiers diagrams docs](https://mlochbaum.github.io/BQN/doc/primitive.html#modifiers))
  6. (After much plugging away at the REPL) ... "Dammit, I forgot I can use the `Explain` button!"
  7. (Fiddle around some more) "OK, I think I got it" and write ```Sol ← +´∘(⌈`-⊢)```
- The next big step up in BQN skills is [identifying function trains](https://mlochbaum.github.io/BQN/doc/train.html), which took me a bit of spelunking about in the manual before finding it. For example, going from the first line to the second in this snippet 👇🏻 
```
"whatsin" {(𝕨∊𝕩)/𝕨} "intersect"
"whatsin" (∊/⊣) "intersect"
```
proficiently will really up your game in code-golfing powers, should you be interested in that. This [APL Wiki page](https://aplwiki.com/wiki/Tacit_programming#Trains) and the [Trainspotting](https://xpqz.github.io/learnapl/tacit.html) links and [videos at the end](https://www.youtube.com/watch?v=Enlh5qwwDuY?t=440) are also useful resources.
- `TODO` Benchmarking:
- `TODO` Generating random arrays:

### Interesting resources
For those that *truly* want to stare into the abyss and have it stare right back at them, there's some ~university level courses that are written in APL/BQN/J.
- [Code Report/Connor Hoekstra's](https://www.youtube.com/watch?v=UogkQ67d0nY&t=780s) Youtube channel - where he goes over some of the [history and theory of combinator logic](https://archive.org/details/combinatorylogic0002curr) via code examples in Scala, Haskell and APL.
- [Here's Kenneth Iverson's](https://link.springer.com/chapter/10.1007%2F978-3-642-41422-0_2) `Notation and Thinking` paper.
- [Physics in APL2](http://www.softwarepreservation.org/projects/apl/Books/Physics%20in%20APL2)
- [Calculus in J](https://www.jsoftware.com/books/pdf/calculus.pdf)


### What's next?

...Well, I think I want to learn a bit from the people that *took parallelism and performance seriously in ML* aka, "What if Haskell wasn't slow and they wanted to dunk on MATLAB"?

Don't forget...

\miguelito{If you want to see more blogposts, [sponsor me on GitHub](https://github.com/sponsors/miguelraz/)}
