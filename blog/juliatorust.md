@def title = "From Julia to Rust"

0. COST paper

Handy learning materials:
- Rust book
- Rustlings
- Tour of Rust
- cheat.rs
- Rust by example
- Rust docs
- Exercism
- Advent of Code by Amos

### What does generic Rustian code look like?
We love composability and multiple dispatch - what does that look like in Rust?
- In Julia land, how do I get generic code? `zero(...)`, `eltype(...)`, `where T<:Foo`
- In Rust Land, how do I get generic code? `impl<T>`, ``

### Rustian projects of interest 
1. Graph workbench Aaalto [Comparing parallel Rust and C++](https://parallel-rust-cpp.github.io/)
2. cargo release [and other tricks](https://deterministic.space/high-performance-rust.html)
3. Jeff Zarnett programming for performance course [repo](https://github.com/jzarnett/ece459), with a [full youtube playlist](https://www.youtube.com/watch?v=BE64OK7l20k&list=PLFCH6yhq9yAHnjKmB9RLA2Qdk3XhphqrN),[youtube links](https://www.youtube.com/watch?v=-MDHdqZvxxs&list=PLFCH6yhq9yAHnjKmB9RLA2Qdk3XhphqrN&index=28)
4. Ryan Eberhardt Stanford [course](https://reberhardt.com/blog/2020/10/05/designing-a-new-class-at-stanford-safety-in-systems-programming.html#lectures) 
5. MMtk and GCs 
6. VScode and Rustanalyzer to just get started
7. command line stuff rocks [Rust CLI](https://zaiste.net/posts/shell-commands-rust/)
- rg
- bat
- dust
- typeracer
- taskwarrior
- wool
8. Jon Gjengset streams: 
- [multicore and atomics](https://www.youtube.com/watch?v=rMGWeSjctlY)
9. [coz](https://github.com/plasma-umass/coz)
10. [sled's](https://sled.rs/perf#e-prime-and-precise-language) approach to benchmarking
11. [Scientific Computing](https://www.lpalmieri.com/posts/2019-02-23-scientific-computing-a-rust-adventure-part-0-vectors/) a Rust adventure and Rust ML to production
12. [Taking ML to production with Rust](https://www.lpalmieri.com/posts/2019-12-01-taking-ml-to-production-with-rust-a-25x-speedup/)
13. [Rust FFT](https://github.com/ejmahler/RustFFT)
14. [Green function evaluation kernels](https://github.com/rusty-fast-solvers/rusty-green-kernel)
15. egg
16. Polars
17. Loom

### Papercuts and sharp edges
0. Knowing the Rustian motivations:
- Stanford course, Carol Golding's talk, C++ dangling pointer example.
1. Install `cargo-add`, use it to manage crate dependencies.
2. For numerics, install `ndarray` and `num_traits`. Linear Algebra and numerics where not a primary focus of Rust when starting out as they were with Julia.
3. Benchmarking with `@btime` is painless, `criterion` is your best Rustian bet.
4. Setup your `rust-analyzer` and `error lens` plugins on VSCode or IDE asap, you'll thank me later. Rust-land expects you to be in constant dialogue with the compiler, and making that iteration cycle as ergonomic as possible will yield dividends in the long run. What we don't get from accessing help docs in the REPL, Rust people keep a terminal tab handy where they run `cargo watch` and get continuous feedback from the compiler.
5. You CAN'T index into a String in Rust! [Docs are here](https://doc.rust-lang.org/std/primitive.str.html#method.chars) use slices like `&str[1..] == str[2:end]`, to mix up Julia and Rust syntax.
6. Reading from `stdin` is a pain as a newcomer. I wanted to try out some competitive coding exercises and reading from `stdin` was waaaay too rough for me at first. Eventually I cobbled this template up [link here](https://gist.github.com/miguelraz/d0341e9fee8c728baa99fd6fe86c1be1) so that you don't struggle if you want to try a couple of CodeForces problems.
7. Not having a generic `rand` is just painful. So painful.
8. There is no `@code_native` and friends in Rust - your best bet is to use the Rust Playground and click on the `...` to have it emit the total assembly. This only works for the top 100 most popular crates though. You can `cargo run --release -- --emit=llvm-ir/asm` and then fish the results out of `target/`, but that's unwieldy - why does no one have a CLI for this yet?
9. Another multiple dispatch gripe: having to implement `Display` traits for new structs feels like pulling teeth, and this initial type signature seems inscrutable as a begineer:
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

### Appreciation of Rust things
1. Rust people take uwu-ification very, VERY seriously. [The uwu](https://github.com/Daniel-Liu-c0deb0t/uwu) project uses SIMD to uwu-ify strings for [great artistic value](https://twitter.com/twent_weznowor)
2. The Rust foundation and strong community conduct codes.
3. compiler error messages are second to none.

### Things I wish I'd known earlier
0. If you can, avoid the examples with Strings and &str.
1. The preferred way of "whipping up an example in the REPL" is to `cargo new foo`, mucking about and then `cargo run --release` or using the Rust Playground.
2. If you're using a very expansive test suite, `cargo test --test-threads 8` and `cargo test --quiet` are helpful flags.
3. For loops are not idiomatic in Rust - writing Fortran-ey code instead of iterators will lead to pain and slower loops. 
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
9. Rust is not as centralized with online communication as Julia is around Slack/Zulip/Discourse. Their version of `#appreciation` channels is to go on twitter and tell `@ekuber` what a joy the 

### What Rust can bring to Julia
1. A model of governance.
2. Less vulnerable software in the world is a good thing.
- [Alex Gaynor talk](https://www.usenix.org/conference/enigma2021/presentation/gaynor):
- [sudo vulnerabilities](https://www.helpnetsecurity.com/2021/01/27/cve-2021-3156/): Very bad ? Maybe?
- 
3. [Error handling](https://www.youtube.com/watch?v=rAF8mLI0naQ&t=947s): Multiple dispatch may prove very advantageous 

### What Julia can bring to Rust
1.

