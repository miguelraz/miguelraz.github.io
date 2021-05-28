@def title = "The Grind"
@def hascode = true

@def tags = ["diary", "code"]

# Virtual diary for progress on all fronts

### 27/05/2021

145. Finally got around to the `nucleotide` in Rust exercism. My solution was a bit C-ish, this is neater: (Credits to `azymohliad`, but with no `Err`)
```rust
fn count(c:char, dna: &str) -> usize {
    dna.chars().filter(|&x| x == c).count()
}

fn nucleotide_counts(dna: &str) -> HashMap<char, usize> {
    "ACGT".chars().map(|c| (c, count(c, dna))).collect()
}
```

Another clever initialization trick by `jtmueller`:
```rust
let mut counts: HashMap<char, usize> = ['A', 'C', 'T', 'G'].iter().map(|n| (*n, 0)).collect();
```
Probs worth using `HashMap::with_capacity(4)` since I know there's only `ACTG` as keys.

147. Rust: `use enum::*;`, and then you don't need to `enum::foo` all over your match arms!

148. I learned about the `slice.windows(2)` function in the `sublist` exercise, [link here](https://doc.rust-lang.org/std/primitive.slice.html#method.windows)
```rust
let slice = ['r', 'u', 's', 't'];
let mut iter = slice.windows(2);
assert_eq!(iter.next().unwrap(), &['r', 'u']);
assert_eq!(iter.next().unwrap(), &['u', 's']);
assert_eq!(iter.next().unwrap(), &['s', 't']);
assert!(iter.next().is_none());
```

149. Difference between `show` and `print`: `print` uses quotes around the string, `show` doesn't, and this 

150. Rust: `map.entry(letter).or_insert(0)) += 1`
### 26/05/2021

144. FINALLY GOT THE ASSEMBLY HELLO WORLD TO WORK!
- I had to disable the `stdfaxh.h` whatever
- This was the final command:
```bash
[I] mrg@JuliaLap ~/p/a/m/C/Ch02_01 (master)> nasm -f elf64 Ch02_01.asm
[I] mrg@JuliaLap ~/p/a/m/C/Ch02_01 (master)> g++ Ch02_01.cpp Ch02_01.o
[I] mrg@JuliaLap ~/p/a/m/C/Ch02_01 (master)> ./a.out

```
- and the assembly file was:
```asm
;-------------------------------------------------
;               Ch02_01.asm
;-------------------------------------------------

; extern "C" int IntegerAddSub_(int a, int b, int c, int d);

;        .code
;IntegerAddSub_ proc
	global IntegerAddSub_
	section .text
; Calculate a + b + c - d
IntegerAddSub_:
        mov eax,ecx                         ;eax = a
        add eax,edx                         ;eax = a + b
        add eax,r8d                         ;eax = a + b + c
        sub eax,r9d                         ;eax = a + b + c - d

        ret                                 ;return result to caller
;IntegerAddSub_ endp
;        end

```
- So I just had to add the `global IntegerAddSub_`, `section .text` below that, the name of the function as a section, and the last `ret` to follow `nasm` conventions.

### 24/05/2021

138. Made a 3D print of dispatch with my sister. It was an awesome birthday.

139. Got DoctorDocstrings.jl Poster and Rubin.jl Lightning talk accepted to JuliaCon! Now to work on those asap...

140. Got the Kusswurm `Modern x86 Assembly Language Programming` and Min-Yih Hsu `LLVM Techniques` books in the mail now...

141. Should write down the Next steps for MMTK - a written down goal is usually an easier one. 

142.  🚀 💃 To setup emojis, we can insert with `SPC i e`, but the line editor gets a bit funky...?

143. Found this incredibly useful [Doom emacs tips](https://gist.github.com/hjertnes/9e14416e8962ff5f03c6b9871945b165), and [this vim guide](https://gist.github.com/dmsul/8bb08c686b70d5a68da0e2cb81cd857f)

### 21/05/2021

137. Finally remembered to setup `mu`. Let's [see if I can finally do it...](https://www.sastibe.de/2021/01/setting-up-emacs-as-mail-client/)

### 18/05/2021

135. Vim tricks from Emacs doom! RTFM to change the font to Julia mono!
- `cc` in vim mode will let you change the whole line! 
- `C` changes to the end of the line!
- `*` to highlight all copies of the word under the cursor
- `~` to change the case of a letter, `[#]~` to change # chars after the letter under cursor. `g~[m]`, `gU[m]` `gu[m]` toggle cases with motion `[m]`
- `>[m]` to toggle case with motion `[m]`, `>>` to indent this line
- `J` to move line beneath to end of this one
- `gq[m]` format text between here and `[m]`, `gqq` formats current line
- *Marks*: `ma` sets a mark
- `'` and `''` to set a mark and jump back and forth between them

136. Kevin Bonham is helping me figure out the Emacs tabbing situation:
```
*Me*
Alright, I'm tired of never knowing how to work buffers or tabs or windows inside my doom emacs.
Who's got a good crash course?
My ideal goal is to:

1. Be able to open multiple buffers and move between them
2. Be able to set groups of tabs with different buffers
3. Be able to "restore" groups of tabs when starting up emacs.

*Kevin Bonham*
I've just been figuring this out myself...

1. SPC b b to switch buffers in the same window (assuming you've opened them before with SPC . or something.
    SPC w J (note the capital) will move the current buffer into a new window below (can also use H, K, or L) as last arg to do left, up, or right).
    Then do the same thing but lowercase to move focus around to different windows
2. SPC TAB has all of the tab-related things. SPC TAB n does new tab, SPC TAB r renames it, SPC TAB 1 to switch to tab 1 etc.
3. SPC p has all of the "project" related stuff. I haven't played a lot with these, but they seem to all be linked to a directory, though I think if you have outside files open, they will re-open with the project
```
### 17/05/2021

134. Wow-BOB-Wow has some nifty Rust tricks:
```rust
pub fn sum_of_multiples(limit: u32, factors &[u32]) -> u32 {
	(1..limit).filter(|i| factors.iter().any(|f| i % f == 0)).sum()
}
```

- For `perfect-numbers` don't forget it might be easier to match on 
```rust
match x.cmp(n) {
    Ordering::Greater => Some(Classification::Abundant),
	...
}
```

### 15/05/2021

133. 1.7 goodies! You can destructure structs with named tuples!
```julia
(; a, b) = x # destructures props `a` and `b` of `x`
```
Can also be used like:
```julia
struct A
	x
	y
end

foo((; x, y)::A) = x + y # ermahgerddd
```

`@test` can now be passed as an additional argument `skip` and `broken`:
```julia
@test isequal(complex(one(T)) / complex(T(Inf), T(-Inf)), complex(zero(T), zero(T))) broken=(T == Float64)
```

- You can also now iterate on a `RegexMatch` to get its captures!
- `Base.@invoke f(arg1::T1, arg2::T2; kwargs...) ` now resembles the `@ccall` syntax.
- Multidimiensional array syntax!
```julia
[ 1; 2 ;; 3 ; 4 ;; 5 ; 6 ;;; 7 ; 8 ;; 9 ; 10 ;; 11 ; 12]
```

### 14/05/2021

131. When making a PR to BinaryBuilder.jl, search the whole repo to make sure no one has tried building `jemalloc` before :upside-down: :tada:

132. Julia doesn't ship binaries yet, but [BOLT](https://www.ic.unicamp.br/~ra045840/bolt-cgo19.pdf) could be worth looking into.

### 13/05/2021

129. Micket in the Julia chat has a nice answer for:
"How to do this neater?"
```julia
d = Dict("a" => 2, "b" => 3)
Dict(zip(keys(d), map(x -> 2x, values(d))))
# Do this!
map!(x -> 2x, values(d))
# Or this!
Dict( k => 2v for (k, v) in d)
```

130. `aur/julia-bin` is a good wrapper for Julia on Arch. Thanks Mosè!


### 12/05/2021

128. If you append a julia Markdown bloc with `=` you get line numbers on HackMD.
```julia=
3 + 3
```

### 11/05/2021

123. Fortran learnings!
1. Fortran people [have nice parallelism](https://developer.nvidia.com/blog/accelerating-fortran-do-concurrent-with-gpus-and-the-nvidia-hpc-sdk/) concerns.
```fortran
do concurrent(i = 1:N)
    i0 = max(i - 1, 1)
    i1 = min(i + 1, N)
    b(:, :, 1) = 0.5 * (a(:, :, i0) + a(:, i1)) ! array assignment
end do
```
Can already be sent to Tesla GPUs o.O
2. In fortran, `functions` are `pure`, `subroutines` modify their arguments.
3. To make a struct, it probably suffices that
```fortran
type :: t_point
    real :: x
    real :: y
end type
```
And you access it with
```fortran
type(t_point) :: mypoint
mypoint%x = 1.0
mypoint%y = 2.0
```
4. You can declare fields in the struct as `private, protected, allocatable[dimension], pointer, codimension, contiguous, volatile, asynchronous`:
```fortran
type :: t_example
    integer, private:: i = 0 ! hites it from use outside of the t_example scope. Default init is with i = 0
    integer, protected :: i ! allowed access, but not definition outside of the scope
    real, allocatable, dimension(:) :: x
end type
```
5. You can `contains` *type-bound procedures*
```fortran
module m_shapes
implicit none
private
public t_square

type :: t_square
    real :: side
    contains
        procedure :: area
end type

contains
    real function area(self
    class(t_square), intent(in) :: self
    res = self%side**2
    end function
end module m_shapes
```

124. Peter Deffebach kindly helped me golf a really cool, [but simple task](https://twitter.com/miguelraz_/status/1392161937467731970):
```julia
using CSV, Glob
fs = CSV.File.(readdir(glob"*.csv"))
```
Done! You've read all the files `fs` that are CSVs!
```julia-repl
julia> using CSV, DataFrames, Glob;
julia> files = readdir(glob"*.csv");
julia> reduce(vcat, CSV.read(file, DataFrame) for file in files)
```

125. Jacob Zelko has kindly [shared some tools for dev flow]():
1. vim FloatTerm instead of vim-slime, don't need to open a pane that way.
2. `:MarkDownPreview` with `iamcoo/markdown-preview.nvim`.

### 10/05/2021

121. Tim Besard and Valentin Churavy kindly helped me out on the Julia users GPU call (available on the julialang.org calendar).
They noted a couple of good starting considerations:
1. Try and have a function that maps to every single element in the GPU.
2. Implementing a simple moving average is a type of convolution - there's good tutorials on optimizing that [here](http://alexminnaar.com/2019/07/12/implementing-convolutions-in-cuda.html) and [here](https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/).


### 09/05/2021

120. `git log -p -- path/to/file` will show you the commits you did to a file. Amazing!

### 07/05/2021

117. To write the Unicode Character `U+000A`, (Hat tip to Mason Protter), try this:
```julia
Char(0x000A) |> clipbaord
```
Thanks to Dave MacMaho, we can also do
```julia
'\U1f638'
```
and get the Cat emoji :D

118. Huh, forgot to add this nice pice of `@ccall` goodness from the `primecount_jll` stuff:
```julia-repl
julia> myprimecount(x) = @ccall libprimecount.primecount_pi(x::Clonglong)::Clonglong
myprimecount (generic function with 1 method)

julia> @time myprimecount(1e8)
  0.001004 seconds
5761455

julia> @time myprimecount(1e14)
  0.149201 seconds
3204941750802
```

119. We're dunking on the Fortran gang because they're 8x slower on a `sin` [benchmark](https://fortran-lang.discourse.group/t/simple-summation-8x-slower-than-in-julia/1171/48) :D
I'm glad I pulled out Steven Johnsons flags to cross compile a C lib to use it with `@ccall`:

```julia
shell> ls
cordic.c  cordic.h  cordic.html  cordic.sh

shell> gcc -fPIC -O3 -xc -shared -o libcordic.so cordic.c

shell> ls
cordic.c  cordic.h  cordic.html  cordic.sh  libcordic.so
```

I pulled that from their announcement of hte Julia [broadcasting features](https://julialang.org/blog/2017/01/moredots/) and the annex notebook [here](https://julialang.org/assets/blog/moredots/More-Dots.ipynb).

And here is how to call it:
```julia-repl
julia> function cordic_sine(a)

          cos = Ref{Float64}(0.0)
          sin = Ref{Float64}(0.0)

          # Ref: Excellent work by John Burkardt
          # https://people.sc.fsu.edu/~jburkardt/c_src/cordic/cordic.c
          # void cossin_cordic ( double beta, int n, double *c, double *s )
          ccall((:cossin_cordic, "/home/mason/cordic/libcordic.so"), Cvoid, (Float64, Cint, Ref{Float64}, Ref{Float64}), a, 40, cos, sin)

          return sin[]

       end
cordic_sine (generic function with 1 method)
```
Basically, don't forget it's the ABSOLUTE PATH!

### 06/05/2021

116. Simeon Schaub pulled some fancy destructuring:
```julia
x = [1, 2, 3]
x[3], x[1:2]... = x
@test x == [2, 3, 1]
```



### 05/05/2021

115. WE GOT JEFF TO STREAM SMALL STRING OPTIMIZATION!
Small lessons:
1. Big wieldy codebase? Work on one small, small change at a time. Cross bridges as you come to them.
2. Majority of strings don't need more than 128 bytes, so a single byte of addressing
3. Jeff uses `ack` for grepping the codebase
4. Before trying to compile, review your changes with a `git diff`
5. When getting a segmentation fault after making your changes and running `make`, run a debug build to figure out what went wrong with `make debug -j4`
6. `gdb /usr/bin/julia-debug` starts gdb, then `cd base/; r --output-ji x compile.ji` or something like that.
7. If you change header files you have to rebuild everything
8. Bonus: There's a docker image to start Julia Int32.
9. Multithread the `compiler.ji` step: multithread the code generator, break up into more code units...
10. set a breakpoint on `jl_throw` to see where `gdb` goes wrong. then `r -J ../usr/lib/julia/corecompiler.ji --output-ji x sysimg.jl`
11. rr magic: `rr record ../usr/bin/julia-debug -J ../usr/lib/julia/corecompiler.ji --output-ji x sysimg.jl`, then `rr replay`. `b jl_exceptionf` and then `rc` to "reverse continue" so that you can step backwards from what happened.
12. When an assertion fires, and you are in `gdb`, the location of the assertion in the source code is in frame 4, so, to jump to it you just start `gdb` and then `f 4`.(Usually just using `d bt` to look at the backtrace and figure out from there where to go.
13. You can call lisp (to reindent your emacs!) within the `gc.c` file!
14. Hah, I clicked the moment of [triump!](https://clips.twitch.tv/ExcitedSparklyTofuTheThing-I5DsaBoyOXcZ2KMw)
15. `../julia runtests.jl strings` to run the string test suite.

116. Remembered about `ArgParse.jl`. Noice:
```julia
s = ArgParseSettings()
@add_arg_table! s begin
    "--opt1"
        help = "an option with an argument"
    "--opt2", "-o"
        help = "another option with an argument"
        arg_type = Int
        default = 0
    "--flag1"
        help = "an option without argument, i.e. a flag"
        action = :store_true
    "arg1"
        help = "a positional argument"
        required = true
end
```

### 05/04/2021

114. Don't forget to turn off `cpuscaling` when running your benchmarks! Hat tip to [Camille Fournier](https://twitter.com/skamille/status/1389731461893349380) for schooling a bunch of us on this one!

[From this link:](https://nixcp.com/disable-cpu-frecuency-scaling/) we can do:
```bash
grep -E '^model name|^cpu MHz' /proc/cpuinfo
```

To figure out if the number on the left is lower than the number on the right. That's costing speed!
if you install `cpupowerutils(Centos/Debian)/ cpufrequtils (ubuntu / Debian)` you can do:
```bash
cpupower frequency-set -g performance
```


### 29/04/2021

113. Added a new recipe for `simdjson`. remember to add `supported_platforms(; experimental = true)` to try and run thigns on the new Mac M1 and `julia_compat = 1.6` to get the `cpuid` feature detection.
As always, Mosè helped tons. He rocks.

### 28/04/2021

112. Como deshacer tu [ultimo git commit](https://midu.dev/como-deshacer-el-ultimo-commit-git/)
```bash
git reset --soft HEAD~1
git reset --hard HEAD~1
git commit --ammend -m "este es el mensaje correcto"
git add f.txt
git commit --ammend -m "mensaje del commit"
# Si esta pushed...
git revert 74a...
```

### 27/04/2021

109. `launch=false` config for `CUDA.jl` helps set `peakflops`. Current NVIDIA 860M sets clocks in about 5.6e11.

110. MichaelHatherly's `InteractiveErrors.jl` is amazing. I should add it to a growing list of REPL tools.

111. `cd -` jumps you back to the last dir. Also found [command line libs in Rust](https://lib.rs/command-line-utilities):
- exa, bat, git-tui, git-delta, hunter, and bandwhich
- `grex`, `navi`, and `typeracer`: use more often!

### 22/04/2021

107. Finally reinstalled `CUDA.jl` stuff. Some good pointers:
- install the `linuxXXX-headers` and `linuxXXX-nvidia` to get compat stuff, then `sudo pacman -Sy cuda` to get all the  goodies or `CUDA_full_jll`. Big thanks to Time Besard and the `#gpu` gang for the setup.
- It's important to know the full memory model. Yupei Qi was very kind to recommend the [GTC On Demand videos](https://www.nvidia.com/en-us/gtc/on-demand/) and this [Architecture whitepaper](https://www.microway.com/download/whitepaper/NVIDIA_Maxwell_GM204_Architecture_Whitepaper.pdf)
- This is a good script to figure out the ideal launch config via the occupancy api (🎩 to Valentin Churavy )
```julia-repl
julia> using CUDA
julia> function mykernel()
         nothing
       end
mykernel (generic function with 1 method)
julia> myconfig(kernel) = (@show kernel; (threads=1, blocks=1))
myconfig (generic function with 1 method)
julia> @cuda config=myconfig mykernel()
```
- It is **critical** to use the `nsys` profiler to figure out the full occupancy and the SMs in your systems. Ignore the CUDA cores, those are more marketing.`nsys launch julia` is very useful for getting this setup.


108. Put up StagedFilters.jl on Discord. With `LoopVectorization.jl`, we get up to 300x performance increase on some systems vs SciPy. I should make a release as I go forward
- Roadmap: Add a GPU method, add calculating the derivatives in a single pass


### 20/04/2021

105. Ooops - turns out I didn't use a copy of `main` branch for the tutorials so someone has to update by hadn a bunch of stuff :((((

106. `BinaryBuilder.supported_platforms(exlclude = Sys.islinux)` - where have you been all this time?

### 18/04/2021

104. Great day! Wrote the DataFrames.jl tutorials in Spanish, like 13 notebooks in a day. Vim skills paid off big time!

### 14/04/2021

102. Almost clinching the BB recipe for `racket`. This will help build Herbie! In BinaryBuilder.jl, Mosè recommends, instead of 
```bash
cp racket/bin/* ${prefix}/
# try doing
cp -r racket/bin ${prefix}/.
```

103. Possible TODO? Stefan posted on [Discourse](https://discourse.julialang.org/t/julia-is-eight-times-slower-than-go-on-numerical-scheme/59383/29?u=miguelraz):
> There’s an old issue to [allow type annotations on global variables](https://github.com/JuliaLang/julia/issues/964). **This would be a great intro compiler project** — not trivial by any means, but relatively straightforward. The right approach would need to be discussed with the compiler team, but I suspect the it would be to associate a type with each global binding and automatically insert a type check at each global assignment and teach the compiler that it can assume that the type of each global access has the associated type. An untyped global would then have type Any, so all globals would work the same way. Some subtleties for usability: you’ll want to at least allow redeclaring the same global with the same type so that code can be re-included interactively; you could also allow the type annotation to be made more restrictive since any code that’s already been generated with that assumption will still be correct; to be really fancy, one could add “back edges” from global binding types to methods that use those globals and increase the world age / invalidate those methods, which would allow arbitrary re-declaration of type globals at the cost of recompiling any methods that accessed the global.

### 13/04/2021

100. Submitted GSoC app. Godspeed. Go go Rubin.jl!

101. In BinaryBuilder.jl, `cd ${prefix}/` is where all compilation targets are placed. 
Also, RTFM! Specifically platform hijinks.

### 11/04/2021

98. We got invited to give a conference talk at Alpine2021 because of a [tweet](https://twitter.com/miguelraz_/status/1381041713725153283) I sent to Alpine's main dev, Ariadne Conill.
Now to coordinate a cool talk/proposal with Mosè and Elliot and show off cool Julia stuff.

99. FINALLY got Lean4 working on VSCode. Still don't know how to use `nix` but oh well. Halfway through the manual, and this example was neat to grok:
```lean
def add1Times3FilterEven (xs : List Nat) :=
	-- this
	--   List.filter (. % 2 == 0) (List.map (. * 3) (List.map (. + 1) xs))
	-- becomes this
	--   xs |> List.map (. + 1) |> List.map (. * 3) |> List.filter (. % 2 == 0)
	-- becomes THIS!
	xs |>.map (. + 1) |>.map (. * 3) |>.filter (. % 2 == 0)
```

In the same note: `x |> f` in Lean is the same as `f <| a`, which in Haskell means `f $ a`. Damn, that's some crappy ascii in Haskell :/

### 08/04/2021

97. Spawning a `run(...)` can take 2x more allocations from one system to another!
```julia-repl
julia> using primecount_jll

julia> @time run(`$(primecount()) 1e14`); # can be 2x allocations in other systems!
3204941750802
  0.150116 seconds (468 allocations: 33.891 KiB)
```

92. Woke up to the `primecount_jll` post getting tons of love, awesome! Hat tip to Stefan Karpsinski and Carsten Bauer for alley-ooping this.

93. Need to remember the `@doc` macro exists to document code not necessarily next to a function declaration - need to add a dispatch to DoctorDocstrings.jl for this case.

94. Ah right, forgot the `make -j${proc}` flag for a parallel BBuilder recipe, thanks to Mosè for [catching that again](https://github.com/JuliaPackaging/Yggdrasil/pull/2779/files)

95. Mosè points out [that it's not too hard to look at the warning logs](https://dev.azure.com/JuliaPackaging/Yggdrasil/_build/results?buildId=9980&view=results) emmitted from the PR - that's
how he was ble to spot that `CompilerSupportLibraries` was missing, and some other warnings needed to be addressed.

96. How to easily create a function that updates its own internal state? Use a closure! [ Like this](https://discourse.julialang.org/t/in-julia-how-to-create-a-function-that-saves-its-own-internal-state/58457/4?u=miguelraz)
```julia-repl
julia> f(state=0) = ()->state+=1
f (generic function with 2 methods)

julia> foo = f()
#7 (generic function with 1 method)

julia> foo()
1

julia> foo()
2

julia> foo()
3

julia> foo.state
Core.Box(3)

julia> foo.state.contents
3
```

### 05/04/2021

86. Chris Elrod with the amazing hint that `@code_native` has a `syntax=:intel` or `syntax=:att` flag!

87. Nice idea during the vacation: need to get
- list of all the conditions passed to the integrator and find a way to shove them into the type system.
- just ignore the commented rules, they don't pass those cases anyways :/
- find the first comment symbol "/;", (Only 8 are excluded), and slurp with regex the lhs := rhs /; assumptions
- make sure to separate the assumptions so that the weird list syntax doesn't creep in.

88. [up](https://github.com/akavel/up) Ultimate Plumber is absolutely amazing at ripgreppin' files and seeing results in real time. Someone rewrite it in Rust already!

89. Hmmm - what about just simply checking if there is a `With[...]`, and doing straight string replacement?

90. Don't forget about using `Traceur.jl`!, just drop a `@trace foo(3)` and keep going.

My workflow goes like this:

- `cat` a file into up: `cat file.txt | up`
- setup pipes for grepping and counting `rg "foo" | rg --invert-match "bar" | wc`

91. I made a [cool tutorial](https://discourse.julialang.org/t/number-of-primes-below-a-given-number/58709/21?u=miguelraz) on making a BinaryBuilder.jl recipe for `primecount` a bleeding edge
algorithm library for counting primes in in C/C++.

### 31/03/2021

85. Made public advances on Rubin.jl today. Turns out you can call (Within Mathematica)
`FullForm[Hold[...]]` and that will give you the S-expression for the whole thing.

Now to parse that into Julia full fledged.

### 26/03/2021

81. Apply a `SymbolicUtils.Rewriters.If(cond, rw)` to get the "facts" of our intrules.

82. Somebody can export every single DiffEq method to Fortran with some cleverness and `FortranTarget()` shenanigans in Symbolics.jl hmmmmm

83. `@less @which @edit @functionloc` all work the same!

84. Finally got to forwarding a GitHub fork to a new changes! Here's how:
```
git fetch upstream
git checkout master
git rebase upstream/master
git push -f origin master
```
Kindly [taken from here](https://gist.github.com/ravibhure/a7e0918ff4937c9ea1c456698dcd58aa).

### 25/03/2021

78. Instead of `Base.OneTo(n)`, use `axes(A, i)` (Thanks Mason!), like so:
```julia
julia> A = [rand() for i in 1:1000, j in 1:1000];julia> function do_add4!(A)
           n = sizeof(A)[1]
           for j = Base.OneTo(n)
               for i = Base.OneTo(n)
                   @inbounds A[i,j] += 1.0
               end
           end
       end
```

Chris Elrod mentions that unless the `Base.OneTo` isn't being fed to an inlined function, it doesn't work for much.

79. Mason also recommends `oneunit` instead of `one` as it works with arbitrary number types. BORKED though, disregard.

80. This also works:

```julia
julia> using LoopVectorization
julia> A = # 1000 x 1000 rand float32s
julia> @avxt A .* 1f0 # multithreaded and AVX512 on platforms that support it
```

81. I should start contributing more to LoopVectorization.jl...

### 23/03/2021

73. Derp - remember, it's `match(regex, string).captures[index]`

74.	`FileTrees` needed a `path(file) |> string` instead of a `File`.

75. This whole thing parses and writes to a JSON3 array within 10 seconds. That rules!

76. To write files into the `MyPkg.jl` directory when activated Sukera suggests
```julia
joinpath(@__DIR__, "my_new_file.json")
```

77. HELL YES RUBIN.JL LIVESSSS


### 22/03/2021

70. `ArtifactUtils.jl` rules! just `add_artifact!` and you're almost good to go.

71. Need to work with a gajillion files in a folder and map the same transform to them lazily? Use FileTrees.jl for all your multithreaded directed needs!

72. Hmmm some of the Rubi rules are ... commented? Hope I don't end up writing a full Mathematica to Julia transpiler...

### 17/3/2021

So yeah, it's been a while. Back on the saddle again.

68. `Meta.show_sexpr` is super cool.

69.  This works!

```julia
for c in IOBuffer(mymultilinestring)
	foo(c)
end
```

70. Project Euler is coming along nicely. I should start on Rubi and put those freaking AdventOfCodeParsing skills to the test...


### 16/12/2020

66. Alex Arslan coming in again with the hot tips: If you want to parse a string into an expression (I need it to call the last REPL history line with `@edit`)
you can use `Meta.parse("3^2") == :(3 ^ 2)`.

67. Whooops. Shipped `DoctorDocstrings.jl` today. Best way to figure out if you have a bug is to ship it to production. Problem is that the `jldoctest` expects the output to be `display`ed just after
the REPL input, so I need to paste the code there. I think I can handle it...
`display` is the function to print to the REPL, btw.

### 15/12/2020

65. Boy oh Boy. I started on DoctorDocstrings.jl. It's gonna be amazing.

### 14/12/2020

62. Retaking Matt Bauman's [Parallel workshop from JuliaCon 2019](https://github.com/mbauman/ParallelWorkshop2019/blob/master/040%20Multithreading.jl)
- Remember to accumulate into `Threads.Atomic{eltype(arr)}(zero(eltype(arr))` if updates are scarce.
- `Threads.atomic_add!` and friends aka `atomic_add!(r, A[i]) == r += A[i]`
- `using .Threads`
- Pattern: Initialize an accumulator, write an inner loop (independent for each loop), reduce the results at the end with another for loop
- BUT! Atomics can't yet handle complex numbers, or structs.
- Pattern: Make an array the size of the threads, `@threads for i in eachindex(A); R[threadid()] += A[i]`
There's 3 interesting distinctions for `@sync` and `@async`:
```julia
@time for i in 1:10 # takes about 10s
    sleep(1)
end
@time for i in 1:10 # about 0s
    @async sleep(1)
end
@time @sync for i in 1:10 # about 1s
    @async sleep(1)
end
```
You can `wait` for a task to block until it finishes or `fetch` to initizlize it now.

- `using Distributed`: You have 8 REPLs started on each computer. You gain finer control on which processor communicates with which.
- `nprocs(), myid(), @everywhere`,
- useful idiom: `for i in workers(); @spawnat i work(...); end`
- instead of manually partitioning the space and juggling indexes, try using
```julia
@distributed (+) for r in [(0:9999) .+ offset for offset in 0:10_000:r[end]-1]
    partial_pi(r)
end
```
- `@distributed` has special support for reductions - to save data movement. Good for reductions.
- `@pmap` over a reduction like `0:999` and `0:10000:r[end]-1` and then change it to `0:9999` and `0:1000000:r[end]-1` because you reduce the communication. Especially good for expensive inner loops that return a value. Creates a task per item in iter space.
- `SharedArray` will let all threads concurrently access same array! `using SharedArrays` should Just Work TM. Slower than threads, since you go to disk.
- Heads up - `SharedArrays` must be bits types - because they need to be Mmapped. Threading like behavior replacement on a single machine.
- You can initialize an `SharedArray` with an `init` function so that it starts up its own data in a sense.
- `@sync @distributed` needs to happen to wait for the correct results.
- `DistributedArray` Every worker has access to a different portion of the array. Let's the data do the work splitting.
- `fetch(@spawnat 2 A.localpart)` shows the data the DArray `A` has on worker 2.
- Pluses: Generic arrays, data itself splits the computation.

63. Got pretty well punked by a [Python gotcha](https://twitter.com/DahlitzF/status/1338384990040682498)
```julia-repl
julia> IdDict(true => "yes", 1 => "no", 1.0 => "maybe")
IdDict{Any,String} with 3 entries:
  true => "yes"
  1.0  => "maybe"
  1    => "no"
```
Vs

```julia-repl
julia> Dict(true => "yes", 1 => "no", 1.0 => "maybe")
Dict{Real, String} with 1 entry:
  1.0 => "maybe"
```
Fortunately, Stefan was able to convince some of use in  the Julia Slack that this is a desirable behavior - you should replace the keys of a dict when you do this, otherwise you will be very very unhappy.
Here's the relevant [implementations](https://github.com/JuliaLang/julia/blob/0bedcdabeb21d0d244babb4a88c91ff75a15577f/base/float.jl#L534-L553) in the `decompose` function in Base.

Quoting Stefan from the Slack:
```
in 0.3 we didn’t hash equal keys the same, we considered the type, but it was really bad
worst problem was that the type of a dict changed the behavior
if you had a Dict{Any,String} and you used 1 and 1.0 as keys, they would end up in different slots; if you had a Dict{Float64,String} and you used 1 and 1.0 as keys, they would both end up in the 1.0 slot
the only ways to avoid that  badness were:
1. don’t auto-convert keys, which would be really annoying and fussy
2. figure out a good way to value-based key hashing efficiently
two major challenges:
1. make it fast for common types like ints and floats and reasonably fast for things like bigints and rationals
2. make it extensible so that people implementing their own numeric types can do so correctly
yes, package authors definitely extend 'Base.decompose' to have proper hashing.
```
NICE - [turned the confusion into a PR](https://github.com/JuliaLang/julia/pull/38881)

64. Very nice solution to the wordcount exercise: with a `matchall` regex and a `foreach`.
```julia
function wordcount(sentence::AbstractString)
    words = matchall(r"[a-z]+'[a-z]+|[a-z0-9]+", lowercase(sentence))
    counts = Dict{AbstractString, Int}()
    foreach(w -> counts[w] = get(counts, w, 0) + 1, words)
    counts
end
```

### 11/12/2020

60. Exercism: Circular Buffer. A few informal interfaces define the ability of Julia to give you a lot of methods for free!
- `append!, empty!, pop!, pushfirst, setindex!, collect, eltype, first, getindex, isempty, iterate, last, length, size` are all "free" if you can properly subtype `<: AbstractVector`.
- I didn't need to keep a bunch of tracking vectors - sometimes just 2 Ints to signal where the `Head` (first writeable element) and `tail` first removable element are is enough additional info.
-

61. Omicron666 from Discord helps out with the syntax for nested for loops/iterations:
- `[10*i + j for i+1:M for j in i+1:N] # Do the first variable i, then the second without a comma`

### 7/12/2020

52. `parse(Int, "01010101", base=2)` to get a binary number directly is really nifty.

53. Remember to use the `lo, hi = extrema(xs)` function! Credit for a really elegant solution to JLLing.

54. Some really good learning about writing Iterators from [Eric Davies from Invenia](https://julialang.org/blog/2018/07/iterators-in-julia-0.7/)
- `IterTools.jl` is your friend.
- You need 2 `iterate` methods. YOu can be clever and use a kwarg, or if you aren't sure of the structure of the `state` arg, use `...`:
```julia
function iterate(it::TakeNth, state...)
    xs_iter = nothing

    for i = 1:it.interval
        xs_iter = @ifsomething iterate(it.xs, state...)
        state = Base.tail(xs_iter)
    end

    return xs_iter
end
```

55. To dump a TLA  file into a dot file, use `tlc -dump dot file.dot file.tla`. Then read it with
- Hmmmmm Strong connected concurrent components in LightGraphs.jl ? [link here](https://github.com/tlaplus/tlaplus/blob/master/general/docs/contributions.md), [repo here](https://github.com/vbloemen/hong-ufscc)

56. [CodeCosts.jl](https://github.com/kimikage/CodeCosts.jlA) looks REALLLLLY cool for a [JuliaTooling] video soon...
```julia-repl
julia> using CodeCosts

julia> f(x::T) where T = convert(T, max(x * 10.0, x / 3))
f (generic function with 1 method)

julia> @code_costs f(1.0f0)
CodeCostsInfo(
     CodeInfo(
   1 1 ─ %1  = Base.fpext(Base.Float64, x)::Float64
   4 │   %2  = Base.mul_float(%1, 10.0)::Float64
  20 │   %3  = Base.div_float(x, 3.0f0)::Float32
   1 │   %4  = Base.fpext(Base.Float64, %3)::Float64
   2 │   %5  = Base.lt_float(%2, %4)::Bool
   1 │   %6  = Base.bitcast(Base.Int64, %4)::Int64
   1 │   %7  = Base.slt_int(%6, 0)::Bool
   1 │   %8  = Base.bitcast(Base.Int64, %2)::Int64
   1 │   %9  = Base.slt_int(%8, 0)::Bool
   0 │   %10 = Base.not_int(%7)::Bool
   1 │   %11 = Base.and_int(%9, %10)::Bool
   1 │   %12 = Base.or_int(%5, %11)::Bool
   2 │   %13 = Base.ne_float(%2, %2)::Bool
   1 │   %14 = Base.Math.ifelse(%13, %2, %4)::Float64
   2 │   %15 = Base.ne_float(%4, %4)::Bool
   1 │   %16 = Base.Math.ifelse(%15, %4, %2)::Float64
   1 │   %17 = Base.Math.ifelse(%12, %14, %16)::Float64
   1 │   %18 = Base.fptrunc(Base.Float32, %17)::Float32
   0 └──       return %18
     )
, CodeCostsSummary(
     zero:  2|
    cheap: 12| 111111111111
   middle: 10| 4===2=2=2=
expensive: 20| 20==================
    total: 42| 100 (default threshold)
))
```

57. [DP by errichto:](https://www.youtube.com/watch?v=YBSt1jYwVfU)
- There's identical subproblems (think of the leaves of fibonacci(5))
- if it doesn't matter how you get to an intermediate state, then the dims of the dynamic program are `dp[N]`, with N states.
- Then think of the transition.
- When doing the minimum path sum through an array, take care to a) initialize the edges / boundaries, the first element
- build a copy of the initial data, and only update after doing the logic for the max/min logic.
- Brain hurts.

58. [Dynamic prog 2 by errichto](https://www.youtube.com/watch?v=1mtvm2ubHCY):
- Combination sum problem.

59. TLA challenge for AoC2020!


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
```plaintext
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

```plaintext
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
