@def title = "From Julia to Rust"
@def author = "Miguel Raz Guzmán Macedo"
@def tags = ["Rust", "Julia"]
@def rss = "From Julia to Rust - learnings and reflections"
@def rss_pubdate = Date(2021, 06, 05)
@def published = "05 June 2021"

### From Julia to Rust 🗺 

I've been more serious about learning Rust recently, after dragging on with passive learning for a while. My first real programming language was Julia, and I know other Julians interested in Rust. I've written this article for those people in mind, because Rust and Julia are good performance sparring partners, but Rust has a different mindset and tradeoffs that are worth considering.

I hope you enjoy it.

---

### Why Rust? 🤷 

There are 3 talks that sold me on Rust being worth learning, the first is [by Carol Nichols](https://www.youtube.com/watch?v=A3AdN7U24iU) and the [second is a lecture by Ryan Eberhardt and Armin Nanavari](https://www.youtube.com/watch?v=cUrggIAPJEs). The first talks about how about ~70% of all bugs from the big tech corporations are from memory safety and that trains used to not have emergency brakes. The second explains how sytems programming codebases already impose the invariants of resource ownership on the coders - but that reasoning can be horribly error prone, tedious, and automated.

That's the point of technology! To not have to worry about the previous generations problems because we figured out a way to offload that thinking to a machine. 

The third talk that really sold me on Rust was [Alex Gaynor's](https://www.usenix.org/conference/enigma2021/presentation/gaynor). It's bad enough that a bank or a school web site could crash because of memory bugs, but once you take into account the fact that not even the best programmers in the world (sorted by salaries, roughly) can ship safe code, you start to despair a little. Then you hear about the incredibly battle-tested libraries like [sudo ](https://www.helpnetsecurity.com/2021/01/27/cve-2021-3156/) and, as the moral argument goes, you are likely going to put vulnerable people in harm's way if you keep shipping a broken tool. I buy the urgency of that argument more and more when journalists or human rights advocates get targeted by state actors due to a trivial (but buried) C mistake.

So that's the spiel for jumping on the Rust train when I argue with myself in the shower. What's the Rust's philosophy?

---

### Informal introductions - tales of two languages 📚 

I will now give 2 hand-wavy historical rehashings of the origins of both languages.

You might know Julia's origin story - there were a gajillion DSLs for scientific computing, BLAS is a mess but implements polymorphism through namespacing for performance needs, and other libraries re-implemented a poor man's version of multiple dispatch because of the performance constraints. If you add a clever JIT to multiple dispatch capabilites, you can get ~C performance with ease if types can be inferred, and fortunately you can build a general programming language around that paradigm and those trade offs. Eventually, they baptized the language to honor the one true queen of [algorithms](https://youtu.be/lZb2JKhf-mk?t=208).

Rust comes from a different place: Some years ago in Mozilla, Graydon Hoare and the team got fed up with systems programming and the C/C++ tool chain. They were working on a language that allowed for programmers to be productive in low-level systems, harness concurrency performance without the foot-bazookas, and avoid errors during run time. At first they had different systems for handling the previous problems, until the team pieced together that an ownership system, with a borrow checker at compile time, could kill 2 birds with one stone. Eventually, they named the language after the [fungus](https://en.wikipedia.org/wiki/Rust_(fungus)).

Recap: Julians were sick of unreusable code, niche DSLs and hacky polymorphism. With multiple dispatch as the central design feature they solved those problems. Rustaceans were sick of the C/C++ minefields and trying to keep all the invariants of large, error-prone codebases in their head. The idea of ownership and a borrow checker to know those errors *at compile time* and be data-race free is what's got them to where they are now.

There's obviously important details missing on both stories - you can get it from proper historians if you like, this is a brief and informal introduction. I will however, mention the other big Rustian idea of affine types when I talk about how they get a version of generic code we've come to know and love in Julia land. Spoiler alert: you can get generic code if you pay the price of a Julia runtime, and that's not something Rustaceans want. If you want generics at compile time, you have to "prove" to the compiler that your types are constrained to some extent, and you relay that information by tacking on affine types to your code.

That's enough of an intro, here's the table of contents.

\toc

---

### Handy learning materials 🍎🐛 

If for some reason you've already decided that learning Rust is a worthy endeavour, here's my list of resources to learn. I think they are a good resource to follow in approximate order, but use whatever works, and if it doesn't, skip it.

- [The Rust book](https://www.rust-lang.org/): Click the link to get started with installation and IDE setup. It pays to read it at least once cover to cover and not fret about coming back to the thorny bits.
- [VSCode Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens) and [Rustanalyzer](https://github.com/rust-analyzer/rust-analyzer): The quicker the feedback loop you get from the compiler, the sooner you can spot mistakes and keep going. These aren't mandatory but it's the easiest way to make the feedback loop faster.
- [Tour of Rust](https://tourofrust.com/TOC_en.html): Also has good examples.
- [cheat.rs](https://cheats.rs/): A cheat sheet for all the new syntax, priceless.
- [Rust by example](https://doc.rust-lang.org/stable/rust-by-example/index.html): Always good for a quick MWE.
- [Rust docs](https://doc.rust-lang.org/std/iter/trait.Iterator.html): Their version of the Julia manual. Make sure to click the `[+]` to see how the code drops down. I still spend time looking at the iterators page.
- Courses and exercises:
  - [Exercism](https://exercism.io/my/tracks): If you want to get into some guided learning, Exercisms is great, but focuses too much on strings at the beginning for my liking. Make sure to look at the community solutions when you're done.
  - [Advent of Code 2020 by Amos](https://fasterthanli.me/series/advent-of-code-2020/part-1): This was my first "get your hands dirty" with Rust experience. Other articles by Amos are great and friendly too, but this series was useful for figuring out a Rustian workflow and design thinking.
  - [Ryan Eberhardt Stanford course](https://reberhardt.com/blog/2020/10/05/designing-a-new-class-at-stanford-safety-in-systems-programming.html#lectures): University course that gets you up and running with systems programming constraints and problem solving. I'm not its target audience but it was great for understanding Rust's domain.
  - [Jeff Zarnett programming for performance course repo](https://github.com/jzarnett/ece459), with a [full youtube playlist](https://www.youtube.com/watch?v=BE64OK7l20k&list=PLFCH6yhq9yAHnjKmB9RLA2Qdk3XhphqrN): Another good course for stepping in directly into high performance computing - not done with it yet, but the professor is friendly and enthusiastic.
  - [Rustlings](https://github.com/rust-lang/rustlings): I found some exercises too hard the first time I picked up the Rust book. Your Mileage May Vary but I did them solo and suffered. I would recommend pairing up with a buddy before attempting all of it.
- [Too many linked lists](https://rust-unofficial.github.io/too-many-lists/): Another great walkthrough once you feel more comfortable reading and writing Rust.
- Jon Gjengset's streams:  Jon Gjengset is a well-known Rust community member and has amazing quality streams - if you want to see a proficient Rustacean code, this is a good place to start.
  - [sorting algos stream](https://www.youtube.com/watch?v=h4RkCyJyXmM&t=2455s): More friendly to beginners if you know your sorts.
  - [multicore and atomics](https://www.youtube.com/watch?v=rMGWeSjctlY): Gets into the weeds about all the pain that Rust can save you when you're implementing low-level tricky concurrency.
  
----

Alright, so you're set up to go on a learning journey. What's Rust look like anyway when compared to Julia?

### What does generic Rustian code look like? 🔍 
We love composability and multiple dispatch, so let's look at a short example of how to get the good ol' Julia bang-for-buck, with a 1D point:
```julia
import Base: +
struct Point{T<:Real}
    val::T
end

+(x::Point{T}, y::Point{T}) where T<:Real = Point{T}(x.val + y.val)
a = Point{Int32}(1)
b = Point{Int32}(2)
a + b # works
c = Point{Float32}(1.0)
d = Point{Float32}(2.0)
c + d # Also works!
```
So, in Julia land, how do I get generic code? 

I make sure to not use any explicit types and let the dispatch system do the rest. You use functions like `zero(...)`, `eltype(...)`. With the dispatches, I add them to the appropriate subtype with `where T<:Foo`. If I define the appropriate methods, the others get composed atop of them , so I don't need to define `+=` once I've defined `+`. Duck type all the way - when something errors at runtime because I forgot a case (like the fact there's no type promotion rules above) I just write a function per call I missed and keep hacking on.

Setup a simple type hierarchy, define some functions on your types without using them explicitly, profit from not rewriting all the code, plug and chug as you run into errors or perf hits, look at docstrings in the REPL to help you out. Happy life.

Let's look at the rust example:
```rust
use std::ops::Add;

#[derive(Clone, Copy, Debug, PartialEq)]
struct Point<T> {
    val: T
}

impl<T: Add<Output = T>> Add for Point<T> {
    type Output = Self;
    
    fn add(self, b: Self) -> Self::Output {
        Self { val: self.val + b.val }
    }
}

fn main() {
    let a = Point::<i32>{val: 1};
    let b = Point::<i32>{val: 2};
    
    let c = Point::<f32>{val: 1.0};

    println!("{:?}", a + b);
    println!("{:?}", c == c);
}
```
In Rust Land, how do I get a similar generic code?

I worked on like half of this code and then had to [look it up](https://doc.rust-lang.org/std/ops/trait.Add.html). You can run it in the [Rust Playground here](https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=e3dd98c60fa0cdebb5f1a582599d3b0d). Avid readers will notice the following: 

0. Damn, that's a lot of boilerplate. 😣 
1. To get generics, you need a `struct` for your type, an `impl<T> $TRAIT for Point<T>` block where the `add` function is defined, and type annotations like `Self::Output`, `Add<Output = T>`.
2. There's a sort of "name spacing" with the turbo fish operator: `::<this one!>`. We don't get functions that can share names but differ in behaviour. Bummer. (We get this in Julia with some nicer outer constructors, but I think it takes from the thrust of the argument.)
3. The `println!` function is different - it's a macro, and it runs at parse time, also like Julia's macros. The chars inside the `{:?}` signal that we want debug printing, that we got above with the `#[derive(Debug)]`. Rust doesn't know how to print new structs if you don't define it, [which, as Lyndon White points out, is one of the problems solved by multiple dispatch ](https://discourse.julialang.org/t/is-julias-way-of-oop-superior-to-c-python-why-julia-doesnt-use-class-based-oop/52058/84?u=miguelraz).
4. Oh, those `#[things(above_the_struct)]` are also macros. I still don't know how they're different, but they seem to affect how the compiler interacts with the crate too. Since some traits (like the ones for copying or printing) are so boilerplate heavy and predictable, you can get some behaviour for "free" if you add the right `#[derive(...)]` stuff in the declaration. That's how the `c == c` works actually, it's due to the `PartialEq`.

The main workflow feels like this: 

Slap a `<T>` in front of your struct and the fields you want it to be generic over. Look up the functions needed for each trait in the documentation. Setup a brief test case. Doesn't compile? See what `rustc` says and try and tack it on some traits; maybe you missed an affine type with `impl<T: Foo>` or the `Self::Output` - the compiler guides you through patching up your code. If you're asking for some generic behaviour, the compiler will complain and you'll have to add another trait implementation so that *it is damn sure* you're allowed to continue.

I also chose a particularly easy example: there's no associated data (like a string) in my `Point<T>`, so I don't need to prove to the compiler that my data doesn't outlive its uses - those are `lifetimes`, and they can get hairy, fast, but you'll run into them eventually. I also don't know how easily you could handle multiple generic types and the compile time penalties associated with them.

There's more syntax up front compared to Julia, and not just because we're writing library code here. Pythonistas can pick up Julia within a few hours and be productive. Rust has a lot more surface area to cover in learning the language: references, traits, impls, enums, lifetimes, pattern matching with `match`, macros, cargo flags for configuration, ownership and borrowing, Send and Sync...

Whodathunkit, Garbage Collectors let you worry about other things for a small runtime price. They might not be right for every use case but they're a solid investment.

---

### Rustian projects of interest 🥇 

There's a steep wall to climb when starting out with Rust - however, they've nailed the user experience for learning tough stuff. I think it was Esteban Kuber who said something along the lines of "We weren't missing a sufficiently smart compiler, but a more empathetic one".

Alright, so what's the view from the top look like? Like Julia, Rust is an incumbent in a crowded space, so how has it punched above it's weight against the established candidates? 

Here's a list of all the projects that I've found particularly of note to Julians.

- [rayon](https://github.com/rayon-rs/rayon) is the original reason I got interested in Rust. Check their [hello world](https://github.com/rayon-rs/rayon#parallel-iterators-and-more) - the promise is that if you are using iterators, you can swap (mostly) `iter()` for `par_iter()` and at compile time you can know if your code will run in parallel. That's just about the friendliest user interface to parallelism besides `Threads.@threads`, and with some additional guarantees - a small update loop is easy to keep the invariants in your head, but it really pays when the Rust compiler catches a concurrency bug that spanned multiple files, modules and data structures. Cool tech note: Rayon uses the [same idea for work stealing thread scheduler](https://youtu.be/gof_OEv71Aw?t=1184) that Julia's parallel task run time system uses (inspired by Cilk, get it? 'Cuz Rayon is a fake silk? Ha...). 
- [tokio](https://github.com/tokio-rs/tokio) deserves a mention as well for its capabilities for asynchronous programming, but I am not familiar enough with it to comment on it. Rust people get excited about it though! 
*NB*: It is non-trivial to compose `rayon` and `tokio` codes.
- [egg](https://egraphs-good.github.io/) and related projects like [herbie](https://herbie.uwplse.org/): A wicked fast egraph matching engine - a great competitor and inspiration for the Symbolics.jl ecosystem.
- [MMtk and GCs](https://github.com/mmtk/mmtk-core): Garbage Collectors are a family of algorithms that share behaviour, and different strategies can be built atop of tweakable parameters. The promise for building a configurable, performant and battle-tested back-end for Garbage Collectors is alive with this project by Steve Blackburn and gang. If you haven't heard of [Immix](https://www.youtube.com/watch?v=73djjTs4sew&t=914s) or [Floorplan](https://github.com/RedlineResearch/floorplan), enjoy the rabbithole. If you're new to GCs, [this is a good starting point](https://www.cs.cornell.edu/courses/cs6120/2020fa/lesson/10/) for seasoned Julians.
- [Rust CLI](https://zaiste.net/posts/shell-commands-rust/): Rust people feel comfortable working in the terminal, and they've taken that user experience Very Seriously and have a top notch performance and user experience for their command line CLIs. Here's a few of my favorites - you only need to `cargo install foo` and they should be properly installed on your system.
  - [rg](https://github.com/BurntSushi/ripgrep): SIMDified grep replacemnt tool (for some use cases). Includes colors!
  - [bat](https://github.com/sharkdp/bat): cat clone with tons more built-in syntax highlighting.
  - [dust](https://github.com/bootandy/dust): visualize disk space used by folders.
  - [typeracer](https://lib.rs/crates/typeracer): fun typing game.
  - [taskwarrior-tui](https://lib.rs/crates/zoxide): Todo tracker.
  - [zoxide](https://lib.rs/crates/zoxide): directory autojumper. I don't really do `cd ../..` climbing around anymore I just do `z foo` a couple of times and that usually guesses right.
  - [zellij](https://github.com/zellij-org/zellij): Terminal multiplexer with friendly UX. Young and promising.
- [coz](https://github.com/plasma-umass/coz): Invaluable tool for *causal profiling*. [Emery Berger's](https://youtu.be/r-TLSBdHe1A?t=2182) presentation alone is worth knowing about this project. I reeeeeally want to nerdsnipe someone to port this to Julia.
- [sled's](https://sled.rs/perf#e-prime-and-precise-language) approach to benchmarking and databases is top-notch. Also worthy of note is the same author's `rio` crate, which is a Rust interface for the `io_uring` linux kernel module, which can significantly speed up asynchronous programming. There's some WIP PRs for landing this for `libuv`, Julia's thread runtime backend, and that effort [is close to wrapping up](https://github.com/libuv/libuv/pull/2322).
- [Scientific Computing in Rust](https://www.lpalmieri.com/posts/2019-02-23-scientific-computing-a-rust-adventure-part-0-vectors/): A *must* to dive straight into linear algebra.
- [Taking ML to production with Rust](https://www.lpalmieri.com/posts/2019-12-01-taking-ml-to-production-with-rust-a-25x-speedup/): A sister article to the one above.
- [Rust FFT](https://github.com/ejmahler/RustFFT): They beat FFTW in some cases with this one, so it seems worthwhile to take a look 👀 .
- [Green function evaluation kernels](https://github.com/rusty-fast-solvers/rusty-green-kernel): Newer package, but I'd like to see how special functions pan out in Rust land.
- [Polars](https://docs.rs/polars/0.12.1/polars/): A highly tuned dataframes implementation for some use cases. They've topped the charts in some of the [H20ai benchmarks](https://h2oai.github.io/db-benchmark/), so they've definitely got technical chops. (They beat DataFrames.jl because of a sparsification trick which is a bit non-trivial to implement, but there's not necessarily an impediment to matching their speed.)
- [Loom](https://github.com/tokio-rs/loom): a model checker for atomic primitives, sister project to `tokio`. I think Julia is a more natural fit for this approach given the ease of operator overloading  and it will be great to try something similar once Jameson's atomics PR lands.
- [Stateright](https://github.com/tokio-rs/loom): distributed systems model checker with a graphic user interface.
- [Creusot](https://github.com/xldenis/creusot): Add some macros to your Rust code, and have it formally verified by Why3.
- [proptest](https://altsysrq.github.io/proptest-book/proptest/getting-started.html): Configure strategies for exploring type instantiations to fuzz your tests, shrink the cases, and automatically track regressions. Impressive stuff!
- [Gleam](https://gleam.run/) and [Lumen](https://github.com/lumen/lumen): Gleam is a Rust backend for an Erlang based language and Lumen is a Rewritten-in-Rust implementation of the ErlangVM, BEAM. Erlang is a concurrency monster, and their actor based model is scalable as hell for certain workloads. I'm glad to see Julia start to step into that domain with [Actors.jl](https://github.com/JuliaActors/Actors.jl). This seems to be the *right way* to abstract for fault tolerance workloads.

There's oodles more. Check out [crates.io](crates.io) or [lib.rs](lib.rs) if you want to explore more (this is their community based JuliaHub equivalent).

I'll make a special note of [evcxr](https://github.com/google/evcxr), a Rust REPL. For now, I don't think it's profitable to use Rust with a REPL-like workflow. I'm too used to that in Julia, and that works well there, but I think there's a risk of digging yourself into a "Everything must be a REPL" mentality and cutting yourself off from learning opportunities. In Rust land, I don't mind doing as the Rustaceans do and learning to do things around a command line, navigating compiler errors and configuring flags and features for certain behaviours or deployment options. Since that's the package that I wanted to learn when I bought into Rust, I don't mind adapting into that mindset. I still wish them all the best and hope they can make the best possible Rust REPL - I'd love to be wrong on this down the road.

---

### Optimization walkthroughs 🏃 

If you want to dive deep into nitty gritty performance fundamentals, these are the best guides I found for explaining the tradeoffs, gotchas, mental model, and engineering for those tasty, tasty flops.

0. [COST paper](http://www.frankmcsherry.org/assets/COST.pdf): Maybe doesn't fit here but this is one of my favorite papers and everyone should read it.
1. [Comparing parallel Rust and C++](https://parallel-rust-cpp.github.io/)
2. [Cheap tricks](https://deterministic.space/high-performance-rust.html)
3. [The Rust performance Book](https://nnethercote.github.io/perf-book/)
4. [How to write Fast Rust code](https://likebike.com/posts/How_To_Write_Fast_Rust_Code.html)
5. [Fastware Workshope](http://troubles.md/posts/rustfest-2018-workshop/)

---

### Papercuts and sharp edges ✂ 

So Rust is "worth learning", but these are roadblocks that I faced and would warn others about to save them some grief.

- You can learn another hobby waiting for Rust projects to compile. The price for compile-time guarantees/being the designated driver in the codebase is offloading more work to the compiler. They're working on leveraging concurrency for speeding up the pipeline, and it's gotten better. Let's just say they also suffer from TTFP 😉 .
- Learn to run your code with `cargo run --release` [and other tricks](https://deterministic.space/high-performance-rust.html). This is the equivalent to running your Julia code with globals (or `-O0` flags), and it's an easy gotcha. This will not change in Rust.
- Rust people keep saying they have no Garbage Collector, when they have a Region Based Garbage Collector. It's all fun and games until they have to implement those linked lists...
- Don't add crates manually! Install `cargo-add`, use it to manage crate dependencies. That and some other tricks are great from doing the `AdventOfCode2020` from the article above.
- For numerics, install `ndarray` and `num_traits`. Linear Algebra and numerics where not a primary focus of Rust when starting out as they were with Julia.
- Benchmarking with `@btime` is painless, `criterion` is your best Rustian bet.
- Setup your `rust-analyzer` and `error lens` plugins on VSCode or IDE asap, you'll thank me later. Rust-land expects you to be in constant dialogue with the compiler, and making that iteration cycle as ergonomic as possible will yield dividends in the long run. What we don't get from accessing help docs in the REPL, Rust people keep a terminal tab handy where they run `cargo watch -c` and get continuous feedback from the compiler.
- You CAN'T index into a String in Rust with ints! [Instead](https://doc.rust-lang.org/std/primitive.str.html#method.chars) use slices like `&str[1..] == str[2:end]`, if I may riff on Rust and Julia syntax in the equality just there.
- Reading from `stdin` is a pain as a newcomer. I wanted to try out some competitive coding exercises and reading from `stdin` was waaaay too rough for me at first. Eventually I cobbled this template up [link here](https://gist.github.com/miguelraz/d0341e9fee8c728baa99fd6fe86c1be1) so that you don't struggle if you want to try a couple of CodeForces problems.
- Not having a generic `rand` is just painful. So painful. This is my easiest workaround so far for generating a vector of `n` random entries:
```rust
let n = 100;
use rand::distributions::Standard;
use rand::prelude::*;
thread_rng().sample_iter(&Standard).take(n).collect()
```
(Oh, and `rand` isn't part of the stdlib so that's another papercut).
- There is no `@code_native` and friends in Rust - your best bet is to use the Rust Playground and click on the `...` to have it emit the total assembly. This only works for the top 100 most popular crates though. You can `cargo run --release -- --emit=llvm-ir/asm` and then fish the results out of `target/`, but that's unwieldy - why does no one have a CLI for this yet?
- Another multiple dispatch gripe: having to implement `Display` traits for new structs feels like pulling teeth, and this initial type signature seems inscrutable as a beginner:
```rust
use std::fmt;

struct Point {
    x: i32,
    y: i32,
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}
```
- Rust does NOT look like math and that hurts my little physicist heart. [Look at this story of a hydrodynamics simulator code](https://rust-lang.github.io/wg-async-foundations/vision/status_quo/niklaus_simulates_hydrodynamics.html) vs anything in the DiffEq verse that is user facing or from ApproxFun.jl, or Turing.jl, or ... anything else. Even the linear algebra from `ndarray` is painful to understand unless you are comfortable in Rust, and all the `i as usize` conversions are a huge eye sore.
- Many of your functions will be faster if you annotate them with `#[inline]`.

---

### Things I wish I'd known earlier 👓 

These could have helped me settle down into a more productive workflow sooner. Get a buddy that knows Rust to see you code to figure most of these out.

0. If you can, avoid the examples with Strings and &str. Yes, they're a great motivation for systems people for all the gnarly use-after free and double-free and memory-leak examples - stick with numerical algorithms first, to get the gist of ownership, try and do some exercisms with iterators and Strings will be much easier to get after that. I don't think it's worth worrying about at first unless your target is systems.
1. The preferred way of "whipping up an example in the REPL"/getting a MWE is to `cargo new foo`, mucking about and then `cargo run --release` or using the Rust Playground.
2. If you're using an expansive test suite, `cargo test --test-threads 8` and `cargo test --quiet` are helpful flags.
3. For loops are not idiomatic in Rust - writing Fortran-ey code instead of iterators will lead to pain and slower loops. Spending time reading the examples in [the iterator docs](https://doc.rust-lang.org/std/iter/trait.Iterator.html) and the community solutions in the exercisms will help a lot.
4. Just clone everything when you are starting out to get around most borrow checker shenanigans - worry about allocations later, Rust is usually fast enough.
5. In the following function, the types of `v` and `w` are a `slice` of `Int32`s, which are different from `Vec<32>`. Read the Scientific Computing link above to see a nice table of the differences. An array like `[f32; 4]` includes the size as part of the type, a slice like `[f32]` does not. Diving into linear algebra means being familiar with many `to_array()`, `to_slice()`, `from_array()`, and `from_slice()` cases.
```rust
fn dot(v: &[i32], w: &[i32]) -> i32 {...}
```


6. Including docs and tests in the same file as your implementation is idiomatic - even the IDEs support clicking on the `#[test]` line and having that run. Julia has a nice workflow for test driven development out-of-the-box - Rust gives you some of those guarantees by... conversing with the compiler.
7. Rust has something similar to the concept of `type piracy`: they're called the `orphan rules`, as explained by [this Michael Gattozzi](https://blog.mgattozzi.dev/orphan-rules/) post:
> Recently at work I managed to hit the Orphan Rules implementing some things for an internal crate. Orphan Rules you say? These are ancient rules passed down from the before times (pre 1.0) that have to do with trait coherence. Mainly, if you and I both implement a trait from another crate on the same type in another crate and we compile the code, which implementation do we use?
8. Rust is not as centralized with online communication as Julia is around Slack/Zulip/Discourse. Their version of `#appreciation` channels is to go on twitter and tell `@ekuber` what a joy the compilers errors are. There's tons of people on their Discord, and everywhere.

---

### Appreciation of Rust things 🦀  

These are things the Rust people have nailed down.

0. Ferris the crab is too cute.
1. Rust people take uwu-ification very, VERY seriously. [The uwu](https://github.com/Daniel-Liu-c0deb0t/uwu) project uses SIMD to uwu-ify strings for [great artistic value](https://twitter.com/twent_weznowor). Julia and Rust both draw me because they make me feel more powerful when I code with them than I think I should be.
2. Governance: The Rust foundation and strong community conduct codes. Given the blow ups that have happened with open source communities recently from short-sighted governance or hate reactionaries tanking projects, this is a welcome sight that will probably pay off for decades to come.
3. Compiler error messages are second to none. Definitely check out `clippy` too and follow the hints. `cargo fmt` will also format all your crate so that Rust code is almost always a unified reading experience.
4. [Awesome mentors](https://rustbeginners.github.io/awesome-rust-mentors/). This is a project maintained `Jane Lusby` and other volunteers. I've gotten world-class mentorship from kind, patient and friendly Rust folks. Shoutout to `Jubilee` for her great wisdom and patience and the rest of the `stdsimd` gang.
5. They also poke the LLVM crowd to improve the compilation times, which is great.
6. They're doc deployment system is unified, polished, and friendly. Inline docs and tests are also great.
7. `cargo` is a joy compared to `Make` hell. `Pkg` is somewhat inspired by it, so that rocks.

---

### What Rust can bring to Julia ⚒ 

1. A model of governance. The Rust community is at least 10x the size of Julia, and it's unclear that adding more hats to the same `TruckFactorCritical` people would help. That said, it'd be better to have those conversations sooner rather than later, and building bridges with Rust people seems wise in the long term. I don't think that Rust is the closest model to look up to given the other projects under the NumFocus umbrella that we can learn from, but I don't see what is lost from learning from them.

2. Less vulnerable software in the world is a good thing. Oxidization is great! Sometimes. I don't think any Julia internals will oxidize in the short term, but it would be an interesting experiment to say the least.
3. [Error handling](https://www.youtube.com/watch?v=rAF8mLI0naQ&t=947s): Multiple dispatch may prove advantageous in this domain, and it hasn't been as much of a priority as it has in Rust. Perhaps that merits some careful rethinking for future Julia versions.
4. Awesome Julia mentors, I think we need this.

---

### Acknowledgments 🙌🏻 

* Thanks to `Jubilee` for feedback on this post and the following corrections: 
  - Rust does not necessarily have an RC GC but a [region based GC](https://en.wikipedia.org/wiki/Region-based_memory_management). You can opt into the RC GC with `Arc` and `Rc` types.
  - Technically Rust doesn't have linear types but [affine types](https://gankra.github.io/blah/linear-rust/).
  - Tokio's story is not as simple as I had made it out to be so I cut some comments
* `Alex Weech` helpfully suggested refactoring the original Julia Point code to be more similar to the Rust example.
* `Daniel Menéndez` helpfully suggested adding `crates.io` or `lib.rs`
* Thanks to `oliver` I also read about this post by Chris Lattner, author of LLVM, on the dangers of [undefined behaviour](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know_14.html), to really scare you out of thinking you know what C is doing under the hood.
