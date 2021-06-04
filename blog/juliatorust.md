@def title = "From Julia to Rust"

### Handy learning materials:
- Rust book
- VScode and Rustanalyzer to just get started
- Tour of Rust
- cheat.rs
- Rust by example
- Rust docs
  - Exercism
  - Advent of Code by Amos
  - Ryan Eberhardt Stanford [course](https://reberhardt.com/blog/2020/10/05/designing-a-new-class-at-stanford-safety-in-systems-programming.html#lectures) 
  - Jeff Zarnett programming for performance course [repo](https://github.com/jzarnett/ece459), 
with a [full youtube playlist](https://www.youtube.com/watch?v=BE64OK7l20k&list=PLFCH6yhq9yAHnjKmB9RLA2Qdk3XhphqrN),[youtube links](https://www.youtube.com/watch?v=-MDHdqZvxxs&list=PLFCH6yhq9yAHnjKmB9RLA2Qdk3XhphqrN&inde
  - Rustlings
- [Too many linked lists](https://rust-unofficial.github.io/too-many-lists/)
- Jon Gjengset streams: 
  - [sorting algos stream](https://www.youtube.com/watch?v=h4RkCyJyXmM&t=2455s)
  - [multicore and atomics](https://www.youtube.com/watch?v=rMGWeSjctlY)

### What does generic Rustian code look like?
We love composability and multiple dispatch - what does that look like in Rust?
- In Julia land, how do I get generic code? `zero(...)`, `eltype(...)`, `where T<:Foo`
- In Rust Land, how do I get generic code? `impl<T>`,
- There's tons of boilerplate -_-
- There's a lot more syntax up front
- There's a lot more surface area to cover in learning the language

### Rustian projects of interest 
- [rayon](https://github.com/rayon-rs/rayon) is the original reason I got interested in Rust. Check their [hello world](https://github.com/rayon-rs/rayon#parallel-iterators-and-more) - the promise is that if you are using iterators, you can swap (in many cases) `iter()` for `par_iter()` and at compile time you can know if your code will run in parallel. That's just about the friendliest user interface to parallelism besides `Threads.@threads`, and with some additional guarantees - a small update loop is easy to keep the invariants in your head, but it really pays when the Rust compiler catches a concurrency bug that spanned multiple files, modules and data structures. Cool tech note: Rayon uses the [same idea for work stealing thread scheduler](https://youtu.be/gof_OEv71Aw?t=1184) that Julia's parallel task run time system uses (inspired by Cilk, get it? 'Cuz Rayon is a fake silk? Ha...). 
- [tokio]() deserves a mention as well for its capabilities for asynchronous programming, but I am not familiar enough with it to comment on it. Rust people are excited about it though! 

NB: Since Rust was adamant about shipping a minimal run time (which means an automatic RC garbage collector and no threading run time) they developed this library as external to stdlib. There's several social and technical constraints for why Tokio is not always included, like embedded systems and people who want to work on no stdlib environments. In Julia the devs just said "let's implement the best one we have so that people don't implement their own and fragment the ecosystem" and that's why we have the task run time we do. This means it is non-trivial to compose `rayon` and `tokio` codes.
- [egg](https://egraphs-good.github.io/)
- cargo release [and other tricks](https://deterministic.space/high-performance-rust.html)
x=28)
- [MMtk and GCs](https://github.com/mmtk/mmtk-core)
- command line stuff rocks [Rust CLI](https://zaiste.net/posts/shell-commands-rust/)
  - rg
  - bat
  - dust
  - typeracer
  - taskwarrior
  - wool
  - zoxide
- [coz](https://github.com/plasma-umass/coz)
- [sled's](https://sled.rs/perf#e-prime-and-precise-language) approach to benchmarking
- [Scientific Computing](https://www.lpalmieri.com/posts/2019-02-23-scientific-computing-a-rust-adventure-part-0-vectors/) a Rust adventure and Rust ML to production
- [Taking ML to production with Rust](https://www.lpalmieri.com/posts/2019-12-01-taking-ml-to-production-with-rust-a-25x-speedup/)
- [Rust FFT](https://github.com/ejmahler/RustFFT)
- [Green function evaluation kernels](https://github.com/rusty-fast-solvers/rusty-green-kernel)
- [Polars](https://docs.rs/polars/0.12.1/polars/)
- [Loom](https://github.com/tokio-rs/loom)
- [Stateright](https://github.com/tokio-rs/loom)
- [Creusot](https://github.com/xldenis/creusot)
- [proptest](https://altsysrq.github.io/proptest-book/proptest/getting-started.html)

### Papercuts and sharp edges
- Knowing the Rustian motivations:
- Stanford course, Carol Golding's talk, C++ dangling pointer example.
- Rust people keep saying they have no Garbage Collector, when they have an automatic Referenc Counting Garbage Collector. It's all fun and games until they have to implement those linked lists...
- Install `cargo-add`, use it to manage crate dependencies. That and some other tricks are great from doing the `AdventOfCode2020` from the article above.
- For numerics, install `ndarray` and `num_traits`. Linear Algebra and numerics where not a primary focus of Rust when starting out as they were with Julia.
- Benchmarking with `@btime` is painless, `criterion` is your best Rustian bet.
- Setup your `rust-analyzer` and `error lens` plugins on VSCode or IDE asap, you'll thank me later. Rust-land expects you to be in constant dialogue with the compiler, and making that iteration cycle as ergonomic as possible will yield dividends in the long run. What we don't get from accessing help docs in the REPL, Rust people keep a terminal tab handy where they run `cargo watch -c` and get continuous feedback from the compiler.
- You CAN'T index into a String in Rust with ints! [Docs are here](https://doc.rust-lang.org/std/primitive.str.html#method.chars) use slices like `&str[1..] == str[2:end]`, to mix up Julia and Rust syntax.
- Reading from `stdin` is a pain as a newcomer. I wanted to try out some competitive coding exercises and reading from `stdin` was waaaay too rough for me at first. Eventually I cobbled this template up [link here](https://gist.github.com/miguelraz/d0341e9fee8c728baa99fd6fe86c1be1) so that you don't struggle if you want to try a couple of CodeForces problems.
- Not having a generic `rand` is just painful. So painful. This is my easiest workaround so far for generating a vector of `n` random entries:
```rust
    use rand::distributions::Standard;
    use rand::prelude::*;
    thread_rng().sample_iter(&Standard).take(n).collect()
```
(Oh, and `rand` isn't part of the stdlib so that's another papercut).
- There is no `@code_native` and friends in Rust - your best bet is to use the Rust Playground and click on the `...` to have it emit the total assembly. This only works for the top 100 most popular crates though. You can `cargo run --release -- --emit=llvm-ir/asm` and then fish the results out of `target/`, but that's unwieldy - why does no one have a CLI for this yet?
- Another multiple dispatch gripe: having to implement `Display` traits for new structs feels like pulling teeth, and this initial type signature seems inscrutable as a begineer:
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
- Rust does NOT look like math and that hurts my little physicist heart. [Look at this story of a hydrodynamics simulator code](https://rust-lang.github.io/wg-async-foundations/vision/status_quo/niklaus_simulates_hydrodynamics.html) vs anything in the DiffEq verse that is user facing or from ApproxFun.jl - worlds apart! Even the linear algebra from `ndarray` is painful to understand unless you are quite comfortable in Rust, and all the `i as usize` conversions are a huge eye sore.

### Appreciation of Rust things
1. Rust people take uwu-ification very, VERY seriously. [The uwu](https://github.com/Daniel-Liu-c0deb0t/uwu) project uses SIMD to uwu-ify strings for [great artistic value](https://twitter.com/twent_weznowor)
2. Governance: The Rust foundation and strong community conduct codes. Given the blow ups that have happened with several open source communities recently from short-sighted governance or hate reactionaries tanking projects, this is a welcome sight that will probably pay off for many decades to come.
3. Compiler error messages are second to none.
4. [Awesome mentors](https://rustbeginners.github.io/awesome-rust-mentors/). This is a project that is carried out by `Jane Lusby` and many others, I've gotten world-class mentorship from very friendly Rust folks.
5. They also poke the LLVM crowd to improve the compilation times, which is great.

### Things I wish I'd known earlier
0. If you can, avoid the examples with Strings and &str. Yes, they're a great motivation for systems people for all the gnarly use-after free and double-free and memory-leak examples - stick with numerical algorithms first, to get the gist of ownership, try and do some exercisms with iterators and Strings will be much easier to get after that. I don't think it's worth worrying about at first unless your target is systems.
1. The preferred way of "whipping up an example in the REPL" is to `cargo new foo`, mucking about and then `cargo run --release` or using the Rust Playground.
2. If you're using a very expansive test suite, `cargo test --test-threads 8` and `cargo test --quiet` are helpful flags.
3. For loops are not idiomatic in Rust - writing Fortran-ey code instead of iterators will lead to pain and slower loops. Spending time reading the examples in [the iterator docs](https://doc.rust-lang.org/std/iter/trait.Iterator.html) and the community solutions in the exercisms will help a lot.
4. Just clone everything when you are starting out to get around most borrow checker shenanigans - worry about allocations later, Rust is fast enough that this is not likely your bottleneck at first.
5. The following function
```rust
fn dot(v: &[i32], w: &[i32]) -> i32 {...}
```
the types of `v` and `w` are a `slice` of `Int32`s, which are different from `Vec<32>`. Read the Scientific Computing link above to see a nice table of the differences.
6. Including docs and tests in the same file as your implementation is idiomatic - even the IDEs support clicking on the `#[test]` line and having that run. Julia has a nice workflow for test driven development out-of-the-box - Rust gives you some of those guarantees by... conversing with the compiler.
7. Polymorphism via macros: `#[derive(Debug, Hash, Eq)]` 
8. Rust has something similar to the concept of `type piracy`: they're called the `orphan rules`, as explained by [this Michael Gattozzi](https://blog.mgattozzi.dev/orphan-rules/) post:
> Recently at work I managed to hit the Orphan Rules implementing some things for an internal crate. Orphan Rules you say? These are ancient rules passed down from the before times (pre 1.0) that have to do with trait coherence. Mainly, if you and I both implement a trait from another crate on the same type in another crate and we compile the code, which implementation do we use?
9. Rust is not as centralized with online communication as Julia is around Slack/Zulip/Discourse. Their version of `#appreciation` channels is to go on twitter and tell `@ekuber` what a joy the compilers errors are. There's tons of people on their Discord, and everywhere.

### What Rust can bring to Julia
1. A model of governance.
2. Less vulnerable software in the world is a good thing.
- [Alex Gaynor talk](https://www.usenix.org/conference/enigma2021/presentation/gaynor):
- [sudo vulnerabilities](https://www.helpnetsecurity.com/2021/01/27/cve-2021-3156/): Very bad ? Maybe?
3. [Error handling](https://www.youtube.com/watch?v=rAF8mLI0naQ&t=947s): Multiple dispatch may prove very advantageous 
4. Awesome Julia mentors, I think we need this.

### What Julia can bring to Rust
1.

### Optimization walkthroughs
0. COST paper
1. [Comparing parallel Rust and C++](https://parallel-rust-cpp.github.io/)
2. [Cheap tricks](https://deterministic.space/high-performance-rust.html)
3. [The Rust performance Book](https://nnethercote.github.io/perf-book/)
4. [How to write Fast Rust code](https://likebike.com/posts/How_To_Write_Fast_Rust_Code.html)
5. [Fastware Workshope](http://troubles.md/posts/rustfest-2018-workshop/)
