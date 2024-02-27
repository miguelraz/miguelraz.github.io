@def title = "The Grind"
@def hascode = true

@def tags = ["diary", "code"]

# Virtual diary for progress on all fronts

### 07/04/2022

545. Not all `extern "C"` functions need to be `#[no_mangle]`.
546. You need to tell the Rust compiler about which `mod` files you are importing, as well as the imports at the root of the crate:
```rust
use input::get_name;
use output::{goodbye, hello};
mod input;
mod output;
```
547. Absolute paths in the current crate need `crate`, which means the root of the current crate. `crate::treats::Treat` is doable but verbose and `Treat` can work if used within the same module. If defined one "module up", use `super::Treat`
548. When refactoring, it can get annoying to do that many changes, so you combine both:
```rust
use crate::Treats::Treat;
```
549. You don't need to import `DayKind` to store a `DayKind` var - Rust only requires importing it if used by name.
550. Rust Path Aliases can be done with `pub use crate::day_kind::DayKind` at the top of the file. This allows really nested mods to just work like `forest::enter()` after `pub use the::secret::entrance::to::the::forest::enter;`    .
551. `pub` is a module level distinction, not a crate-level distinction. If you write `pub(crate)` then you can make it so that other crates don't see it as public but all those inside your own crate do.
552. Upward visibility rules for modules:
- Code within a module inherits the visibility rules from the module above itself

553. Important to use the `criterion::black_box` so that Rust doesn't optimize the code away!
554. `#[repr(C)]` lays out types as a C/C++ compiler would. `#[repr(transparent)]` is applicable to types with a single field only. Useful with `newtype` to guarantee same layout.
555. `#[repr(packed)]` will layout a struct literally like how you wrote it out which is useful in low mem scenarios: embedded, sending bandwidth, etc. (with penalties for unaligned accesses, obvi.)
556. `#[repr(align(n))]` is useful for avoiding `false sharing`.
557. Consider that instead of fully generic code you only write non-generic outer functions and then generic helper inner functions.
558. To be a `trait object` you must have a trait implementation and its vtable. Not all traits are `object-safe` - none of the trait's methods can be generic or use the `Self` type, can't have any static methods (no `&Self`).
559. `Orphan Rule`: You can implement a trait for a type only if the trait *or* the type is local to your crate - this respects the property of `coherence` (one and only one implementation can be called by the compiler). BUT! Caveats:
- Only the crate that defines a trait is allowed to write a blanked implementation like `impl<T> MyTrait for T where T: ...`
- `#[fundamental]` can be pirated by everyone: `&`, `&mut`, `Box`: Allows `IntoIterator for &MyType`.
- `Covered Implementations` didn't get this. Local types go first in type parameter: `ForeignTrait<LocalType, T> for ForeignType`.
560. If keys in a `HashMap` must implement `Hash + Eq`, those are the `trait bounds`. `String: Clone` is also a trait bound (though always true) and `where io::Error: From<MyError<T>>;` too.
561. Instead of `HashMap<K, V, S>` where the keys need a generic `T` and values are `usize` and you write
```rust
where T: Hash + Eq, S: BuildHasher + Default
```
you can do
```rust
where HashMap<T, usize, S>: FromIterator
```
562. Higher ranked lifetime: `F: for<'a> Fn(&'a T) -> &'a U`.
563. Some traits tell you you can use functions:
```
Hash -> hash
Clone -> clone
Debug -> fmt
```
etc. But some don't have an associated methods or types and are known as `marker traits`: `Send, Sync, Copy, Sized, Unpin`. All except `Copy` here are `autotraits`: compiler auto implements them for types unless something borks.
564. Some types don't have a name you can type into code, but they exist and called `existential types`. Caller only (almost only) rely on the return type that implements those traits and nothing else. They also provide `zero-cost type erasure`.
565. These are the same:
```rust
fn foo(s: impl ToString) == fn foo<S: ToString>(s: S)
```
566. Remember the [Rust API guidelines](https://rust-lang.github.io/api-guidelines/). 
567. 99% of all times your types should be `Debug, Clone, Send, Sync, Default` and if not, document why.
- Then consider `PartialEq, ParialOrd, Hash, Eq, Ord` and a `serde Serialize/Deserialize` conditional feature
568. Prefer blanket implementations like `&T where T: Trait`, `&mut T where T: Trait`, `Box<T> where T: Trait`.
569. Wrapper types like `Deref` and `AsRef` feel like magic.
570. `frobnicate(s: impl AsRef<str>) -> impl AsRef<str>` can take both a `String` and an `&str`, or dispatch to not monomorphize loads and do `frobnicate(s: &dyn AsRef<str>)`.
571. Sometimes, starting from concrete nd going to generic args is not necessarily backwards compatible: `fn foo(v: &Vec<usize>) `  to `fn foo(v: impl AsRef<[usize]>)` because compiler can't necessarily deduce return type of `foo(&iter.collect())`.
572. Use `#[doc(alias = "...")]` to make types and methods discoverable under other names.
573. If your function takes in 3 booleans, your user might screw up the arg orders vs if you require explicit structs to be passed.
574. `std::marker::PhantomData<Stage>` is metadata that is eliminated at compile time o.0. Use it to encode illegal states as `unrepresentable`:
```rust
struct Grounded;
struct Launched;

struct Rocket<Stage = Grounded> {
    stage: std::marker::PhantomData<Stage>,
}

impl Default for Rocket<Grounded> {}
impl Rocket<Grounded> {
    pub fn launch(self) -> Rocket<Launched> {}
}

impl Rocket<Launched> {
    pub fn accelerate(&mut self) {}
    pub fn decelerate(&mut self) {}
}

impl<Stage> Rocket<Stage> {
    pub fn color(&self) -> Color {}
    pub fn weight(&self) -> Kilograms {}
}
```
"If your function ignores a pointer arg unless a given Boolean is true, just combine the two args". You can make an enum that stands for `false` and no ptr and one variant for `true` that holds a ptr.
575. Consider adding `#[must_use]`.
576. `pub(crate)` and `pub(in path)` both work! The fewer public types, the more dev freedom!
577. Use `#[non_exhaustive]` to prohibit users from using implicit constructors.
578. `Sealed traits` can be used only and not implemented by other crates.




### 06/02/2022

508. `format!()` returns a `String`, and is useful in `match` arms that return a `String::from("...")`.
509. `eprintln!` prints to `STDERR`, and doesn't interfere with printing to `STDOUT`.
510. `fgets` is used to read data from a file: `if (fgets(line, 100, stdin) == NULL) {}`.
511. Refactor like a boss:
- Start a lib crate: `cargo new --lib calculate`
- replace 1 function in C with the same signature as that in Rust:
```
int solve(char *line, int *solution)
->
fn solve(line: *const c_char, solution: *mut c_int) -> c_int
```
512. Export the C types from `libc::{c_char, c_int}` and add `libc` to your crates.
513. To get Rust to be called from C we need:
- Compile our crate as a dynamic library that the C linker understands
- add the new dylib to the linker search path
- mark the Rust `solve` so that the Rust compiler knows to compile it with C calling conventions
- recompile the C program using `solve` from the Rust dylib
514. Cargo workspaces: sometimes, you need to go to your `$root/Cargo.toml` and add your project name under `[workspaces]` so that `cargo build` is happy.
515. To create a dylib with Rust, just do 
```toml
[lib]
crate-type = "[cdylib]"
```
516. We need to let the linker know that the Rust binary inside `target/` is available as `target/debug/libcalculate.so`:
```
ln -s $(pwd)/target/debug/libcalculate.so /lib/libcalculate.so
```
517. Remember to keep forward declarations like
```
int solve(char *line, int *solution);
```
so that the C compiler can defer compilation.
518. Now we can compile and link vs `libcalculate` with `-lcalculate`. 
```
gcc main.c -o bin -lcalculate
```
This fails! We need to add a `#[no_mangle]` and `pub extern "C"` to our `solve(...)` in Rust.
519. We only need to rebuild `cargo build`, there's no need to recompile the C code because it's a *dynamic library*, neat! The library is loaded by the OS every time we run `calculator`.
520. `CStr` is borrowed memory from C. To validate that you are not reallocating a string, check
```
println!("r_str.as_ptr(): {:p}, line: {:p}", r_str.as_ptr(), line);
```
Which means we can avoid reallocating any buffers/vecs in C when manipulated inside Rust.
521. Move your business logic to standalone Rust functions to get the type safety benefits/reusability. Setup the big functions to bridge as needed and then factor out into Rust business logic so you don't need to keep touching the big C functions.
522. `VecDeque` will give you LIFO ordering with `push_front` and `pop_front` methods.
523. Because `push` only accepts `i32`, `match.other.parse()` doesn't need turbofish as compiler can reason it out.
524. *Highly*  recommended to provide a `Display` implementation for error types.
525. `&str` usage avoids reallocation :D.
526. To find executables, do:
```
find objs -executable -type f
```
527. You have to sometimes generate metadata for stuff like types called `ngx_***`. Since you don't always get to write the C binding, you can use tools, like the `build script`.
528. You need `use std::io::Write;` to use `file.write_all(...)`.
529. To run a command with a certain env var, do `env GREET_LANG="es" cargo run`.
530. `match langugae.as_ref()` is useful to stay with `&str`s.
531. Ughhhhhhh Rust stringy metaprogramminggggggg
```rust
let rust_code = format!("fn greet() {{
    println!(\"{}\"); }}", greeting);
```
532. Genius idea: leverage build scripts AND `bindgen` and have your C API written out for you :D. You can include it under `Cargo.toml/[build-dependencies]` as `bindgen = "0.56.0"`.
533. You need One Big Header file that contains all the other ones, sorta like `wrapper.h`
```
#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>
```
and then a Rust `build.rs`:
```rust
fn main() {
    let nginx_dir = "nginx-1.19.3";
    let bindings = bindgen::builder()
        .header("wrapper.h")
        .whitelist_type("ngx_.*")
        //...
        .clang_args(vec![
            format!("-I{}/src/core", nginx_dir),
            format!("-I{}/src/event", nginx_dir),
        //...
        ])
        .generate()
        .unwrap();
        
        bindings.write_to_file("nginx.rs").unwrap();
}
```
534. The `nginx.rs` file is 30k long, but you want to place it in the `out directory`, which you can know where it is via env vars set by cargo, or via
```rust
let out_dir = std::env::var("OUT_DIR").unwrap();

bindings
    .write_to_file(format!("{}/nginx.rs", out_dir))
    .expect("unable to write bindings");
```
535. `include!("filename.rs")` works like the C/C++ `#include <vector>`
536. `env!("OUT_DIR")` can check env vars ar compile time, errs if not provided.
537. `concat!(env!("OUT_DIR"), "/nginx.rs")` to join the paths at compile time.
538. Your scripts will probs have `include!(concat!(env!("OUT_DIR"), "/nginx.rs"));`
539. `let request = &*r;`. Is called `reborrowing` which converts a pointer to a Rust reference. You need to check that
- the pointer is non-null
- the pointee is a valid instance of the type
- once it's a ref it sticks to borrowchk rules
540. Strategy for buffer reuses: 
- Check that everything is non-null
- `let body_bytes = std::offset_from(start) as usize`
- `let body_bytes = std::slice::from_raw_parts(start, len);`
541. You can have many `&str` made from substrings of `String`, since `&str` is just a pointer and a length (read-only, view).
542. `end.offset_from(start) as usize` needs a cast because `start` can be greater than `end`.
543. Pull from local creates with
```
[dependencies]
calculate = {path = "../calculate"}
```
544. Rust to Rust dylibs need `rlib` in addition to `cdylib`.





### 04/04/2022

502. `usize` is in hexadecimal.
503. The function type of `fn noop() {}` is `*const fn() -> ()`, aka `"a const pointer to a function that takes no args and returns unit"`. `unit` is Rust's `"nothingness"`.
504. If you are in the middle of a call stack and can't unwinde, you can do `nonlocal control transfer`, which can be done via `setjmp` and `longjmp`. `setjmp` sends a label/marker location and `longjmp` jumps back to a previously marked location.
505. `Intrinsic functions` are functions made available by the compiler, not by the PL.
506. How to treat
```rust
const JMP_BUF_WIDTH: usize = mem::size_of::<usize>() * 8;
type jmp_buf = [i8; JMP_BUF_WIDTH];
static mut RETURN_HERE: jmp_buf = [0; JMP_BUF_WIDTH];
```
`RETURN_HERE` as a pointer?
```rust
unsafe { &RETURN_HERE as *const i8 as *mut i8}
```
- read only ref to global `RETURN_HERE`
- convert that ref to `*const i8` 
- convert that to `*mut i8` (which makes it mutable for r/w)
- accessing a global var is unsafe, so wrap it all in unsafe
507. There's mutable pointers `*mut` and immutable pointers `*const`.
  
### 03/04/2022

473. For file handling, check out `OpenOptions`:
```rust
let fs = OpenOptions::new()
            .read(true)
            .write(true) // is overridden by append
            .create(true)
            .append(true)
            .open(path)?;
```
Then you can
```rust
let hello = PathBuf::from("/tmp/hello.txt");
hello.extension();
```
474. Creating a `lib` crate allows you to create different binary executables from the same `lib.rs` without reinventing it.
475. `[[bin]]` in your `Cargo.toml` allows you to specify multiple binary targets
476. `USAGE` can be setup to conditionally compile on different targets:
```rust
use libactionkv::ActionKV;

#[cfg(target_os = "windows")]
const USAGE: &str = "
Usage:
    akv_mem.exe FILE get KEY
    akv_mem.exe FILE delete KEY
...
"

#[cfg(not(target_os = "windows"))]
const USAGE: &str ="
Usage:
    akv_mem FILE get KEY
    akv_mem FILE delete KEY
...
"
```
477. `debug_asssert_eq!(data.len(), data_len as usize);` these are disabled during `--release` builds, but enabled during debug builds.

478. Indexing notation is supported via the `Index` trait.
479. Trait objects appear in 3 forms: `&dyn Trait`, `&mut dyn Trait`, `Box<dyn Trait>`. `Box<dyn Trait>` is owned, the other 2 are not. Trait objects add polymorphism - they use less disk space for some small runtime overhead.
480. Dynamic traits look a bit like this:
```rust
fn main() {
    let mut it = Thing::Sword;
    let d = Dwarf {};
    let e = Elf {};
    let h = Human {};

    let party: Vec<&dyn Enchanter> = vec![&e, &h, &d];
    let spellcaster = party.choose(&mut rand::thread_rng()).unwrap();

    spellcaster.enchant(&mut it);
}
```
481. Trait objects are a form of `type erasure` - compiler does not have access to the original type during the call to `enchant()`. Trait are mostly used for
     - heterogenous collection
     - returning a value (functions can return multiple concrete types with trait objects)
     - supporting dynamic dispatch
482. `?` is syntactic sugar for `try!`: `Ok(value) => value`, `Err(err) =>` returns early and attempts to convert `err` to error type defined in the calling function.
483. Remember the `newtype` pattern for aliasing without extra overhead: 
```rust
#[derive(Debug)]
struct MacAddress([u8; 6]);
```
484. If your PL is expression based, control flow structures also return values. This is a good tool for implementing state machines:
```rust
enum HttpState {
    Connect, 
    Request, 
    Response,
}

loop {
    state = match state {
        HttpState::Connect if !socket.is_active() => {...; HttpState::Request}
        HttpState::Request if socket.may_send() => {...; HttpState::Response;}
        HttpState::Response if socket.can_recv() => {...; HttpState::Response}
        HttpState::Response if !socket.may_recv() => {...; break;}
        _ => state,
    }
}
```
485. `struct Clock;` is a `Zero Sized Type` and does not occupy any memory in the resulting application and is purely a compile-time construct.
486. Anon funcs in Rust can be seen as `let add = |a, b| {a + b};`. Anon funcs can't be defined in global scope.
487. To spawn a thread, use `std::thread::spawn()`. It takes no args, and thus you see this syntax: `thread::spawn(|| {...})`. If you want to use vars in the parent scope, that's called a capture. If you want to move ownership, you need to specify it with `thread::spawn(move || {...})`. You *NEED* `move` if you want to use capture variables.
488. Guidelines for using captures:
     - reduce friction at compile time, use `Copy`
     - Values starting from outer scopes may need `static` lifetimes
     - Spawned subthreads can outlive their parents -> that's why you need to `move` ownership to subthreads.
489. To regain mutable access on each iteration, don't do this:
```rust
for handle in &handlers {
    handle.join();
}
// but rather this
while let Some(handle) = handlers.pop() {
    handle.join();
}
```
because it gains mutable access on each iteration, until the `handlers` vector is empty - but removing the ampersand also works :
```rust
for handle in handlers {
    handle.join();
}
```
490. When doing a yield
```rust
while start.elapsed() < pause {
    thread::yield_now();
}
```
`thread::yield_now()` is a signal to the OS that the current thread should be unscheduled. Bad: You don't know if you actually wait for 20ms. An alternative: bypass the OS and go through to CPU directly via `std::sync::atomic::spin_loop_hint().spin_loop_hint()` turns off functionality and saves power usage. Bad: your cpu might not have that capability.
491.   To get rid of the shared variable here:
```rust
let handle = thread::spawn(|| {
    let start = time::Instant::now();
    let duration = time::Duration::from_millis(20); // THIS DOESN'T NEED EVERY THREAD TO BE CREATED
    while start.elapse() < pause {
        thread::yield_now();
    }
})
```
where you can instead use the `move`
```rust
use std::{thread, time};

fn main() {
    let pause = time::Duration::from_millis(20);
    let handle1 = thread::spawn(move || {
        thread::sleep(pause);
    });
    let handle2 = thread::spawn(move || {
        thread::sleep(pause);
    });

}
```

492.   Closures and funcs are different. Closures are anon structs that implement `std::ops::FnOnce` trait and maybe `std::ops::Fn` and `std::ops::FnMut`. Those structs are invisible from source code but contain the variables of the closure inside of them
493. Instead of the `for byte in input.bytes() {let step = match byte {}; steps.push(step);}`, try `input.bytes().map(|byte| {}).collect();`.
494. Translating into Rayon (where a sequence of `Forward(isize) {TurnLeft|TurnRight} == Vec<Operation>` is collected):
```rust
use rayon::prelude::*;

fn parse(input:&str) -> Vec<Operation> {
    input
        .as_bytes()
        .par_iter()
        .map(|byte| match byte {
            b'0' => Home,
            b'1'..=b'9' => {
                let distance = (byte - 0x30) as isize;
                Forward(distance * (HEIGHT/10))
            }
            b'a' | b'b' | b'c' => TurnLeft,
            b'd' | b'e' | b'f' => TurnRight,
            _ => Noop(*byte),
        }).collect()
}
```
495. But what happens when you don't have a tidy iteration you can throw Rayon at? Consider a thread pool and a task queue.
```rust

```
496. `rustup target list` gives you a list of targets that Rust can compile to.
497. `#[repr(u8)]` Instructs the compiler to use a single byte to represent the values.
498. `kill -l` to list all signals supported by the OS. `SIGSTOP` and then `SIGCONT` can be used to stop and resume a running program!
499. To make a global in Rust, do:
```rust
static mut SHUT_DOWN: bool = false; // to change do: unsafe {SHUT_DOWN = true;}
```
500. To register a signal handler:
```rust
use libc::{SIGTERM, SIGUSR1};
//...
fn main () {
    register_signal_handlers(); // Must be done early
}
//...
fn register_signal_handlers() {
    unsafe {
        libc::signal(SIGTERM, handle_sigterm as usize); // fn must be passed as func pointer to C
        libc::signal(SIGUSR1, handle_sigterm as usize);
    }
}
#[allow(dead_code)]
fn handle_sigterm(_signal: i32) {
    register_signal_handlers(); // again early, try not to miss any
    println!("SIGTERM!");
    unsafe { SHUT_DOWN = true; }
}
```
501. `static` appears in a single location in memory. `const` can be duplicated in locations where they are accessed. 502. 


### 02/04/2022
1.   The big 4:
     - use refs
     - clone the values
     - reduce the need for long lifetimes
     - clever type wrappers
2.   `Clone` lets you `.clone()`, `Copy` is implicit and lets you copy instead of move (must be on primitive types).
3.   `Rc<T>` is very useful when cloning would be very expensive.
4.   `Rc<T>` does not allow mutation, `Rc<RefCell<T>>` does.
5.   In multithreaded code, `Rc<T>` -> `Arc<T>` and `Rc<RefCell<T>>` -> `Arc<Mutex<T>>`.
6.   `println!("{:032b}", x);` left pad x with 32 0s
7.   Rust numbers have methods like `1.2_f32.ceil()`.
8.   `Cow` means Copy on Write and are useful when someone gives you a buffer.
9.   `*mut T` and `*const T` are basically the same. `&mut T` and `&T` compile down to pointers.
10.  If you want to accept both `&str` and `String`, you can try
```rust
fn is_strong<T: AsRef<str>>(password: T) -> bool {
    password.as_ref().len() > 5 {...}
}
```
1.   Dynamically sized types (DSTs) don't change sizes, but are assigned a size at runtime (like slices `[T]`).
2.   `while let Ok(_) {...}` loop until `f.read_exact(&mut buffer)` returns an `Err`.
3.   For commandline args use `std::env::args()` with `nth()`.
4.   `expect("foo")` is a nicer version of `unwrap()`.
5.   instead of 
```rust
pub fn hamming0(a: &str, b: &str) -> i32 {
    a.bytes()
    .zip(b.bytes())
    .map(|(a, b)| a != b)
    .fold(0, |acc, i| { acc + i as i32})
}
```
I can do
```rust
pub fn hamming0(a: &str, b: &str) -> i32 {
    zip(a, b)
        .filter(|(a, b)| a != b)
        .count()
}
```
and with `usize` instead of `i32` you can also get some speedups.

### 01/04/2022

1.   Ryan James Spencer kindly shared his article about [Magnifying glasses for Rust](https://www.justanotherdot.com/posts/magnifying-glasses-for-rust-assembly.html).

2.   Instead of stringly typed data, go for `enums`.
3.   `traits` are close to interfaces/contracts/type classes. 
```
impl trait Read {
    fn read(self: &Self, save_to: &mut Vec<u8>) -> Result<usize, String> // You need a func signature
}

impl Read for File {}
``` 
1.   `//!` is used  to document the thing that was just read by tehe compiler.
2.   `cargo doc --no-deps` can speed up doc generation by quite a while.
3.   There's a difference between a variable's `lifetime` and its `scope`. A variable can be dropped after it is consumed by a function
and not used, but then Rust can refuse to compile if you do try to use it.
1.   If I define functions like `fn foo(x: i32) -> Foo`, then I can `let a = 3; let a = foo(a);` and have the ownership passed because of the return type.

### 31/02/2022
1.   If I want to filter all BinaryBuilder platforms to only Linux, I can do
```julia
filter!(Sys.islinux(), supported_platforms())
```
instead of the `platforms = [ ... ]` dance.
1.   When using `rust.godbolt.com`, remember that 
```
use std::simd::*;
```
Is what let's your code compile and that you don't need a `main()`, just `pub fn` and you're on your merry way.
1.   Finally, here's the `dot_product_scalar_0` in [Rust Godbolt](https://rust.godbolt.org/z/q3f933T68), with a sweet view and `llvm-mca` to boot.
Here's the [SIMD Rust godbolt comparisons](https://rust.godbolt.org/z/jnbjxToE5) and the Rust snippet that worked
```
#![feature(portable_simd)]
#![feature(array_chunks)]
use std::simd::*;

// A lot of knowledgeable use of SIMD comes from knowing specific instructions that are
// available - let's try to use the `mul_add` instruction, which is the fused-multiply-add we were looking for.
#[target_feature(enable="sse")]
pub unsafe fn dot_prod_simd_2(a: &[f32], b: &[f32]) -> f32 {
    assert_eq!(a.len(), b.len());
    // TODO handle remainder when a.len() % 4 != 0
    let mut res = f32x4::splat(0.0);
    a.array_chunks::<4>()
        .map(|&a| f32x4::from_array(a))
        .zip(b.array_chunks::<4>().map(|&b| f32x4::from_array(b)))
        .for_each(|(a, b)| {
            res = a.mul_add(b, res);
        });
    res.reduce_sum()
}
```
Notice the `#[target_feature(enable="avx2")]`, the `pub unsafe`

1.   `fn dead_end() -> !{}` the `!` is for funcs that crash and is known as the `Never` type.


### 30/02/2022
1.   `All of Rust operators are defined within traits`. Ach so...
- variables are lowercase
- Single uppercase letters denote generic type variables
- Terms beginning with uppercase (`Add`) denote traits or concrete types, like `String/Duration`
- Labels `'a` are lifetime parameters

1.   `String` is to `Vec<u8>` as `str` is to `[u8]`.
2.   Array sizes are known at compile time `[T; 4]` - just a homogenous container. 
Slices don't have a known size at compile time `[T]`, so they have are usually used as `&[T]`, and are dynamically sized (but don't contract or expand at runtime!).
1.   The term `view` comes from databases where a read-only view is way faster without needing to copy. However, since Rust wants to know sizes of everything in your program, but slices don't know that, you need a `&` reference.
Vectors though, those are growable!
1.   You can ref a whole tuple:
```
    for &(i, line) in x.iter() { ... }
```
1.   `rustup doc` opens up the stdlib docs.

### 29/02/2022

1.   `std::ops::Add` is the trait, `std::ops::Add::add` is the operation. Thus, this snippet
```
    let mut sum = a
        .array_chunks::<4>()
        .map(|&a| f32x4::from_array(a))
        .zip(b.array_chunks::<4>().map(|&b| f32x4::from_array(b)))
        .map(|(a, b)| a * b)
        .fold(f32x4::splat(0.0), std::ops::Add::add) // Note it's not `std::ops::Add`
        .reduce_sum();
```

### 25/02/2022

438. When setting up `rust.code-workspaces`, you can ignore them if you do `git config --global core.excludesFile ~/.gitignore` and then add
```
*.code-workspace
```
to the file


### 24/02/2022

434. A neat `chunks` example:
```
    pub fn of_rna(&self, rna: &str) -> Option<Vec<&'a str>> {
        rna.as_bytes()
            .chunks(3)
            .map(str::from_utf8)
            .map(|seq| self.name_for(seq.unwrap()))
            .take_while(|&codon| codon != Some(STOP))
            .collect::<Option<Vec<&'a str>>()
}   
```

435. `stack.pop().and_then()` is very useful.
436. This was also a neat trick:
```
    for word in note.iter() {
        *words.entry(word).or_insert(0) += 1;
    }
```
437. Another useful pattern to create a `HashSet`:
```
pub fn is_pangram(sentence: &str) -> bool {
    let all:  HashSet<char> = HashSet::from_iter("abcdefghijklmnopqrstuvwxyz".chars());
    let used: HashSet<char> = HashSet::from_iter(sentence.to_lowercase().chars());
    all.is_subset(&used)
}
```
438. This is just neat syntactic sugar:
```
//impl<T: PartialEq + Add<Output = T> + Sub + PartialOrd + Default> Triangle<T> {
impl<T> Triangle<T> 
    where T: PartialEq + Add + Sub + PartialOrd + Default {
```
439. This is a useful pattern:
```
    arr.iter()
    .fold(HashMap::new(), |mut counts, word| {
    ...
    })
```



### 23/02/2022

433. Brushing up on some Rust via exercism and `hansrodtang` has some nifty code for an `isogram`:
```
use std::collections::HashSet;
pub fn check(candidate: &str) -> bool {
    let mut set = HashSet::new();
    candidate
    .to_lowercase()
    .chars()
    .filter(|c| c.is_alphabetic())
    .all(|c| set.insert(c))
}
```

### 15/02/2022

https://julialang.org/blog/2022/02/10years/
  * [x] https://xkcd.com/1053/

432. [PartialExecuter.jl](https://twitter.com/carlo_piovesan/status/1501949845795323910) Will interpret code and then kill it as an LLVM pass. VERY juicy Julia opportunities per method tables :D

### 14/02/2022

431. [Break Dancing: Low overhead, ARchiteture nuetral software branch tracing](https://storage.googleapis.com/pub-tools-public-publication-data/pdf/5aea197bdfb8a67288cf9801c7317bad920c2e2d.pdf)

### 04/02/2022

427. I found these `cargo shortcuts` [useful]() from the Cargo book:
```
rr = "run --release"
ti = "test -- --ignored"
tq = "test -- --test --quiet --test-threads 8"
tt = "test -- --test-threads 8 --test"
```
These cut down on the crate testing time.

428. BQN lists are written with the ligature character:
```
    +‿´‿∘‿×
⟨ + ´ ∘ × ⟩

    +‿´‿∘‿×  ≡  ⟨+,´,∘,×⟩
1
```

429. BQN exported names use `⇐`.

430. Trainsssssssss.

### 03/02/2022
426. `scanl` in Julia is `accumulate`. To solve this [Increasing Array](https://cses.fi/problemset/task/1094/) problem I would write
```julia-repl
xs = [1,3,5,1,7]
sol(xs) = accumulate(max, xs) - xs |> sum
```
and in BQN
```
Sol ← +´∘(⌈`-⊢) # Credit to Asher Mancinelli
```

### 22/02/2022
425. [Bodo Scholz](https://www.youtube.com/watch?v=RrCuUqKQhrw) Tensor comprehensions in SaC.

### 03/02/2022
423. Makie has a few tricks up its sleeve: 
- `on` to register listeners that update on a change to the observable
- `onany` to register a listener to many observables
- `connect!` to forward all updates from `obs1` to `obs2`
- Oh, Makie has `Keyboard.Button` for all possible interactions/clicks/presses. That's neat.

424. Pro-tip: When trying to figure out a package:
- look at what's exported to see what's available
```julia
# eg for Makie, I would have found this useful before wasting a few hours...
export Observable, Observable, lift, map_once, to_value, on, onany, @lift, off, connect!
```
- look at tests to see the typical idioms
- look at documentation

1.   wtf is this syntax yo
```julia
function updater(i, f::Flatten)
    function (val)
        #...
    end
end
```
omgggg
```julia
function (YOLO)
    YOLO + 1
end
```

### 02/02/2022
1.   `content` is useful for not indexing into the `contents(f[1,1])` figure in Makie.

### 30/01/2022
1.   Pluto autoreload trick:
```julia-repl
using Pluton: run
run(; auto_relaod_from_file=true);
```


### 28/01/2022
1.   To change the Julia prompt:
```
Base.active_repl.interface.modes[1].prompt = "julia 😷>"
```
credit to `rickhg12hs`.

1.   Damn, today was really cool. Sounds like Nautilus.jl project has some real legs. I got toggle buttons working but there's still so much to build.
Also, I blocked twitter and social media on my phone. Time to hunker down. Also this number is a good sign. I've started to do a small number of *impossible* things
before breakfast... I kinda like this streak.
1.   Joined Lemmster's TLA+ workshop last minute. Maybe I should try it out for realsies sometime.

### 25/01/2022
1.   Time to actually learn the freakin' commands to the Julia REPL:
- exit with `^d`
- Move to beginnign with `^A`, `^E` move to end
- `^R` is reverse search and `^S` is forward search
- `^F` is forward a word, `^B` is back a word
- `^-Space` sets a mark, `^X` swaps places with the mark, `^G` deactivates de mark
- `^-T` transposes chars with cursor, `meta-Up/down arrow` transpose line with one above
- `meta-u/c/l` change next word to uppercase, titlecase, lowercase
- `^/,`, `^_` undo previous edit
- `^W` delete word up to nearest whitespace, `meta-d` delete next work, `meta-backspace`

### 24/01/2022
1.   Jeebus I spent way too much time on Franklin blog today. 
2.   This [DataFrames.jl](https://www.ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v1.x_rev1.pdf) worksheet is super userful.

### 23/01/2022
1.   [Why meshgrid is inefficient](https://groups.google.com/g/julia-users/c/83Pfg9HGhGQ/m/9G_0wi-GBQAJ?pli=1) and what the Julia anternative is: 2D array copmrehension
```julia
inflate(f, xs, ys) = [f(x,y) for x in xs, y in ys]

# call version 1: with a named function
inflate(foo, xs, ys) 

# call version 2: anonymous function syntax
inflate((x,y) -> sin(x) + 2 * y^2 / cos(x,y), xs, ys)

# call version 3: with a do block
inflate(xs, ys) do x, y
    sin(x) + 2 * y^2 / cos(x,y)
end
```

### 21/01/2022
1.   GPU call with Julian. We can optimize the ffmpeg pipeline to reduce the critical path. We were doing:
- scale the intro video and poster video
- concat them
- encode to final product
When we can do instead
- scale the intro video once
- concat the poster video and the intro video on each invocation
- encode the final product.

1.   Tips for job interviews:
> When was the lat time you promoted someone on your team?
> Why did the last person leave?
> How do you nurture the wellbeing of people under a challenging environemnt?
> When was the last time you supported a direct report's growth, even if it meant leaving the company?
> Can I speak to some latino/women who have held this role before?



### 20/01/2022
1.   Got this oneliner for downloading from `JuliaCon talk title urllink.mp4`:
```
miguelraz@cyclops ~/J/src> bat posters.csv | awk '{print $NF}' | rg "mp4" |xargs  wget -v
```
And it would be parallel with a `xargs -n 1 -P 8 filename` to download with 8 cores simultaneously.

1.   Rescued the `ffmpeg` script for processing JuliaCon videos. Should shape into a nice package. Need to recruit CI wizards + a cron job so that it can be kicked on demand for uploads.

### 18/01/2022
1.   Let's help Simeon out with that globals PR. Maybe also the freakin' blog post. And then the LLVM13->LLVM14 upgrade.

### 15/01/2022
1.   FUTHARK BABY! Futhark is a Haskell-like, ML, pure functional language that is super parallel, compiles to GPUs and has a REPL! [It's just amazing](https://futhark-book.readthedocs.io/en/latest/random-sampling.html)
- OK Futhark is also in that Midsommar movie. Weird.

### 03/01/2022
1.   Limited Direct Execution - setup all the stuff for a program, run it's `main()`, free mem and process from task list. But how do you know it didn't do bad stuff, and how can you time share with that? The OS has facilities that can limit the running programs, otherwise it would be just another library.
2.   To go from `user` mode to `kernel` mode you need to use a `system call`, which looks like a normal C function. These functions use a `trap` instruction,and when done a `return from trap` instruction (while de escalating kernel privileges).
A bit of state from program counters, flags, registers and trap will be pushed into a per-process `kernel stack`, and popped when execution resumes. 
To know which code to run, the kernel sets up a `trap table` at boot time, which has code for when a keyboard interrupt or disk interrupt is sent, etc.
System calls must be made via a service number to increase security.
Also, regaining control of the CPU by the OS is tricky if there was a process running on it. You can cooperate and trust the process will make system calls eventually (and then do your OS things) or take over. You can use a `timer interrupt` that will disrupt the machine every few milliseconds and the OS interrupt handler takes over. This timer can also be TURNED_OFF! OS can also decide to switch... which is called a `context switch.`
1.   To context switch, save a few registers, pop a few registers, ^-_-^.
2.   Remember about `setting core affinity` - if you want to measure context switching timings, make sure it isn't switching across threads.

### 02/01/2022
1.   Process API:
* Create - 
* Destroy
* Wait
* Miscellaneous control
* Status
Process states: * Running, Ready, Blocked (or zombie, to check that children exited succesfully by the parent)
The Process List/task list will have a struct to keep track of all the running programs in the system. Also called a Process Control Block or process descriptor. (It's just a `struct`).
 1.   `./run-process.py` was a trip:
 ```
 -intro (master)> ./process-run.py -l 3:0,5:100,5:100,5:100 -S SWITCH_ON_END -I IO_RUN_LATER -c -p -L 5
Time        PID: 0        PID: 1        PID: 2        PID: 3           CPU           IOs
  1         RUN:io         READY         READY         READY             1          
  2        WAITING         READY         READY         READY                           1
  3        WAITING         READY         READY         READY                           1
  4        WAITING         READY         READY         READY                           1
  5        WAITING         READY         READY         READY                           1
  6        WAITING         READY         READY         READY                           1
  7*   RUN:io_done         READY         READY         READY             1          
  8         RUN:io         READY         READY         READY             1          
  9        WAITING         READY         READY         READY                           1
 10        WAITING         READY         READY         READY                           1
 11        WAITING         READY         READY         READY                           1
 12        WAITING         READY         READY         READY                           1
 13        WAITING         READY         READY         READY                           1
 14*   RUN:io_done         READY         READY         READY             1          
 15         RUN:io         READY         READY         READY             1          
 16        WAITING         READY         READY         READY                           1
 17        WAITING         READY         READY         READY                           1
 18        WAITING         READY         READY         READY                           1
 19        WAITING         READY         READY         READY                           1
 20        WAITING         READY         READY         READY                           1
 21*   RUN:io_done         READY         READY         READY             1          
 22           DONE       RUN:cpu         READY         READY             1          
 23           DONE       RUN:cpu         READY         READY             1          
 24           DONE       RUN:cpu         READY         READY             1          
 25           DONE       RUN:cpu         READY         READY             1          
 26           DONE       RUN:cpu         READY         READY             1          
 27           DONE          DONE       RUN:cpu         READY             1          
 28           DONE          DONE       RUN:cpu         READY             1          
 29           DONE          DONE       RUN:cpu         READY             1          
 30           DONE          DONE       RUN:cpu         READY             1          
 31           DONE          DONE       RUN:cpu         READY             1          
 32           DONE          DONE          DONE       RUN:cpu             1          
 33           DONE          DONE          DONE       RUN:cpu             1          
 34           DONE          DONE          DONE       RUN:cpu             1          
 35           DONE          DONE          DONE       RUN:cpu             1          
 36           DONE          DONE          DONE       RUN:cpu             1          

Stats: Total Time 36
Stats: CPU Busy 21 (58.33%)
Stats: IO Busy  15 (41.67%)
 ```
1.   `wait` waits on a PID, `fork` makes a copy except for the PID, `exec` runs a different program than the calling program. There are several variatns of `exec`.
2.   Colorful man pages with: `export MANPAGER="less -R --use-color -Dd+r -Du+b"`
3.   If you want to use `exec`, you hand craft a vector for 
```
char *myargs[3];
myargs[0] = strdup("wc");
myargs[1] = strdup("p3.c");
myargs[2] = NULL; // marks end of array
execvp(myargs[0], myargs);
printf("This never gets printed");
```
This literally transforms your program into the new one you are calling. Succesful calls to `exec` never return o.0.
1.   Huh, `killall` seems like a useful thing to know...
2.   List available `man` pages with `man -f ls`
### 01/01/2022

- OK so the reason  this is exists `p->x++;` is because the precedence here is so annoying:`(*p).x++`. Thank the lord for [Learn-C online](https://www.learn-c.org/en/Dynamic_allocation)
- malloc returns a void pointer, so if you write 
```c
person *myperson = (person *) malloc(sizeof(person));
```
then you've typecasted it.
- neat exercies for dealing with linked lists: `pop_last`, `pop_first`, `push`, `print_list`, `pop_by_index`
- understand the `DFS-search` algo
- DEAREST LORD BLESS OSTEP!!!

### 16/12/2021
- Messing around with typed globals...

### 15/12/2021
- `libc++` and `libstdc++` can be upgrade via pacman
- NEVER upgrade with `pacman -Sy foo` - that's a partial upgrade and will breakshit.
- Another day, another time that trying to install Emery Berger's MESH allocator fails :/
- `mold` went 1.0 today! Submitted a patch to make a BBuilder recipe.

### 13/12/2021

1.   Found thise great code review checklists:
- [michaelgreiler.com](https://www.michaelagreiler.com/wp-content/uploads/2020/05/Code-Review-Checklist-Michaela-Greiler.pdf)
- C++20 before [and after ranges](https://mariusbancila.ro/blog/2019/01/20/cpp-code-samples-before-and-after-ranges/)
- University of Champagna Illinois Systems C [programming book course](https://raw.githubusercontent.com/illinois-cs241/coursebook/pdf_deploy/main.pdf)
- TODO An introduction to [libuv](https://nikhilm.github.io/uvbook/threads.html)
- TODO [libuv advanced tutorial](https://unixism.net/loti/ref-liburing/advanced_usage.html)

1.   CLANGD IS NOT INCLUDED IN A CLANG INSTALLATION. Just install the VSCode IDE thing for [christ sake's](https://clangd.llvm.org/installation)

2.   Holy crap - [modules in cpp20](https://itnext.io/c-20-modules-complete-guide-ae741ddbae3d) can help cut down bloat size IMMENSELY: this is like 5 orders of magnitude for a "hello world" program.
- To compare this: write the "hello world with 'import <iostream>' and '#include <iostream>' directives swapped out, compile with:
> clang++ -std=c++20 -stdlib=libc++ -E hello_world.cc | wc -c # Here the -E makes clang only spit out the preprocessor stuff.
> 1956614

vs
> clang++ -std=c++20 -stdlib=libc++ -fmodules -fbuiltin-module-map -E hello_modular_world.cc | wc -c
> 239

### 30/11/2021

1.   [New PATCH 1.7!](https://julialang.org/blog/2021/11/julia-1.7-highlights/) and contained this lil' nugget:
```julia
myreal((; re)::Complex) = re
myreal(2 + 3im) == 2
```

### 25/11/2021

1.   Jean Yang kindly suggested [Write you a Scheme in 48 hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours/First_Steps) as a stream with a timer, it sounds RAD!
2.   [This Haskell setup video](https://www.youtube.com/watch?v=5p2Aq3bRuL0) looks fantastic by using
- ghcid (reloading REPL)
- hlint (suggests better patterns and helps explore stdlib)
- don't mess with cabal/stack when starting

### 22/11/2021

1.   TODO: Make a BinaryBuilder.jl recipe for [CReduce](https://github.com/maleadt/creduce_julia), get some fuzzing going in Julia.

### 29/10/2021

1.   In [LLVM speak](https://www.cs.cornell.edu/%7Easampson/blog/llvm.html),Modules > Functions > BasicBlock > Instruction, and everything inherits from the `Value` class.
2.   Useful snippet:
```cpp
for (auto& B : F) {
  for (auto& I : B) {
    if (auto* op = dyn_cast<BinaryOperator>(&I)) {
      // Insert at the point where the instruction `op` appears.
      IRBuilder<> builder(op);

      // Make a multiply with the same operands as `op`.
      Value* lhs = op->getOperand(0);
      Value* rhs = op->getOperand(1);
      Value* mul = builder.CreateMul(lhs, rhs);

      // Everywhere the old instruction was used as an operand, use our
      // new multiply instruction instead.
      for (auto& U : op->uses()) { // NICE
        User* user = U.getUser();  // A User is anything with operands.
        user->setOperand(U.getOperandNo(), mul);
      }

      // We modified the code.
      return true;
    }
  }
}
```
- `dyn_cast<T>(p)` is a LLVM `typeof` that is very efficient.
- `IRBUilder` has a gajillion methods for constructiong instructions


### 23/10/2021

1.   When reading LLVM source code, I need to find the name of many things (like using your IDE for tooltip hovering/documentation). `ctags` can help with that. 
- Go into the `llvm` src dir, run `ctags -e -R .` and a `TAGS` file will be made.
- I keep a terminal tab open in the `llvm` src dir, and then do `vim -t LLVM_READNONE` to have Vim open up where `LLVM_READNONE` is defined.
- That way, I don't need to fish everywhere for what symbols/functions mean

### 22/10/2021

1.   Phew, moving out was a hassle.
- `llvm-config` is very useful for knowing if your LLVM build was built with `shared libs`, `run time type info`, `split debug` and all that stuff.

### 23/09/2021

1.   Downloaded a code with CVS today. 

### 19/09/2021

1.   Fortran `coarrays` use `tile_indices`, `this_image()`, `num_images()` and are run with `cafrun -n 4 ./test`. 
- `gather(size(ids))[*]` and `real, allocatable :: gather(:)[:]` with `[*]` means a coarray.
- coarrays are synced with `sync all`.
- `real, codimension[*] :: a` == `real :: a[*]`, a coarray scalar.
- `real, dimension(10), codimension[*] :: a` == `real :: a(10)[*]`
- `real, dimension(:), codimension[:], allocatable :: a` == `real, allocatable :: a(:)[:]`
- `sync` is triggered on all `allocate` and `deallocate` of coarrays.
- `a[2] = 3.141`
- Needed to install [OpenCoarrays](https://github.com/sourceryinstitute/OpenCoarrays/blob/main/INSTALL.md#advanced-installation-from-source) to get `caf hello_images.f90 -o hello_images` and `cafrun -n 4 hello_images` to run. Wasn't bad at all.
- This is a remote copy: `h(ime)[left] = h(ils)`
### 18/09/2021

1.   FORTRAN learnigns:
-`&` is used for line breaks
- `parameter` is for constants
- functions and subroutines are procedures - subroutines are with `call add(a, 3)`, modify args in place, functions can only return 1 value
- `do concurrent (i = 2:grid_size)` is for SIMD stuff/parallelism
- `contains` separates the program code from functions/subroutines
- `implicit none` is to stop fortran from making integers from variables that start with I/J/K/N etc.
- `intent(in)` declares that the vars are provided by the calling program or procedure, and their values won't change inside this function.
- you can specify data type result and name
```fortran
integer function sum(a, b) result(res)
    integer, intent(in) :: a, b
    res = a + b
end function sum
```
- `intent(out)` value is assigned inside the procedure and returned to the calling program
- `intent(in out)` given to the proc, can be modified. Always specify intent for all args.
- `elemental` allows the scalar dummy args to be treated as arrays - nice!
```fortran
integer elemental function sum(a,b)
    integer, intent(in) :: a, b
    integer, intent(out) :: res
    res = a + b
end function sum
```
- `optional` is useful for `debug` scenarios, may not be defined at all.
```fortran
subroutine add(a, b, res, debug)
    integer, intent(in) :: a, b
    integer, intent(out) :: res
    logical, intent(in), optional :: debug
    
    if (present(debug)) then
        if (debug) then
        ! ...
    end if
    ! ...
end subroutine add

! used with 
call add(3, 5, res, .true.) ! or call add(3, 5, res, debug=.true.)
```
- some barebones [functional FORTRAN](https://github.com/wavebitscientific/functional-fortran) exists and oh lord.
- `use iso_fortran_env` for constants and compiler version and options:
```fortran
program opts
    use iso_fortran_env
    implicit none
    print *, 'Compiler version: ', compiler_version()
    print *, 'Compiler options: ', compiler_options()
end opts
```
- `gfortran -fcheck=all -g -O0 -fbacktrace` leads to: all runtime checks (array bounds), debugger info, disable any optimizations, print useful tracebacks.
- debug in dev, optimize in prod
- other built-in modules are `ieee_arithmetic/exceptions/features`
- you can specify types of nums with `integer(kind=i32) :: n` and `real(kind=real32) :: dt` or `integer(i32) :: n` more concisely
- `use iso_fortran_env, only: int32, real32` which are "more portable" and preferred by the smart kids.
- Define one module per source file:
```
module mod_diff

end module mod_diff
```
- to compile several modules, do mods, then main: `gfortran mod_diff.f90 tsunami.f90 -o tsunami`
- `use mod_ocean, only: temperature_ocean => temperature` with `=>` as alias
- Best practices for [Fortran Arrays](https://www.fortran90.org/src/best-practices.html#arrays)
- implicit vs explicit shaped arrays, you can get to do:
```fortran
integer :: r(5)
r = [1,2,3,4,5]
```
- ARRAYTIPS: Access as `v(:, 1), v(:, :, 1)` - colons on the left for contiguous strides.
- OPENMP example: (remember to set `OPEN_MP_THREADS=8` in your bash env or something)
```
program testopenmp
  use omp_lib
  implicit none

  integer :: nthreads

  nthreads = -1
  !$ nthreads = omp_get_num_threads()
  print *, "nthreads = ", nthreads
end program
```
and remember to `gfortran testopenmp.f90 -o openmp -fopenmp`
- this is a static array: `real :: h(grid_size)` and can be exploited by the compiler.
- `real, allocatable :: h(:)` <- this is a dynamic/allocatable array
- `character(len=4)` to set a max length for the string
- `['AAPL', 'IBM']` ! initialized the stock symbols
- concat strings with `'this ' // 'syntax' // ' plz'`
- avoid `save implicit` behavior.
- these:
```fortran
integer :: a(5) = [1,2,3,4,5]
! and these
integer :: a(5)
a = [1,2,3,4,5]
```
are equivalent.
- `a = [(i, i = 1, 100)]` is sugar for 
```fortran
do i = 1, 100
    a(i) = i ! integer, allocatable :: a(:)
end do
```
- `[integer ::]` or `[real ::]` makes an empty array, useful for invoking a generator.
- `character(*)` is an `assumed-length` character string.
- `allocate(a(im))` tells FORTRAN to allocate an array of size `im`.
- `allocate(a(-5:10))` can have first index as -5 :D
- `mold/source` - help allocate array from another array. `mold` mimics type + doesn't initalize, `source` copies elements.
- auto reallocation:
```fortran
integer, allocatable :: a(:)
a = [integer ::]
a = [a, 1] ! a = [1]
a = [a, 2] ! a = [1, 2]
a = [a, 2* a] ! a = [1, 2, 2, 4]
```
arrays are autodeallocated on scope drop.
- `allocate(u(im), stat=stat, errmsg =err)`, check for `allocated(a)`.
- `arr(5:10:2)` results in `array = [5, 7, 9]`
- `a(10:)` is from 10 on, `a(:10)` up to 10, `a(::3)` every 3rd element
- `pack(x, mask)` allows you return elements only where `mask` is true. common idiom is to do `res = pack(res, ...)` to have autorealloc.
```fortran
! reversing an array
pure function reverse(x)
    real, intent(in) :: x(:)
    real :: reverse(size(x))
    reverse = x(size(x):1:-1)
end function reverse
```
- arrays are Fortran's only builtin data structure
- clauses for openmp: `shared,nowait, if, reduction, copyin, private, firstprivate, num_threads, default`







### 01/09/2021

1.   TODO [Visualize the Julia repo with this tool](https://discourse.julialang.org/t/this-tool-for-understanding-repos-is-brilliant/67226/5)

### 27/08/2021
1.   Writing a cover letter... godspeed to me.

### 16/08/2021

Link dump time!
1.   Linux [perf guide](https://twitter.com/derKha/status/1426195407395299329).
2.   [Go fix some DiffEq compile times yo](https://discourse.julialang.org/t/22-seconds-to-3-and-now-more-lets-fix-all-of-the-differentialequations-jl-universe-compile-times/66313)
3.   [Semver autodetection in Rust](https://github.com/rust-lang/rust-semverver)
4.   [Plz someone help out Keno with Cxx.jl](https://compiler-research.org/assets/presentations/K_Fischer_Cxx_jl.pdf)
5.   [Amos Rust futures post](https://fasterthanli.me/articles/understanding-rust-futures-by-going-way-too-deep)

### 11/08/2021

1.   Jon Sterling writes about a metalanguage for `multi phase modularity` [here](https://twitter.com/jonmsterling/status/1423655072303489024).
2.   Consider using `TimeWarrior`[linked here](https://timewarrior.net/docs/what/).
3.   Dr. Devon Price [has an amazing article criticizing the biological understanding of mental health:](https://devonprice.medium.com/no-mental-illness-isnt-caused-by-chemicals-in-the-brain-1b01d6808871).

### 04/08/2021

1.   Parallel Julia priorites from the State of Julia 2021 talk:

| Features/Correctness            | Performance                       |
| ------------------------------- | --------------------------------- |
| Thread safety: Distributed      | Optimize scheduler                |
| thread safety: package loading  | Parallel mark/sweep               |
| Memory model                    | Type inference of `fetch(::Task)` |
| Finalizer thread                | Better for loop and reduce        |
| Interactive threads             | BLAS integration                  |
| GC state transitions in codegen | TAPIR Integration                 |

1.   Compiler priorities from State of Julia 2021:

Latency related:

- Staged JIT, faster interpreter
- Caching code
- Subtyping an dmethod-lookup optimizations

System images and other build artifacts:

- Faster and easier sysimg builds
- separate LLVM/codegen from runtime
- strip debug info, IR
- Tree shaking
- Language support for separate compilation

Array optimizations

GC performance work

Compiler extensibility

1.   `ghostscript` can be used for batch pdf processing.
 

### 03/08/2021

1.   All the JuliaCon posters are uploaded! 🎉 I heard a lot of interesting proposals from people from NZ, photolithography people and many others... posters are fun! Life's lookin' good!

### 02/08/2021

1.   Extract 20 seconds without re-encoding:
```bash
ffmpeg -ss 00:01:30.000 -i YOUR_VIDEO.mp4 -t 00:00:20.000 -c copy YOUR_EXTRACTED_VIDEO.mp4
```
1.   Tuning options in ffmpeg:
```
film – use for high quality movie content;
animation – good for cartoons;
grain – preserves the grain structure in old, grainy film material;stillimage – good for slideshow-like content;
fastdecode – allows faster decoding by disabling certain filters;
zerolatency – good for fast encoding and low-latency streaming;
psnr – only used for codec development;
ssim – only used for codec development;
Example: 
ffmpeg -i your_video.mov -c:v h264 -crf 23 -tune film your_output.mp4
```
1.   You can use 2 pass encoding for targeting a specific output file size, but not care so much about output quality from frame to frame.
2.   `For an output that is roughly 'visually lossless' but not technically and waaaay less file size, just use -crf 17 or 18`.
3.   You can also constrain the maximum bitrate (useful for streaming!)
```
ffmpet -i input.mp4 -c:v h264 -crf 23 -maxrate 1M -bufsize 2M output.mp4
```
1.   Recommend adding a `faststart` flag to your video so that it begins playing faster (recommended by YouTube).
```
ffmpeg -i input.mp4 -c:v h264 -crf 23 -maxrate 1M -bufsize 2M -movflags +faststart output.mp4
```
1.   If you want to produce 1080p and above, h265 offers great savings in bitrates/file size (ntoe: needs to be built with `--enable-gpl --enable-libx265`).
```
ffmpeg -i input -c:v libx265 -crf 28 -c:a aac -b:a 128k output.mp4
```
1.   h266 video codec: 
- with h265, to transmite a 90min UHD file, it needs about 10 gigabytes of data
- with h266, you need only about 5 gigabytes.
Can deal with 4k/8k and 360 degree video!

1.   VP8 videos: Supposed to be web standard.
2.   OF COURSE Google made vp9 in direct competition of h265, you need `libvpx-vp9`.
3.   OH LORD Youtube recommends it's own [ffmpeg settings!!!](https://developers.google.com/media/vp9/settings/vod)
4.   AV1 video - SD and HD under bandwidth constrained networks.
5.   Netflix codedc is SVT-AV1 and they [have blog posts explaining it](https://netflixtechblog.com/svt-av1-an-open-source-av1-encoder-and-decoder-ad295d9b5ca2), as well as github repos!
6.   AV1AN exists becuase AV1/VP9/VP8 are not easily multithreaded ... 😕 
7.   RTMP is for "Real time Messaging Protocol" and is the de facto standard for all live videos in FB, Insta, YT, Twitch, Twitter, Periscope etc. Streaming pre recorded video to live can be done in at least 2 ways:
- take input file "as is" and convert in real time to FLV (and stream it live via:)
```
-f flv rtmp://a.rtmp.youtube.com/live2/[YOUR_STREAM_KEY]
#: this will instruct FFMPEG to output everything into the required FLV format to the YouTube RTMP server
```

1.   PRE PROCESS FILES IN BATCH: pg 113/122
```
for i in *.mov; do ffmpeg -i "$i" -c:v libx264 -profile:v high -level:v 4.1 -preset veryfast -b:v 3000k -maxrate 3000k -bufsize 6000k -pix_fmt yuv420p -r 25 -g 50 -keyint_min 50 -sc_threshold 0 -c:a aac -b:a 128k -ac 2 -ar 44100 "${i%.*}.mp4"; done
```
"The above example script will pre-process every .movfile contained in the directory, in line with the YouTube's requirements for streaming a Full-HD 1080p at 25FPS."


### 31/07/2021

1.   `tmux` can be used to keep persistent sessions on `ssh`, so `mosh` is not necessarily needed.
The way to do this (Credit to Danny Sharp) is do the ssh inside a tmux session and then
`tmux ls` to see which sessions you have made and then `tmux attach-session -t 3` to connect to session 3.
This is a smart way of checking in on long running compute jobs.
1.   From `FFMPEG Zero to Hero`:
```
BITRATE: Bitrate or data rate is the amount of data per
second in the encoded video file, usually expressed in kilobits per second (kbps)
or megabits per second (Mbps).  The bitrate measurement is also applied to audio files.
An Mp3 file, for example, can reach a maximum bitrate of 320 kilobit per second,
while a standard CD (non-compressed) audio track can have up to 1.411 kilobit per 
second. A typical compressed h264 video in Full-HD has a bitrate 
in the range of 3.000 - 6.000 kbps, while a 4k video can reach
a bitrate value up to 51.000 kbps.  A non-compressed video format,
such as the Apple ProRes format in 4K resolution, can reach a bitrate of 253.900 kbps and higher. 
```
1.   FFMPEG can read and write to basically any format under the sun, and has been designed by the MPEG:
`Moving Pictures Expert Group`.

### 29/07/2021
1.   To run code with the interpreter, use `julia --compile=no`.
2.   [Buffy](https://github.com/openjournals/buffy) for JOSS submissions.
3.   [Crafting Interpreters](https://craftinginterpreters.com/) for speeding up the Debugger and such.
4.   [Advance bash scripting guide](https://tldp.org/LDP/abs/html/)
5.   [Proceedings Bot](https://discourse.julialang.org/t/juliacon-2021-proceedings/55354)
6.   [Toby Driscoll online book](https://tobydriscoll.net/fnc-julia/linsys/efficiency.html)

### 28/07/2021
1.   Link dump:
https://lazy.codes/posts/awesome-unstable-rust-features/
https://github.com/koalaman/shellcheck
https://github.com/Apress/beginning-cpp20/blob/main/Exercises/Modules/Chapter%2002/Soln2_01A.cpp
https://rustc-dev-guide.rust-lang.org/

### 21/07/2021
1.   To clean up a video with ffmpeg, do:
```
ffmpeg -i elrodtest.mov -af "highpass=f=300, lowpass=f=3000, afftdn" -c:v copy passeselrod.mov
```
This applies a FFT filter, with a highpass and lowpass of 300Hz and 3000Hz
1.   This is an awesome thread on [LLVM resources](https://twitter.com/matt_dz/status/1417857422559952897)
And WOW is [this super list thorough LLVM Program Analysis resources](https://gist.github.com/MattPD/00573ee14bf85ccac6bed3c0678ddbef#introduction)

### 20/07/2021

1.   [sortperm is sorta slow](https://github.com/JuliaLang/julia/issues/939) - up for grabs!
2.   [Setup donation links to JuliaCon](https://twitter.com/Anno0770/status/1414009622583783432)
3.   [Submit to the procceedings...](https://proceedings.juliacon.org)
4.   FFMPEG is HUGE ! Here's what I needed to concat 2 videos together:
```bash
ffmpeg -i "concat:input1.ts|input2.ts" -c copy output.ts
```
Now I need to apply that to every `*.mov/mp4/mkv` video in the folder and then I have a lot of processed videos. Perhaps I should also dump that info into a CSV file...

### 14/07/2021
1.   Federico Simonetta [asks](https://julialang.slack.com/archives/C67910KEH/p1626281444356200):
```
Dummy question: if I have T=Vector{Int32}, I can get the inner type using eltype. How can I get the outer type? (i.e. Vector so that I can create a new Vector but using a different inner type?)
```
Which I think Erik Schnetter wanted since a [long time ago.]
There's now a Base method [for this]():
```julia
Base.typename(T).wrapper # credit to Jakob Nissen
```
But name is being bikeshed currently.

If you want to use `CustomType{Matrix{Float32}}`, Rackauckas says that 
```julia
Base.@pure __parameterless_type(T) = Base.typename(T).wrapper
```
can be used, instead of `SciMLBase.parameterless_type(T)`.

Matt Bauman is convinced it's a footgun, and we should just stick to using `similar(x, AnotherType)` instead.

1.   Conor Hoekstra nerdsniped me into learning some APL - here's my attempt for printing 'Even' or 'Odd' depending on a summation
```
      EvenOrOdd←{(1+2|(+/⍵))⌷ 'Even' 'Odd'}
      EvenOrOdd 1
┌───┐
│Odd│
└───┘
      EvenOrOdd 1 1
┌────┐
│Even│
└────┘
```
There's oodles more to learn [here](https://problems.tryapl.org/) and [here](https://tryapl.org/#).

1.   Right, the [Chen Long](https://www.math.uci.edu/~chenlong/lectures.html) courses exist. And the Barba CFD Python course. And the Leveque book... sigh.


### 09/07/2021
- [Should read George's appying to a PhD guidea](https://github.com/gwisk/gradguide) at some point...

### 06/07/2021
- [Brendan Greg on performance](https://brendangregg.com/blog/2021-07-05/computing-performance-on-the-horizon.html) on the horizon.
- [How a computer should talk to people by M. Dean](https://twitter.com/TartanLlama/status/1409834646087606276) and posted by Sy Brand.
- Move recs by the amazing `@JoyOfPhysics:`
```
Depends on what subgenres you like! Besides the Jordan Peele horror you mentioned, 
 I always recommend 
 A Girl Walks Home Alone At Night,
 Creep and Creep 2, 
 Blackcoat’s Daughter, 
 It Comes At Night, 
 REC (the Spanish original)...
 
  The Ritual and Midsomma
```
- [Learning J book](https://www.learningj.com/book.htm#toc)
- [Ran into the Puffin profiler written in Rust](https://github.com/EmbarkStudios/puffin) looks cool!

### 29/06/2021
- There's a Rust based client for neovim: `neovide`. Looks cool.

### 28/06/2021
- Found the Bret Contreras [Triangle approach](https://bretcontreras.com/wp-content/uploads/PDF_DOWNLOAD_BcPyramid.pdf) useful. Should set that up for 6 muscle groups, 2 times a year.
- ... I need to start a workout diary.

### 27/06/2021
1.   [Loop invariants](https://www.cs.toronto.edu/~ylzhang/csc236/files/lec08-loop-invariant.pdf) have 3 steps:
- you have a loop with `E` a loop guard and body `S`
```
while E:
    S
```
- You then initialize the loop, see that the LI condition holds with the guard `E` and the precondition.
- You then prove that if the Loop Invariant condition holds before the i-th iteration of the loop, it holds in the i+1-th iteration of the loop
- At the end, you use the negation of `E` and the LI to affirm something useful about the program (most likely, the post condition).
  * Merge Sort example:
    - Hardest part is thinking of the LI in the first place.
    - "For arrays L and I, L[i] and R[j] hold the smallest elements not in S (target vector)"

### 26/06/2021
1.   TLA+ Loop invariants here we go...


### 25/06/2021
1.   [Leiserson course]() is level 1, [Design and analysis of algorithms is level 2](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-046j-design-and-analysis-of-algorithms-spring-2015/index.html), Jelani course is level 3.
2.   [Nancy Lynch distributed algorithms course](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-852j-distributed-algorithms-fall-2009/index.htm)
3.   Ooooh [Self adjusting binary search trees](https://dl.acm.org/doi/10.1145/3828.3835)
4.   [MITOCW: Matrix Methods in Data Analysis, Signal Processing and Machine Learning](https://ocw.mit.edu/courses/mathematics/18-065-matrix-methods-in-data-analysis-signal-processing-and-machine-learning-spring-2018/index.htm)
5.   [Doom config by Fausto Marques](https://www.reddit.com/r/DoomEmacs/comments/o0gqoi/any_julia_users_here_to_help_a_n00b/) for julia... should read it sometime...

### 24/06/2021
1.   Asesorias online de la fac...
2.   LLVM has options to investigate base language code coverage with `llvm-profdata` and `llvm-cov` tooling.
3.   Reading atomic habits - this blog works well as a braindump, but it would be a good idea to include reflections and reviews on proposed monthly and weekly goals on maths, physics, computing projects, physical activity and life.

### 23/06/2021
1.   God I want [to tkae the Algorithm Engineering 2021](https://people.csail.mit.edu/jshun/6886-s21/) course so bad... or at least translate it.
2.   Mosè posted about [Reproducible build academic guidelines](https://reproducible-builds.org/docs/).
3.   [RISC V course!](https://training.linuxfoundation.org/training/introduction-to-riscv-lfd110x)

### 22/06/2021

1.   Viendo el tutorial de Ploomber de Eduardo Blancas - Deberías cachear el pipeline de datos de tal manera que si afectas un nodo del DAG computacional, el resto no necesiten recalcularse. Technically same mechanism as cached parallel tests.
2.   Julia 1.7 has implicit multiplication of radicals! `xSQ3y` works! Also `(; a, b) = x` can destructure `x`.
3.   [MPI Formal TLA+ spec!](http://formalverification.cs.utah.edu/mpitla/MPI_semantics_v0.8.2.pdf) + [formal lab link](http://formalverification.cs.utah.edu/mpitla/)
4.   [Practical Specification course!](https://web.cecs.pdx.edu/~apt/cs510spec/).
5.   Safety - something bad never happens. Liveness - something initiated/enabled eventually terminates.


### 21/06/2021

1.   [Julia macros for beginners](https://jkrumbiegel.com/pages/2021-06-07-macros-for-beginners/): `esc` means "treat this variable like a variable the user has written themselves." AKA interpolating within the macro only gives you variables local to the macro's module, escaping treats it as a user variable.
- Before writing a macro for an expression, try to understand it first with `Meta.@dump`.
- A good check for correct escaping is passing in local variables.
```julia
julia> module m
           export fill
           macro fill(exp, sizes...)
               iterator_expressions = map(sizes) do s
                   Expr(
                       :(=),
                       :_,
                       quote 1:$(esc(s)) end
                       )
               end
               Expr(:comprehension,
                   esc(exp),
                   iterator_expressions...
                   )
           end
       end
Main.m

julia> Main.m.@fill(rand(3), 5)
5-element Vector{Vector{Float64}}:
 [0.7935931741613422, 0.009320195062872738, 0.586287521697819]
 [0.5090383286377023, 0.8500671589320301, 0.023782332100151793]
 [0.31575252460961667, 0.30058298960206287, 0.2873940760156002]
 [0.07225330666900165, 0.22506420288160234, 0.225626098738561]
 [0.5753508713492259, 0.37821541454348995, 0.3146472409806831]
```
1.   `Dr. Takafumi Arakaki` has some good recommendations on globals - mark them inside functions!
```julia
julia> global a = 1;

julia> good() = global a += 1;

julia> bad() = a += 1;

julia> good()
2

julia> bad()
ERROR: UndefVarError: a not defined
```
1.   Try to also avoid this idiom:
```julia
function consumer()
    id = threadid()
    report = 0
    println("I'm consumer $(threadid())")
    ...
```
Instead try doing
```julia
for id in 1:numProducers
    @spawn producer(id)
end
```
He also recommends that "while debugging, you'd probably wan tto show the error from producers and consumers like this"
```julia
@spawn try
    producer()
catch err
    @error "Unexpected error from a producer" exception = (err, catch_backtrace())
    rethrow()
end
```
1.   Neat trick - don't use `while true` loops in the beginning 😅 . Use `for _ in 1:10_000` to check if the threads are even alive.


### 20/06/2021

1.   I read [Lamports Logical Clocks](https://lamport.azurewebsites.net/pubs/time-clocks.pdf) paper today. I learned a couple of things.
- To totally order all events in a distributed system, you only need each process to keep a counter of its own events, and send events with its own timestamp. If you get a timestamp equal or higher than your own, then you bump your up to that amount.
- However, these total orderings can be "unsynched" from the real world - if you include some small perturbations in your timestamps, you can, within bounded time (and quite fast) always synchronize your system.
1.   Now reading [Paxos Paper](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf).
- To coordinate proposals of a value, it's good to keep a threshold counter and reject proposals which are inferior to that.
- [Fischer, Lynch, and Patterson]() implies that " a reliable algoritm for eledcting a proposer must use either randomness or real time -- for example, by using timeouts."
1.   `CHOOSE` is nondeterministic - if it chose 38 today, it will choose that again next week. You never need to write `x' = CHOOSE i \in 1..9 : TRUE`, just use `x' \in 1..99`. Use `CHOOSE` only when there's exactly 1 `v` in `S` satisfying formula `P`, like in the definition of `Maximum(s)`
```
Maximum(S) == IF S = {} THEN -1
              ELSE CHOOSE x \in S : \A m \in S : x \geq m
```
1.   The `ASSUME` statement is made for assumptions about the constants
2.   `SUBSET Acceptor` == `PowerSetOf(Acceptor)`.
3.   `EXCEPT` can be chained!
```
       /\ aState' = [aState EXCEPT ![m.ins][acc].mbal = m.bal,
                                   ![m.ins][acc].bal  = m.bal,
                                   ![m.ins][acc].val  = m.val]
```
1.   This is also legit:
```
Phase1b(acc) ==  
  \E m \in msgs : 
    /\ m.type = "phase1a"
    /\ aState[m.ins][acc].mbal < m.bal
    /\ aState' = [aState EXCEPT ![m.ins][acc].mbal = m.bal]
    /\ Send([type |-> "phase1b", 
             ins  |-> m.ins, 
             mbal |-> m.bal, 
             bal  |-> aState[m.ins][acc].bal, 
             val  |-> aState[m.ins][acc].val,
             acc  |-> acc])
    /\ UNCHANGED rmState

```
1.   Elements of a `Symmetry Set` may not appear in a `CHOOSE`.
2.   `ASSUME` must be a constant formula.
3.   Specs hold as undefined all values of all variables not used at all times. It's best not to think of specs as programs which describe the correct behaviour of the system. The describe a universe in which the system and its environment are behaving correctly.   
4.   Steps that leave are variable values unchanged are called `stuttering steps`. Including stuttering steps helps us say what a system *may* do, but now we want to specify what a system *must* do.
5.   A finite sequence is another name for `tuple`.
6.   [Alternating Bit](https://lamport.azurewebsites.net/video/ABSpec.tla) protocol: Let's say you have users A and B. If A sends to B 4 strings, how can B detect if A sent repeated strings multiple times? There is no way to tell apart `Fred, Mary, Mary, Ted, Ted, Ted, Ann` from `Fred, Mary, Ted, Ann`. You could timestamp it, but let's not. It's easiest to just append a bit that flips after every message. Appending a bit can be done with
```
TypeOK == /\ Data \X {0, 1} \* where \X is the cartesian product
```
1.   To talk about `may/must`, we will talk about liveness and Safety properties.
- `Safety Formula`: Asserts what may happen. Any behavior that violates it does so at some point. Nothing past that point makes nay difference.
- `🔷 Liveness / eventually Formula`: Asserts only what must happen. A behavior can *not* violate it at any point. Only liveness property sequential programs must satisfy is `🔷Terminated`
- Weak fairness of Action A: if A ever remains continuously enabled, then A step must eventually occur. Equivalent - A cannot remain enabled forever without another A step occurring. It's written as `WF_vars(A)`
  - A spec with liveness is writeen as `Init [][Next]_vars /\ Fairness`
  - Have TLC check the liveness property by clicking on the `Properties` part of the toolbox and then `\A v \in Data \X {0,1} : (AVar = v) ~> (BVar = v)`.
1.   Now on to the full [AB Protocol](https://lamport.azurewebsites.net/video/AB.tla)
2.   `Strong Fairness` of action A asserts of a behavior: 
    - If A is ever `repeatedly enabled`, then an A step must eventually occur.
    - Equivalently: A cannot be repeatedly enabled forever without another A step occurring.
    - Weak fairness gives you the possibility of your enabling condition being flip-flopped forever. Strong fairness guarantees if you are enabled repeatedly, A must occurr.
3.   What good is liveness? What is the good in knowing that something eventually happens in 10^6 years? This is good if there's no hard real time requirements.
4.   Recursive declarations must be prepended with `RECURSIVE`
```
RECURSIVE RemoveX(_)
RemoveX(seq) == IF seq = << >>
                THEN << >>
                ELSE IF Head(seq) = "X"
                     THEN RemoveX(Tail(seq))
                     ELSE <<Head(seq)>> \o RemoveX(Tail(seq))
```
1.   The Temporal Substitution law: can't do the basic maths trick have to had the 🔲 
```
THEOREM 🔲 (v = e) => (f = (f WITH v <- e))
```
1.   When in AB2, we add the possibility for messages to be corrupted. If that happens, we will need to compare messages to a potential "Bad" string, and TLC will yell at formulas like `"Bad" = 0`. Instead, we can call the constant `Bad` a model value.
2.   When trying to specify the liveness of the spec, it's good to try and attach metadata for what actually happened, but don't append `TRUE/FALSE` to your messages - separate another Sequence as `<<TRUE,FALSE,TRUE...>>` to keep track of the *real* and *imaginary* parts of the spec.
3.   Refinement mappings help make implementations easier.

### 19/06/2021

1.   In TLA+, every value is a set: 42 is a set, "abc" is a set.
2.   This represents 
```
TCTypeOK ==
    rmState \in [RM -> {"working", "prepared", "committeed", "aborted"}]
TCInit == rmState = [r \in RM |-> "working"] (* this means the array with index set RM such that every element rm of RM is mapped to "working"*)
```
1.   Terminology
| Programming | Math     |
| ----------- | -------- |
| array       | function |
| index set   | domain   |
| f[e]        | f(e)     |
1.   Remember notation for updating a record: 
```
Prepare(r) == /\ rmState[r] = "working"
              /\ rmState' = [rmState EXCEPT ![r] = "prepared"]

Decide(r)  == \/ /\ rmState[r] = "prepared"
                 /\ canCommit
                 /\ rmState' = [rmState EXCEPT ![r] = "committed"]
              \/ /\ rmState[r] \in {"working", "prepared"}
                 /\ notCommitted
                 /\ rmState' = [rmState EXCEPT ![r] = "aborted"]
```
1.   Ah! Draw the state machine and then figure out the actions that transition to each state!
2.   If you see the Coverage of actions and some of the actions were never taken `Count == 0`, it usually means there's an error in the spec.
3.   End of line `\* comment syntax`
4.   This record is actually a function, whose domain is `{"prof", "name"} such that f["prof"] = "Fred" and f["num"] = 42`. `f.prof === f["prof"]`
```
[prof |-> "Fred", num |-> 42]
```
1.   Abbreviate `[f EXCEPT !["prof"] = "Red"` as `[f EXCEPT !.prof = "Red"}]`
2.   `UNCHANGED <<rmState, tmSTate, msgs>>` is an ordered triple. It's equivalent to 
```
... /\ rmState' = rmState
    /\ tmState' = tmState
    /\ msgs' = msgs
```
1.   Conditions which have no primes' are calle *enabling conditions*, and  in an Action Formula should go at the beginning, like so.
```
TMRcvPrepared(r) == /\ tmState = "init"
                    /\ [type |-> "Prepared", rm |-> r] \in msgs
```
1.   Update the CommunityModules.jar... or else get hit by a bug..
2.   `Symmetry sets`: if "r1"↔ "r3" in all states of behavior `b` allowed by `TwoPhase` produces a behaviour `b\_{1,3}` allowed by `TwoPhase`, TLC does not have to check `b\_{1,3}` if it has checked `b`. Becuase `RM = {"r1", "r2", "r3"}`, We say that RM is a `symmetry set` of `TwoPhase`. To exploit this, replace
``` 
RM <- {"r1", "r2", "r3"}
```
with 
```
RM <- {r1, r2, r3}
```
select `Set of model values/Symmetry Set` just below it.
1.   So it turns out that TwoPhase Commit can break if the TM fails. If you try to "just" engineer it with a second TM, they can cannibalize messages if TM1 pauses and TM2 takes over and sends an abort signal.



### 18/06/2021

1.   A `behaviour` of a system is a sequence of states. A `state machine` is described by all its possible initial states and a next state relation. A `state` is an assignment of values to variables. The part of the program that controls what action is executed next is called the `control state`.
2.   A new TLA+ spec...
```
------------------------------- MODULE simple -------------------------------
EXTENDS Integers
VARIABLES pc, i


Init == i = 0 /\ pc = "start"

Pick == \/ /\ pc = "start"
           /\ i' \in 0..1000
           /\ pc' = "middle"
         
Add1 == \/ /\ pc = "middle"
           /\ i' = i + 1
           /\ pc' = "done"

Next == Pick \/ Add1

=============================================================================
\* Modification History
\* Last modified Fri Jun 18 20:58:16 CDT 2021 by mrg
\* Created Fri Jun 18 20:50:35 CDT 2021 by mrg

```
1.   To produce the PDF, type `Ctrl + Alt + P`.
2.   DON'T use Tabs (config in Preferences), F3/F4 to jump back and forth, F5 to see all defs, F6 for all uses of word under cursor, F10 is jump to PlusCal unfolded def, Oooh boxed comments are neat with `Ctrl+O + Ctrl+B` and friends, don't shade PlusCal code, regen pdf on save, `Ctrl+TAB` to swap between tabs, `Ctrl+Alt` to swap between subtabs
3.   [Hillel's super cool tricks for TLA+](https://twitter.com/hillelogram/status/1406081888498892807)
4.   This formula `FillSmall == small' = 3` is WRONG. It's true for some steps and false for others. It is NOT an assignment. The `big` must remain unchanged! If you don't you are coding, if you do keep it same, you are doing math. eg:
```
FillSmall == /\ small' = 3
             /\ big' = big
```
1.   Remember you can add `TypeOK` as an invariant and `big # 4` too!
2.   `big + small =< 5` , not `big + small <= 5` 🙁 
3.   Equality is commutative! `0 = small === small' = 0`
4.   Use a ' expression only in `v' = ...` and `v' \in ...`

### 17/06/2021

1.   [io_uring tutorial here](https://unixism.net/loti/async_intro.html), with a [chatbot example here](https://github.com/robn/yoctochat)
2.   [6 ways to make async Rust easier](https://carllerche.com/2021/06/17/six-ways-to-make-async-rust-easier/)
3.   Triage: `filter(func)` makes `func` a `Fix1`.
4.   Lazy iterators have uppercase names!
5.   GC is broken in multithreading - if thread 1 is allocating a bunch of garbage, and thread 2 isn't, then thread 1 can trigger a dozen collections, making thread 2 think its few objects are very old, and thus don't need to be collected.
6.   Lean4: `return` at the end will hurt type inference.
7.   `fpcontract` is a type of `fastmath flag`. If you use LLVMCall, you can use specific ones. Here's a specific issue for [automatic FMA](https://github.com/JuliaLang/julia/issues/40139).
8.   Turns out [folds are universal](https://www.cs.nott.ac.uk/~pszgmh/fold.pdf) - 
9.   PROJECT IDEA: [Feynman Diagrams???](https://www-zeuthen.desy.de/theory/capp2005/Course/czakon/capp05.pdf)

### 16/06/2021

1.   [Travis Downs recommends this x86 link dump](https://stackoverflow.com/tags/x86/info) - it's great! OMG it's way too much...
2.   `git format-patch -1 --pretty=fuller 3a38e874d70b` to format patches for the linux kernel.
3.   `git send-email mypatch.patch` to send patches, `git format-patch` to make it.
4.   `cregit, bison, flex, cscope` are useful tools for navigating kernel source code.
5.   `git log -2 Makefile` shows the last 2 commits that went into `Makefile`.
6.   `git log -2 --author=Linus` checks for the last 2 commits by Linus o.0
7.   You can comput in subtype expressions! Thanks to `Dr. Bauman` for this gem.
```julia
struct MyArrayWrapper{A} <: supertype(A)
    data::A
end
```
1.   `make core` will maek the core tests in Julia.
2.   `JULIA_LLVM_ARGS=-timepasses ./julia` To time all passes! Cool Stuff I learned from `Jameson Nash`. 
3.   `cat Make.user` to get 
4.   `cp -a v1.7/ v1.8/` to copy over all files
5.   Disabling DWARF with `./julia -g0` will make your code go *slightly faster* because you don't emit as much DWARF stuff - Probs worth looking into disabling it more.
6.   User vs System time: User land vs Kernel land timings  
7.   Profiler tricks:
```julia
Profile.print(C = true, nosiefloor = 1, mincount = 10)
```
1.   `e->Lunions = oldLunions;` is copying by value (which means a stack of 100 int32s is being copied on all that)
2.   Charpov sent me `homework1` and friends - MPI assignment is Homework 5.
3.   TLA+ Link dump
- [mpmc.c Lemmy tutorial](https://www.youtube.com/watch?v=wjsI0lTSjIo) [with C code](https://github.com/lemmy/BlockingQueue/blob/master/impl/producer_consumer.c), [java example](https://www.cs.unh.edu/~charpov/programming-tlabuffer.html)
- [PlusCal course](https://weblog.cs.uiowa.edu/cs5620f15/Homework)
- [cheat sheet](https://d3s.mff.cuni.cz/f/teaching/nswi101/pluscal.pdf)
- PROJECT IDEA: [Lean 4 Runge Kutta](https://lpsa.swarthmore.edu/NumInt/NumIntFourth.html), [Functional Fold!](https://www.johndcook.com/blog/2016/06/02/ode-solver-as-a-functional-fold/)
- [Intro to Distributed Systems book - Murat Demirbas recc](https://cse.buffalo.edu/~demirbas/CSE586/book.pdf)
- [Dao attack in PlusCal](https://muratbuffalo.blogspot.com/2018/01/modeling-doa-attack-in-pluscal.html), [code is here](https://github.com/muratdem/PlusCal-examples/tree/master/DAO)
- [beginner friendly examples](https://github.com/tlaplus/Examples/issues/15)
- [advent of code 2020](https://github.com/arnaudbos/aoc2020-tla-plus/blob/master/day1/DayOne.tla)
- [tortoise and hare cycle detection algo](https://github.com/lorin/tla-tortoise-hare/blob/master/CycleDetection.tla)
- [Rust and TLA+](https://github.com/spacejam/tla-rust)



### 15/06/2021

1.   Discovered [upgrep](https://github.com/Genivia/ugrep), which is a very optimized grep built in Cpp. Of note are the lockless work stealing scheduler and SIMD debranchification approach. It has a very, very pretty interactive `ugrep -Q 'foo'` mode. The debranching algo is [exposed in this talk](https://www.youtube.com/watch?v=kA7qZgmfwD8).
2.   Rediscovered [Calculus made easy](https://calculusmadeeasy.org/) and [AoPS boards](https://artofproblemsolving.com/school).
3.   Never a bad time to remember the [CFDPython](https://github.com/miguelraz/CFDPython) exists.
4.   Found the books `More/Surprises in Theoretical Physics by Rudolf Peierls`.
5.   Also found [Fundamentals of Numerical Computing](https://github.com/tobydriscoll/fnc-extras) by Toby Driscoll and [Exploring ODEs](http://people.maths.ox.ac.uk/trefethen/Exploring.pdf)
6.   PROJECT IDEA: Scrape [uops.info](https://uops.info/xml.html) with `TableScraper.jl`.
7.   PROJECT IDEA: CourseTemplates.jl based on [Computational Thinking from MIT](https://github.com/mitmath/18S191) which is [very pretty](https://computationalthinking.mit.edu/Spring21/semesters/).
8.   Remember the Intel OPtimization manuals come with [attached example codes](https://github.com/intel/optimization-manual/tree/2a7418eb5b6d750437c51542aec276a4d688fcba/common)
9.   PROJECT IDEA: Port [GW Open Data Workshop](https://gw-odw.thinkific.com/courses/take/gw-open-data-workshop-4/texts/24465187-welcome) too.
10.  [Read George's grad guide](https://github.com/gwisk/gradguide).
11.  Julius' post on [Julia macros for beginners](https://jkrumbiegel.com/pages/2021-06-07-macros-for-beginners/) is great.
12.  PROJECT IDEA: REPL Based PlutoUI.jl. WITH VIM BINDINGS + TextUserInterfaces.jl maybe?. YES. YES!
13.  PROJECT IDEA: Open Data structures in Julia with the MIT course template.
14.  Look into [DIANA](https://www-zeuthen.desy.de/theory/capp2005/Course/czakon/capp05.pdf) and Julian ports of it ([paper is here](https://core.ac.uk/download/pdf/25359736.pdf), [code is here](https://github.com/apik/diana)).
    - [FeynCalc](https://github.com/FeynCalc/feyncalc) in Mathematica is an interesting contender: [3.4 seconds](https://feyncalc.github.io/FeynCalcExamplesMD/EW/Tree/H-FFbar) to calculate the Higgs decaying into a fermion-antifermion pair.
15.  Learned how to fix a sink today: Need a stillson wrench, a bucket and a metal coat hanger. Put the bucket under the sink's elbow. Twist off the bottom of the elbow. If there's no much when you take off the cap, it's likely there's no blockage at the elbow. Next, scrape the circumferences of the sink's drain with the wire hanger, letting off a bit of water to rinse the muck. Repeat until clean, don't forget to wrench up the bottom of the elbow again.
16.  PROJECT IDEA: LLVMPassAnalyzer.jl with [Text User Interfaces.jl](https://github.com/ronisbr/TextUserInterfaces.jl) as the backend. Or maybe [TerminalUserInterfaces.jl](https://github.com/kdheepak/TerminalUserInterfaces.jl)
17.  Lean: `import Leanpkg; #eval Leanpkg.leanVersionString`, commetns are with `--`, arrays `#[1,2,3][1] == 1`, functions don't need spaces so `gcd 1 10 == 1`, Lists are `[1,2,3]`, 
```
structure Array (a : Type u) where
    data : List a
```
1.   `eval List.map (fun x => x + 1) [1, 2, 3]` and `#eval List.map (fun (x,y) => x + y) [(1,2), (3,4)] == [3,7]`
2.   There's [Lean for hackers](https://agentultra.github.io/lean-for-hackers/), and you can run your file with `lean --run leanpkg.lean`.
3.   [Functional Algorithms Verified!](https://functional-algorithms-verified.org/functional_algorithms_verified.pdf) sounds awesome, but not in Lean4 
4.   [Logical Verification in Lean](https://lean-forward.github.io/logical-verification/2020/index.html)
5.   [Temporal Logic slides and exams](https://www.dc.fi.udc.es/~cabalar/vv/index.html)
6.   [LTL Model checking course](https://www.youtube.com/watch?v=qDyJ9H6r0YA) and book `Principles of MOdel Checking - J P Katoen`
7.   [Lean 4 course by Seb. Ullrich](https://github.com/IPDSnelting/tba-2021) is THE source and [Lean for hackers](https://github.com/agentultra/lean-for-hackers/blob/master/index.md) looks like a good hello world post.
- Bonus [advent of lean4](https://github.com/rwbarton/advent-of-lean-4)
- PROJECT IDEA: [Linear Temporal Logic in Lean4](https://github.com/GaloisInc/lean-protocol-support/blob/cabfa3abedbdd6fdca6e2da6fbbf91a13ed48dda/galois/temporal/temporal.lean)
- [All the adhd feels today](https://twitter.com/visakanv/status/1405252979301634049)


### 11/06/2021

1.   `MXCSR`: Multimedia eXtension Control and Store Registers - can be accessed with `vldmxcsr, vstmxcsr`
2.    The amazing `Jubilee` shares another nugget:
> So like... the problem with those is that access to the MXCSR bit field actually can break LLVM compilation assumptions.
> it's literally UB.
> To touch it. At all.
> Now, it so happens that LLVM may not break your code if you actually do it, and LLVM is slowly growing the capability to handle altering MXCSR in a principled manner, but anyone touching it is doing so at their own risk, aware that it's UB.
1.   When going form AVX to SSE instructions, there may be a performacne penalty due to keeping the upper 128 bits of YMM registers intact - use `vzeroupper` before that to avoid all perf penalties. Also, AVX allows unaligned accesses with a perf cost, but keeping alignment will increase perf.
2.   MASM calling convention: pass first 4 float args in xmm0:3.
3.   Leaf functions in assembly don't need a prolog or epilog, non-leaf functions *must*: save and restore volatile registers, initialize stack frame pointer, allocate local storage space on the stack, call other functions.
4.   In C++, you can align xmm values with
```cpp
struct XmmVal {
public:
    union {
        int8_t m_I8[16];
        int16_t m_I16[8];
        //...
        float m_F32[4];
        double m_F64[2];
    }
}
void AvxPackedMathF64 {
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;
    alignas(16) XmmVal c[8];
}
```
1.   To get those xmm's into vector registers:
```
; Load packed SPFP values
    vmovaps xmm0, xmmword ptr [rcx] ;xmm0 = a
    vmovaps xmm1, xmmword ptr [rdx] ;xmm1 = b
```
So, note you load the entire `xmm` register with `xmmword ptr [foo]`.
1.   Super cool trick to check 16 byte alignment (no perf penalty)
```
test rcx, ofh ; jump if x not aligned to 16 byte boundary
jnz Done
```
1.   Macros avoid overehad of a function call.
2.   Want to transpose a matrix? Use a bunch of `vunpcklps`, `vunpckhps`, `vmovlhps`, `vmovhlps`.


### 10/06/2021

1.   Assembly! 
*    rax - temporary register; when we call a syscal, rax must contain syscall number
*    rdi - used to pass 1st argument to functions
*    rsi - ptr  to pass 2nd argument to functions
*    rdx - used to pass 3rd argument to functions
This mirrors this syscall in C:
```c
size_t sys_write(unsigned int fd, const char* buf, size_t count);
```
* `fd` - file descriptor, 0,1,2 for stin, stdout, and stderr respectviely
* `buf` - points to char array, can store content from file pointed at by fd
* `count` - specifies number of bytes to be written from the file into the char array

1.   Little-endian - smallest byte as smallest address. Derp.
2.   `data, bss, text` - initialized consts/dadta, non initialized vars, code section in asm.
3.   registers: rax:rdx, bp sp si di, r8:r15
4.   There's several types of initialzied data `db` (declare bytes), `dw` (declare words), etc.
There's also `RESB, RESW` as reserved bytes, reserved words, etc. `INCBIN` is for external binary files, `EQU` for defining constants:
```
one equ 1
```
Exercise: try to translate the following C code into asm:
```c
if (rax != 50) {
    exit();
} else {
    right();
}
```
Attempt:
```
    cmp rax, 50
    jne .exit
    jmp .right ; HOT DAMN FIRST TRY YO
```
1.   Only 6 args can be pass via registers, the rest are passed on the stack:
*    rdi - first argument
*    rsi - second argument
*    rdx - third argument
*    rcx - fourth argument
*    r8 - fifth argument
*    r9 - sixth
So if you have 
```c
int foo(int a1, int a2, int a3, int a4, int a5, int a6, int a7)
{
    return (a1 + a2 - a3 - a4 + a5 - a6) * a7;
}
```
The first six are pass in the registers, and the 7th arg you have to pop from the stack: `push arg/ pop arg`.
In MASM, you get 4 registers for calling convention and the rest are in 8 byte incremetns from the RSP.
ALSO: After you are finished being called, you have to restor registers `rbp, rbx, r12:r15`

1.   You can write nicer headers
```
section .data
		SYS_WRITE equ 1
		STD_IN    equ 1
		SYS_EXIT  equ 60
		EXIT_CODE equ 0
    
		NEW_LINE   db 0xa
		WRONG_ARGC db "Must be two command line argument", 0xa
```
1.   `$, $$` return the position in memory of string where `$` is defined, and position in memory of current section start, resp.
2.   Why the instruction `mov rdi, $ + 15`? You need to use the `objdump` util, and look at the line after `calculateStrLength`
```
objdump -D reverse

reverse:     file format elf64-x86-64

Disassembly of section .text:

00000000004000b0 <_start>:
  4000b0:	48 be 41 01 60 00 00 	movabs $0x600141,%rsi
  4000b7:	00 00 00
  4000ba:	48 31 c9             	xor    %rcx,%rcx
  4000bd:	fc                   	cld
  4000be:	48 bf cd 00 40 00 00 	movabs $0x4000cd,%rdi
  4000c5:	00 00 00
  4000c8:	e8 08 00 00 00       	callq  4000d5 <calculateStrLength>
  4000cd:	48 31 c0             	xor    %rax,%rax
  4000d0:	48 31 ff             	xor    %rdi,%rdi
  4000d3:	eb 0e                	jmp    4000e3 <reverseStr>
```
1.   To checkif a string is set:
```
    test rax, rax               ; check if name is provided 
    jne .copy_name
```

1.   Assembly has macros! These are single line
```
%define argc rsp + 8
%define cliArg1 rsp + 24
```
These are multi line
```
%macro bootstrap 1          ; %macro name number_of_params
          push ebp
          mov ebp,esp
%endmacro
```
1.   Don't forget the `.period` when you `call .function`, AND in the function section titles:
```
.returnTrue
    mov eax, 1
    ret
```
1.   THERE'S STRUCTS in ASSEMBLY?
```
struc person
   name: resb 10
   age:  resb 1
endstruc
; and then
section .data
    p: istruc person
      at name db "name"
      at age  db 25
    iend

section .text
_start:
    mov rax, [p + person.name]
```
1.   [Call C from assembly, assembly from C](https://0xax.github.io/asm_7/)
2.   x86 has 8 registers for floats, they are 10 bytes each, labeled from ST0:ST7
- `fld dword [x] ` pushes x to this stack.
- `fldpi` loads pi, lol.
```
extern printResult

section .data
		radius    dq  1.7
		result    dq  0

		SYS_EXIT  equ 60
		EXIT_CODE equ 0

global _start
section .text

_start:
		fld qword [radius]
		fld qword [radius]
		fmul

		fldpi
		fmul
		fstp qword [result]

		mov rax, 0
		movq xmm0, [result]
		call printResult

		mov rax, SYS_EXIT
		mov rdi, EXIT_CODE
		syscall
```
You have data in `radius` and `result`. `fld qword [radius]` stores radius in ST0, and again in ST1. `fmul` then multiplies both and puts it in ST0. Load pi with `fldpi`, multiply, and store that result with `fstp qword [result]`. C calling convention: pass floats to system through `xmm` registers, so you have to declare how many you are using - do that with `mov rax, 0`, `movq xmm0, [result]`, `call printResult`, then exit.
1.   [GREAT ASSEMBLY TUTORIAL](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
2.   `shl` must use register `cl` to make the shifts.
3.   `sar` shift arithmetic right because it carries over the bit, like in arithmetic, ha.
4.   `cdq` -> "convert dobule word to quadword": Dividend in EAX must be sign extended to 64bits.
5.   Do integer conversions with `movsx`, "move integer with sign extension" and `movzxd` "move unsigned integer with sign extension double word"
6.   `@F` is a forward jump, `@B` backwards jump
    
### 09/06/2021

1.   [Parallel Computing course](https://wgtm21.netlify.app/parallel_julia/) by WestGrid Canada + HPC.
2.   [vcpkg](https://vcpkg.io/en/getting-started.html) sounds like a decent package manager for Cpp.
3.   LLVM Tips and tricks: 
    - Use Ninja and tons of flags to speedup compilation: don't build all backends, use the new pass manager, only target host architecture, optimized tablegen, release with debug info,
    -
170.[oh shit git](https://ohshitgit.com/) seems neat!
1.   To see what is actually printed after macro replacements, use `clang -E foo.c`.
2.   `LLVM Bugpoint` does case test reduction
3.   You can unit test the optimizer o.0
```llvm
; RUN: opt < %s -constprop -S | FileCheck %s
define i32 @test() {
  %A = add i32 4, 5
  ret i32 %A
  ; CHECK: @test()
  ; CHECK: ret i32 9
}
```
1.   [Best Tutorial for x86](https://github.com/0xAX/asm) I could find, and free! Now I gotta write syscalls snippets for the bloat...

### 08/06/2021

1.   Lord help me my `Learn LLVM 12` book is here and I'm learning C++ to be an uber Julia hacker. Taking the `C++ Beyond the Basics ` course by Kate Gregory I learned
- `inst const zero = 0` tells the comp `zero` can't change.
- `int taxes(int const total)` tells the copmiler `total` can't change within the lifetime of this function
- `int GetName() const;` const modify the class its in.
- `inst const ci = 3` and `const int ci = 3` are both valid, but prefer `const` after the thing that can't change.
- `[=](){}` is a lambda func that copys everything by value, `[&]` by ref, but copies smartly only the things you used.
```cpp
vector nums {1,2,3,45};
auto isOdd = [](int candidates){candidates % 2 != 0;};
int odds = std::count_if(begin(nums), end(nums), isOdd);
// std algorithms have all the goodies that apply to iterators like
//any_of, all_of, etc
```
- to generate collections, instead of a for loop, try
```cpp
int i = 0;
std::generate_n(std::back_inserter(v), 5, [&]() { return i++; });
```

- to accumulate the elements,
```cpp
int total = 0
total = std::accumulate(begin(v), end(v), 0);
```
- to count elements
```cpp
int count3 = std::count(begin(v), end(v), 3);
```
- to remove elements == 3,
```cpp
auto v4 = v;
auto endv4 = std::remove_if(begin(v4), end(v4), [](int elem) {return (elem == 3)}; );
v4.erase(endv4, end(v4)); // or even v4.erase(std::remove_if(...));
```
- if you use functional style, you can replace `vector<int> v -> list<int> v`, (you don't have [] in lists)
- counting all of something
```cpp
bool allpositive = std::all_of(begin(v4), end(v4), [](int elem) { return elem >= 0; });
```
- ermahgerd `sort(v4)` finally exists in g++20!!!!
- `g++ -std=c++20 numbers.cpp` to get things to work...
- `auto letter = find(begin(v4), end(v4), 'a');`
- try/catch: put most specific errors first, use `std::invalid_argument("foo")`, `catch (exception& e) { cout << e.what(); }`
- do this, not `auto x = new X(Stuff); delete x`
```cpp
try {
    auto x = make_unique<X>(Stuff);
    // risky stuff
}
```
- `constexpr` is evaluated at compile time
- range for statements:
```cpp
for (auto i : v)
for (auto x : {10, 20, 30})
for (auto& x : v) //refers, doesn't modify
```
- `while (p)`, works until pointer is null - UGH
- `x.name` accesses the struct `x` field `name` through reference and `x->name` trough the pointer. Huh?
- `static_assert` exists
- virtual syntax is `= 0`, means `may be redefined later in a class derived from this one`.
```cpp
class Container {
    public:
    virtual double& operator[](int) = 0;//pure virtual function
    virtual int size() const = 0;//const member function (§4.2.1)
    virtual  ̃Container() {} //destructor (§4.2.2)};
}
```
- `:public` can be read as "is a subtype of"
- Essential operations
```cpp
class X {
    public:
        X(Sometype);                    //ordinar y constructor: create an object
        X();                            //default constructor
        X(const X&);                    //copy constr uctor
        X(X&&);                         //move constr uctor
        X& operator=(const X&);         //copy assignment: clean up target and copy
        X& operator=(X&&);              //move assignment: clean up target and move
        ̃X();                            //destr uctor: clean up
        //...
        //Y(const) //
};
```
pg 53 of Tour of Cpp really says talks about move semantics
* soruce of an assignment
* an object initializer
* as a func arg
* as a func return value
* as an exception
- drop objects at end of scopes == RAII
- move/copy and be suppresed with `Shape& operator=(Shape&&) = delete;` + friends on pg 55
- TEMPLATES!
```cpp
template <typename T>
class Vector {
private:
    T* elem;
    int sz;
public:
    explicit Vector(int s);    //constructor, establish invariant, acquire resources
    ~Vector() {delete[] elem;} //destructor, release resources
    //copy+move ops
    T* operator[](int n);
    const T& operator[](int i) const;
    int size() const {return sz;}
}
```
This is also possible:
```cpp
template <typename T, int N>
struct Buffer {
    using value_type = T;
    constexpr int size() { return N: }
//...
}
```
- You can create function objects/closures! `it(n)` pg 64
- add `override` after virtual ops, type your enmus, default value inits structs `int value = 5`, 


1.   Rust tips: Finally found a decent SIMD tutorial for Rust! I learned that ISCP is a C SIMD dialect to get super optimal performance. Instead of their Hello world, we can try doing something like this:
```rust
pub fn dotp(x: &[f32], y: &[f32], z: &mut [f32]) {
    let n = 1024; // or let n = x.len();
    let (x, y, z) = (&x[..n], &y[..n], &mut z[..n]);
    for i in 0..n {
        z[i] = x[i].mul_add(y[i], z[i]);
    }
}
```
that exploits the `x.len()` to pass that info to LLVM for more optims.
### 05/06/2021

1.   [Introduction to Undefined Behaviour](https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html) and a blog post by [John Regehr](https://blog.regehr.org/archives/213) - time to grok some of this nonsense.
- `for(int i = 0; i <= N; i++) {...}` if overflow is UB, then the compiler can assume the loop stops in at most `N+1` iterations (because if  `N == INT_MAX`, the loop may be infinite!)
- Oh damn, the first post is by Chris Lattner, author of LLVM o.0

1.   `@agustinc3301` kindly helped me setup Cloudflare analytics on my Franklin.jl blog. It's free and quick! You verify your account after signing up and then add the link to your Franklin footer in `_layout/foot.html` and `page_foot.html` (I think.). That did it! Now I can see redditors accessing the `Julia To Rust` post  🔎 


### 04/06/2021
1.   `Jubilee` recommends capturing mutation to smaller scopes in Rust instead of the C-ish idiom of mutation everywhere:
```rust
    let mut i = 0;
    while i < N {
        let d2s = f64x2::from_array([
            (r[i] * r[i]).horizontal_sum(),
            (r[i + 1] * r[i + 1]).horizontal_sum(),
        ]);
        let dmags = f64x2::splat(dt) / (d2s * d2s.sqrt());
        mag[i] = dmags[0];
        mag[i + 1] = dmags[1];
        i += 2;
    }
```
Can be converted to 
```rust
    for i in (0..N).step_by(2) {
        let d2s = f64x2::from_array([
            (r[i] * r[i]).horizontal_sum(),
            (r[i + 1] * r[i + 1]).horizontal_sum(),
        ]);
        let dmags = f64x2::splat(dt) / (d2s * d2s.sqrt());
        mag[i] = dmags[0];
        mag[i + 1] = dmags[1];
    }
```
1.   To run `cargo watch` on a non-standard file, use ` cargo watch -c -x "run --examples dot_product"`. Credit to `Lokathor`.
2.   Finally got the code working for the `dot_product.rs`! in the end, it wasn't so scary:
```rust
#![feature(array_chunks)] // gotta have this
fn dot(a: &[f32], b: &[f32]) -> f32 {
    a.array_chunks::<4>() // el paso de la muerte
    .map(|&a| f32x::from_array(a))
    .zip(b.array_chunks::<4>().map(|&b| f32x4::from_array(b))) // so aside form some ugly conversions all is peachy
    .map(|(a,b)| (a * b).horizontal_sum())
    .sum()
}
```


### 03/06/2021

1.   Rust syntax for updating structs with `..other_struct` is very neat.
2.   `if let Some(word) = ... {}`
3.   `while let Some(Some(word)) = ... {}`
4.   `cargo watch -c` is very useful for seeing how you're code is going! Credit to `Lokathor` for the `-c` flag.

### 31/05/2021
1.   `make -C debug` julia builds are much faster to build because you are not optimizing anymore - hat tip to Jameson Nash for that.
2.   LLVM trap is what calls unreachable - tells the runtime that this should never happen. Basically checking that codegen didn't screw up.
3.   `git add -u` 

### 30/05/2021
1.   Finally got the hang of the Rust `dbg!` macro:
```rust
let a = 2;
let b = dbg!(a * 2) + 1;
//      ^-- prints: [src/main.rs:2] a * 2 = 4
assert_eq!(b, 5);
```
Very useful for the competitive problems debugging!

### 27/05/2021

1.   Finally got around to the `nucleotide` in Rust exercism. My solution was a bit C-ish, this is neater: (Credits to `azymohliad`, but with no `Err`)
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

1.   Rust: `use enum::*;`, and then you don't need to `enum::foo` all over your match arms!

2.   I learned about the `slice.windows(2)` function in the `sublist` exercise, [link here](https://doc.rust-lang.org/std/primitive.slice.html#method.windows)
```rust
let slice = ['r', 'u', 's', 't'];
let mut iter = slice.windows(2);
assert_eq!(iter.next().unwrap(), &['r', 'u']);
assert_eq!(iter.next().unwrap(), &['u', 's']);
assert_eq!(iter.next().unwrap(), &['s', 't']);
assert!(iter.next().is_none());
```

1.   Difference between `show` and `print`: `print` uses quotes around the string, `show` doesn't, and this 

2.   Rust: `map.entry(letter).or_insert(0)) += 1`

### 26/05/2021

1.   FINALLY GOT THE ASSEMBLY HELLO WORLD TO WORK!
- I had to disable the `stdfaxh.h` whatever
- This was the final command:
```bash
$ nasm -g -f elf64 hello.asm
$ g++ hello.cpp hello.o
$ ./a.out
```
- and the assembly file was:
```
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
- if using extern variables, use `extern g_val`, and then `default rel`

### 24/05/2021

1.   Made a 3D print of dispatch with my sister. It was an awesome birthday.

2.   Got DoctorDocstrings.jl Poster and Rubin.jl Lightning talk accepted to JuliaCon! Now to work on those asap...

3.   Got the Kusswurm `Modern x86 Assembly Language Programming` and Min-Yih Hsu `LLVM Techniques` books in the mail now...

4.   Should write down the Next steps for MMTK - a written down goal is usually an easier one. 

5.    🚀 💃 To setup emojis, we can insert with `SPC i e`, but the line editor gets a bit funky...?

6.   Found this incredibly useful [Doom emacs tips](https://gist.github.com/hjertnes/9e14416e8962ff5f03c6b9871945b165), and [this vim guide](https://gist.github.com/dmsul/8bb08c686b70d5a68da0e2cb81cd857f)

### 21/05/2021

1.   Finally remembered to setup `mu`. Let's [see if I can finally do it...](https://www.sastibe.de/2021/01/setting-up-emacs-as-mail-client/)

### 18/05/2021

1.   Vim tricks from Emacs doom! RTFM to change the font to Julia mono!
- `cc` in vim mode will let you change the whole line! 
- `C` changes to the end of the line!
- `*` to highlight all copies of the word under the cursor
- `~` to change the case of a letter, `[#]~` to change # chars after the letter under cursor. `g~[m]`, `gU[m]` `gu[m]` toggle cases with motion `[m]`
- `>[m]` to toggle case with motion `[m]`, `>>` to indent this line
- `J` to move line beneath to end of this one
- `gq[m]` format text between here and `[m]`, `gqq` formats current line
- *Marks*: `ma` sets a mark
- `'` and `''` to set a mark and jump back and forth between them

1.   Kevin Bonham is helping me figure out the Emacs tabbing situation:
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
```julia
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

116. Remembered about `ArgParse.jl`. Notice:

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
```
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

 16. Polytomous recommended [this site Taguette](https://www.taguette.org) for highlighting documents and its open source. Super cool! Should send to Ponzi.

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

### 04/08/2022

579. Today I restart this diary but going the other way...fuck Markdown auto formatting.
580. Some attributes are unsafe o.0.
581. Your error types should implement the `std::error:Error` trait, `Display/Debug`
582. Type-erased errors often compose nicely.
583. If your error is `Box<dyn Error + Send + Sync 'static>` then you can `Downcast` it: you can take an err of one type and cast it to a more specific type when calling: you can use `Error::downcast_ref` on an `std::io::Error` to get a `std::io::ErrorKind::WouldBlock`, but `downcast_ref` requires its arg to be `'static`.
584. You can only obtain `!` (the Never type) by infinte looping or panicking or very special occasions, and the compiler can actually optimize your code based on that, since it knows that branch never returns. If you write a func that returns `Result<T, !>`, you can't return an `Err`.
585. `?` does unwrap or early return.
586. "Implement `From`, use `Into` in bounds." Since there is a blanket impl for getting an `Into` from anything that uses `From`.
587. An early return here would be bad because it may skip the cleanup:

```rust
fn do_the_thing() -> Result<(), Error> {
    let thing = Thing::setup()?
    // .. code that uses thing and ?
    thing.cleanup();
    OK(())
}
// vs
fn do_the_thing() -> Result<(), Error> {
    let thing = Thing::setup()?
    let r = try {
    // .. code that uses thing and ?
    };
    thing.cleanup();
    r
```

588. Just because it has `!` at the func name doesn't mean it's a declarative macro, like `macro_rules!` and `format_args!` - just means that some source code will be replaced/changed at compile time.

589. Declarative macros always generate valid Rust as output.

590. `:ident`, `:ty`, `:tt` are known as `fragment types`.

591. Macro variable identifiers existing in their own namespace => no name clashes => `hygienic`. Doesn't happen for Types, Modules and Functions within the call site (so that you can define them inside the macro and use them outside).

592. Avoid `::std` paths so that macros can be used on `no_std` crates.

593. You can escape/share identifiers with `$foo:ident`!

594. Macros must respect import order - even in `lib.rs` so `mod foo; mod bar;` will let macros from `foo` be used in `bar`, and not vice versa.

595. In procedural macros you can affect *how* the parsed code is generated, and aren't required to be hygienic.
* function-like macros need `Span::call_site` and `Span::mixed_site`
* attribute macros are like `#[test]`.
* `#[derive]` macros add to, don't replace token trees that come after them.
* consider using the `syn` crate for macros, and using it in debug mode, and turning off features.
* compile time pure computations sound like something good that a function-like macro can do.
* testing configs and middleware like logging/tracing can be a good place for attribute macros

596. `TokenStream` implements `Display`, which is handy for debugging!

597. To propagate user errors like `u31` as a type, consider the `compiler_error!` macro.

596. Async interfaces are mthods that return a `Poll`, as defined here:

```rust
enum Poll<T> {
    Ready(T),
    Pending
}
```

597. Polling is standardized via the `Future` trait:

```rust
trait Future {
    type Output;
    fn poll(&mut self) -> Poll<Self::Output>;
}
```

types that implement this trait are called `futures` (or *promises* in other langs).
598. Don't poll futures after they have return a `Poll:Ready`, or they panic. If it's safe to do, it's called a `fused future`.

599. `Receiver` and `Iterator` look very similar, in some sense - they might be fused in the future! (async iterators are called `streams`).
600. `Generators` are chunks of code with some extra compiler generated bits that enable it to stop/`yield` its execution midway and resume later from the yieldpoint. Not yet in stable Rust but used internally.
601. Generators need to store a bunch of internal state to be able to resume - if your app spends too much time in `memcpy`, perhaps its the generators. Rust checks that references across these internal states obey the ownership system.
602. What happens when code isnide an `async` block takes a ref to a local var? The point is that the polling can give you `self-referential` data which holds both the data and the refs to that data, but the polling has moved it! To solve this conundrum, you use `Pin`, a wrapper type that prevents the underlying type from being (safely) moved and `Unpin` is a marker trait that the implementing type *can* be removed safely from a `Pin`.

```rust
// What you get from using Pin to implement Future
trait Future {
    type Output;
    fn poll(self: Pin<&mut self>) -> Poll<Self::Output>;
}
```

This means that "once you have the value behind a `Pin`, that value will never move again."
603. Notice the implementation of Pin:

```rust
struct Pin<P> {pointer: P}
impl<P> Pin<P> where P: Deref {
    pub unsafe fn new_unchecked(pointer: P) -> Self;
}
impl<'a, T> Pin<&'a mut T> {
    pub unsafe fn get_unchecked_mut(self) -> &'a mut T;
}
impl<P> Deref for Pin<P> where P: Deref {
    type Target = P::Target;
    fn deref(&self) -> &Self::Target;
}
```

- we hold a *pointer type*: `Pin<Box<MyType>>`/`Pin<Rc<MyType>>` and not `Pin<MyType>`
- the constructor is unsafe! and the `get` method is unchecked - so that any moving is your responsibility
- `Pin::set` can drop a value in place and store a new value - and yet fulfill the contract that the old value was never accessed outside of a `Pin` after it was placed there!

604. Git saves files more like this:
```
   V1    V2 V3 V4 V5
File A   A1 A1 A2 A2
File B   B  B  B1 B2
File C   C1 C2 C2 C3
```
and `vcs` does it more on a "delta based" version:
```
   V1   V2 V3 V4 V5
Fila A  Δ1 -> Δ2
File B  -> -> Δ1 Δ2
File C  -> Δ1 -> Δ3
```
and 99% of stuff can be done locally - you don't need a central server to answer you.
605. Because Git checksums all file stores and is referred to by the checksum, you can't just swap files without detection.
606. Git has 3 stages (*IMPORTANT*):
- *modified* -> the working tree: single checkout of one version of the project. Files pulled from compressed database.
- *staged*   -> the staging area: a file of what goes into the next commit (or `git index`).
- *committed*-> the .git directory (repository): where Git stores metadata and object database for the project (Most important part, this is what you clone form other repos).

607. Basic configs, in ascending priority level:
    - `[path]/etc/gitconfig` - applied to all usrs on system and their repos.
    - `~/.gitconfig` or `~/.config/git/config` - applied to you as user
    - `.git/config` for single repo

608. Set `main` as the default branch name:
```bash
git config --global init.defaultBranch main
```
609. `git help <verb>` is a canonical way to get help, `git add -h` is an abbreviated way to get help/show flags.
610. If anyone has any clone of your repo, they have the entire history of it, and can restore it if needed.
611. Untracked files are files that weren't in the last snapshot.
612. Once you stage it, it gets committed.
613. Use `git status -s (or --short)` to get a nice summary of where you are.
614. `.gitignore` can respect glob patters and ignores `#` lines
```
# ignroes all .a files
*.a 

#but do track lib.a
!lib.a

#ignore all files in any dir named build
build/

ignore all .pdf files in the doc/ dir and its subdirs
doc/**/*.pdf
```
615. `git diff --staged` and `git diff --cached` are synonyms.
616. `git difftool --tool=vimdiff` looks cool.
617. Can declare inline commit message with `git commit -m`, and `git commit -am` will skip the need to stage the file and *then* committing.
618. `git rm -f README` requires extra args to prevent misuse. To remove a file from staging area, do `git rm --cached README`.
619. `git mv README.md README` can save you some commands.
620. `git log --stat` is neat, `git log --compact-summary` is neat,
621. `git log --pretty-format: %h %s --graph` is super neat, add it as a command.
622. Limit log out put with `-2` but also with `--since` and `--until`: `git log --since=2.weeks`. Combine with `--author="John Smit"` and you have a rat!
623. `git log -S function name` is known as the `pickaxe option`: Takes a string and only shows the commits that altered the count of the string.
624. `git log -- path/to/file` gives you history
625. `git log --no-merges` can help reduce noise!
626. Committed to early? try `git commit --amend` literally overwrites the previous commit with a new one. Only do it for local changes, and not those that have been pushed.
627. **UNSTAGE A FILE**:`git reset HEAD <FILE>` to unstage a file
628. **UNMODIFY A MODIFIED FILE**: `git checkout -- <FILE>`. (Dangerous - any local chanes are gone.)
629. The previous 2 can be done with `git restore`:
```bash
git restore --staged <FILE> # unstages a file
git restore <FILE>          # unmodifies a file
```
630. `git fetch <remote>` goes out and copies all the data from that remote project.
631. Fast forward if possible, else create a merge commit: `git config --global pull.rebase "false"` vs you want to rebase while pulling: `git config --global pull.rebase "true"`.
632. `git push <remote> <branch>`.
633. `git remote show origin` shows you all the branches you have made to the repo and their current status (up to date, fast-forwardble, local out of date)
634. `git remote set-url remote-name new-url`
635. List tags: `git tag`, and `git tag -l "v1.8.5*"` will glob accordingly
636. Annotated tags have a bunch of metadata and can be signed and verified - make one with `git tag -a v1.4 -m "My version 1.4"`, and then you can do `git show v1.4`
637. Git tags can be added after the fact: just do `git log --pretty=oneline` and then `git tag -a v1.2 asdfbd`.
638. Git doesn't push tags by default, you need to `git push origin <tagname>`, or `git push origin --tags`. To delete a tag locally use `git tag -d <tagname>` and remotely do `git push origin --delete <tagname>`.
639. Setup aliases with `git config --global alias.co checkout`
640. `git log --oneline --decorate --all --graph` is cooool and `git config --global alias.gg 'log --oneline --decorate --graph'` is very neat for a `git gg`.

### 10/04/2022

641. A commit in Github is 
- a size
- a hash
- a tree
- an author
- a committer
pointing to a `tree` which is
- a size
- a blob per file
- pointing to each blob
and each `blob` contains
- a hash
- its size

Each commit pointing to its tree/snapshot but the parent commit is pointing to another commit's hash.
642. A `git branch` is a movable pointer to one of these commits.
643. To know what branch you're currently on, git keeps a special pointer called `HEAD`.
644. If you want to know to which branch the pointers are pointing to, use `--decorate`
645. Some commits from a diff branch may be hidden - use `git log <branch>` or `git log --all` to show them all.
646. Switching branches *changes files* in your working directory.
647. `git log --oneline --decorate --graph --all` goes from bottom to top.
648. `git checkout -b <newbranchname>` and `git switch -c <new-branch>` are identical. `git switch testing-branch` also works.
649. When there's no divergent work to merge together, it's called a `fast-forward`.
650. Merge commits have 3 parents - can you have N parents?
651. `git checkout master` -> `git merge iss53` ☑ 
652. `git mergetool` 👀 is setup with `git config --global merge.tool nvimdiff`.

### 11/04/2022

653. Rested.

### 12/04/2022

654. Just don't rename branches that are not local to you. CI can also break from a `master` rename, but if you must, use `bit branch --move master main` the `git push origin --delete master`.
655. [Weggli](https://github.com/googleprojectzero/weggli) is a semantic search tool for C/C++
656. The point of `Pin` is to have target types that contain references to themselves and give the methods a guarantee a that the target type hasn't moved (and that the internal self references remain valid).
657. `Unpin` is an auto-trait (if all your struct fields are `Unpin`, your struct is also `Unpin`). Which means you kinda have to opt out of `Unpin`.
658. `pub unsafe fn foo(...) {}` is considered a mistake because it doesn't help you reduce the `footgun radius` lol. The first means `I swear X, Y, Z is upheld in this code`, and `unsafe {...}` means that all the unsafe contracts within the block are contained/upheld.
659. Big things to do in unsafe blocks: deal with raw pointer types like `*const T` and `*mut T`.
660. Types of unsafe:
- Non-Rust interfaces
- skip safety checks
- custom invariatns

661. `std::hint::unreachable_unchecked` is a common use of `unsafe`.
662. You can do `std::ptr::{read,write}::{unaligned,volatile}` to use `odd pointers` - they don't meet Rust's assumptions of alignment or size.
663. `Send/Sync` means that a type is safe to send / share across threads, respectively.
664. It is commone to forget to add bounds to generic parameters for unsafe impls of Send and Sync: `unsafe impl<T: Send> Send for MyUnsafeType<T> {}`.
665. `unsafe` is for memory unsafety, not per se for business logic.
666. There's 3 big types of `UNDEFINED BEHAVIOR` manifestations:
- not at all (can change with diff compilers/hardware/surrounding code change)
- visible errors (at least you can debug something)
- invisible corruption (god help you)
667. [We need Better Language Specs](https://www.ralfj.de/blog/2020/12/14/provenance.html) by Ralf Jung - a Rust PL researcher.
668. `Validity`: rules for what values a given type can inhabit
- Ref types can never dangle, must always be aligned, must always point to a valid value of their target type, shared and an exclusive ref can't coexist simultaneously, etc
669. Niche optimization: Since a reference can never be all zeros, an `Option<&T>` can use all zeros to represent `None` and avoid the extra byte and allocation. Also applies to `Option<Option<bool>>`
670. `MaybeUninit` memory is very useful in network buffers/hot loops: No point requiring a `[0; 4096]` if you're going to overwrite those values with 0 if you're going to overwrite them anyways with other values.
671. If you are calling user code, you should assume it panics and handle accordingly.
672. The `drop check`:
```rust
let mut x = true;
let foo = Foo(&mut x);
let x = false;
```
If Foo implements `Drop`, then it may use a ref to `x`, and thus should not compile. If it doesn't implement `Drop`, all is good. BUT!
```rust
fn barify<'a>(_: &'a mut i32) -> Bar<Foo<'a>>{..}
let mut x = true;
let foo = Foo(&mut x);
let x = false;
```
If `Foo` implements `Drop` but `Bar` does not, this code shouldn't compile. BUT! If the ref `Bar` holds is indirect, like `PhantomData<Foo<'a>>`, or `&'static Foo<'a>`, then the drop is ok, because `Foo::drop` is never actually invoked, and the ref to `x` is never accessed.
This whole logic is the `drop check`, and we really need it for dangling generic parameters like `unsafe impl<#[may_dangle] T> Drop for ...`.
673. "Since we do call `T::drop`, which may itself acces, say a reference to said `x`, Luckily, the fix is simple: we add a `PhantomData<T>` to tell the drop check that even though the `Box<T>` doesn't hold any `T`, and won't access `T` on drop, it does still own a `T` and will drop one when the `Box` is dropped.".
674. Read the [Rustonomicon](https://doc.rust-lang.org/nomicon/atomics.html).
675. `Miri` is the "mid-level intermediate representation interpreter" - you can use it to catch a lot of Rust specific bugs. Use it as a test suite extender.
676. `cargo-expand` expands crate macros.
677. `cargo-hack` is useful to check for all combos of features.
678. `cargo-llvm-lines` tells you which Rust lines give you which LLVMIR.
679. `cargo-udeps` tells you about unused dependencies.
680. Rust libs: 
- `bytes`: efficient byte subslices
- `criterion`
- `cxx`
- `flune`: mpmc channel.
- `hdrhistogram` fancy and compact representation of histograms
- `itertools`
- `slab`: replaces `HashMap<Token, T>`
- `static_assertions`
- `structopt` - typed `clap` cli builder
- `tracing`
681. `rustup +nightly miri` means that it will run MIRI and then revert back to previous settings. `cargo +1.53.0 check` will run your code with Rust `1.53.0` and then revert back to default.
682. `cargo tree --invert rand` will tell you all the places where your crate depends on `rand` so that you can excise it as a dep.
683. `cargo timings test` is now stable 🎉 
684. `rustc -Ztime-passes` is for all the compilation passes!
685. `cargo -Zprint-type-sizes` is a good combo with the `variant_size_differences` lint, which shows `enum` types where the variants have very different sizes.
686. `write!(&mut s, "{}+1={}", x, x + 1);` works to write into the String s!
687. `iter::once` is useful to append to iterators with `Iterator::chain` and for avoiding allocations.
688. `BufReader/BufWriter` batch many small read/writes into one large buffer and can have good perf perks.
689. If you feel like you need both `String/&str`, consider a `Cow<'a, str>` (never take it as a func arg, but do offer it as a return type.)
690. `Instant::elapsed` is clean!
691. `Clone::clone_from` can save some allocations!
692. Remote-tracking branches in git get moved whenever you do any network comms, to stay up to date with the remote repo (kinda like bookmarks). 
693. `git push origin serverfix:awesomebranch` to push local `serverfix` to the `awesomebranch` on the remote.
694. Set credentials with `git config --global credential.helper cache`.
695. A `tracking branch/upstream branch` are local branches that have a direct relationship to a remote branch.
696. `git checkout -b <branch> <remote>/<branch>` can be done with `git checkout --track origin/serverfix`, which can be done with `git checkout serverfix` if unique.
697. `git branch -v` and `git branch -vv` tell you if your branch is ahead, behind, or both. Remember to do `git fetch -all; git branch -vv`.
698. `git fetch` fetches all the changes but doesn't modify working directory - `git pull` does change working directory.
699. 2 ways to integrate changes from one branch to another:
- `rebase`: take a patch applied in Commit4 and reapply it to Commit3. Does linear work.
- `merge`: joining 2 branches with equal history (fast forwarding...). Does O(1) work at the end of the branches.
What differs here is the **history**! Not the contents!
700. **Do not rebase commits that exist outside your repo and tha tpeople may have based work on!**
701. Read about `Distributed Git` and `Public project over Email`

### 14/04/2022
702. Revisited the `leap year ` exercise in Rust. Instead of this crappy 1-liner
```rust
pub fn is_leap_year(year: u64) -> bool {
    (year % 100 != 0 || year % 400 == 0) && year % 4 == 0
}
```
You can use a neat `match`:
```rust
pub fn is_leap_year(year: u64) -> bool {
    match (year % 400, year % 100, year % 4) {
    (0, _, _) => true,
    (_, 0, _) => false,
    (_, _, 0) => true,
    _ => false,
    }
}
```
703. I forgot to do `array[low] < key || array[hi] < key` in a binary search algorithm. I will try to do it tomorrow recursively.

### 15/04/2022

704. Rust: Instead of doing this:
```rust
for i in 0..v.len() {
    w.push('-');
}
// try
(0..v.len()).foreach(|_| w.push('-'));
```

705. A `move` in a thread will try to move a variable into a thread's own stack. This may work for a bit, but if you want other threads to reference that same variable, the Rust compiler must known that that thread outlives all the others (so that the reference is always valid.) A way to get around that is to use a `Rc`, which is allocated on the heap and deallocated when no more threads are referencing it.

706. Unexpectedly useful list of "safer" C++ tooling [in the last slides of the Stanford CS110L](https://reberhardt.com/cs110l/spring-2021/slides/lecture-20.pdf) slides.

### 30/04/2022

707. Major unborking of my `nvim` was done by running `:UpdateRemotePlugins`.

708. OK, it turns out that some of my `` ` `` in the BQN article were erroring the site, which means the blogs after `FromJuliaToBQN` weren't showing up... inchresting! The solution was to use double ticks and spaces in between the code snippets. Hat tip to Eris from the APL/BQN Discord. Triple ticks require a newline, doulbe ticks don't.

### 22/06/2022

709. Getting a long and random list of digits in Julia:
```julia
julia> using Folds

julia> let s1 = string(BigFloat(π; precision = 2^20))[3:end],
           s2 = string(BigFloat(ℯ; precision = 2^20))[3:end],
           w = 4
           Folds.findfirst(1:length(s1)-w; basesize = 10000) do i
               SubString(s1, i, i + w) == SubString(s2, i, i + w)
           end
       end
26548
```
710. Bindings in a `begin ... end` block are global, bindings in `let ... end` block are local
711. `Apertium` is an [open source translation tool](https://www.apertium.org/index.eng.html#?dir=eng-epo&q=), so now I can do this:
```
# -u gets rid of * if it doesn't understand the word
mrg@pop-os ~> echo "This is a sentence" | apertium -u eng-spa 
Esto es una frase 
```
Tools like [Crow translate](ttps://github.com/crow-translate/crow-translate) also exist, which call out to the Google translate API, but I didn't get a proper install within 10 minutes so I'll just let it be.

### 23/07/2022

712. Redirecting an erroring makefile into a text file:
```bash
make &> error.txt
```
will slurp both stdout and stderr into a text file.


### 27/06/2022

715. If you type `:map` in `vim`, you get a list of all the mappings! Learned it from [the neovim docs](https://neovim.io/doc/user/usr_40.html).
716. `:imap`, `:nmap`, `:vmap` mean that your mapping/shortcut work in Insert mode, Normal mode, Visual mode.
717. If you select
```
4
3
2
1
```
And then run `:!sort`, Vim will run sort on your input!

### 30/07/2022

718. This exists in Julia 1.8:

```julia-repl
julia> @time_imports using CSV
      0.2 ms    ┌ IteratorInterfaceExtensions
    414.0 ms  ┌ TableTraits
    181.7 ms  ┌ SentinelArrays
      0.9 ms    ┌ Zlib_jll
      3.0 ms    ┌ TranscodingStreams
    175.8 ms  ┌ CodecZlib
      0.2 ms  ┌ DataValueInterfaces
     18.6 ms  ┌ FilePathsBase
     13.2 ms    ┌ InlineStrings
      1.8 ms    ┌ DataAPI
     93.8 ms  ┌ WeakRefStrings
     21.1 ms  ┌ Tables
     28.9 ms  ┌ PooledArrays
   3369.7 ms  CSV
```

719. How to copy paste [in tmux](https://linuxhint.com/copy-paste-clipboard-tmux/):

```
Step 1. Press the 'Prefix' (‘Ctrl+b) and then press '[' to enter the copy mode.

Step 2. Using the arrow keys, locate the position to start copying from. Use the 'Ctrl+spacebar' to start copying.

Step 3. Move with the arrow keys to the position of the text you want to copy to. When you have finished selecting the text, press ‘Alt+w’ or ‘Ctrl+w’ to copy the text to a Tmux Buffer.

Step 4. Paste the text to a Tmux pane/window/session using the Prefix (by default, it is 'Ctrl+b' ) followed by ']'.
```

720. This is what I use (besides `apertium eng-spa`) to get vim to translate a line for me and print it above with the `@q` macro:

```
" map leader to Space
nnoremap <SPACE> <Nop>
let mapleader = " "
:vmap <leader>t !apertium -u eng-spa<CR>
let @q = 'VypV t'
```

Hat tip to Jacob Zelko.

### 01/08/2022

721. Read: [Non-generic Inner functions](https://www.possiblerust.com/pattern/non-generic-inner-functions)

This can help cut down on monomorphization time and not pollute the namespace with `inner`:

```rust
// Taken from https://steveklabnik.com/writing/are-out-parameters-idiomatic-in-rust
pub fn read_to_string<P: AsRef<Path>>(path: P) -> io::Result<String> {
    fn inner(path: &Path) -> io::Result<String> {
        let mut file = File::open(path)?;
        let mut string = String::with_capacity(initial_buffer_size(&file));
        file.read_to_string(&mut string)?;
        Ok(string)
    }
    inner(path.as_ref())
}
```

722. [Rust and it's Orphan Rules](https://blog.mgattozzi.dev/orphan-rules/): If you split your crate into several, it can be a hassle to work with implementing types which "you own" but are external to your crate separation. Sometimes using the `newtype` idiom helps, other times you have to bust out the `PhantomData`.

723. [Chalk](https://rust-lang.github.io/chalk/book/#chalk-works-by-converting-rust-goals-into-logical-inference-rules) is the trait resolution system that rustc uses.

```
To do this, it takes as input key information about a Rust program, such as:

    * For a given trait, what are its type parameters, where clauses, and associated items
    * For a given impl, what are the types that appear in the impl header
    * For a given struct, what are the types of its fields

```

It lowers traits into `logical predicates`, then uses a `logic solver` to answer Yes/No.

It even has a REPL!

```
$ cargo run
?- load libstd.chalk
?- Vec<Box<i32>>: Clone
Unique; substitution [], lifetime constraints []
```

You can't quanitfy over traits, but you can over types and regions(lifetimes): `forall<T> {...}`.
Syntax: `consequence :- conditions`:
`impl<T: Clone> Clone for Vec<T> {}` => `forall<T> { (Vec<T>: Clone) :- (T: Clone) }`

This rule says `Vec<T>: Clone` is only satisfied if `T:Clone` is also provable.

Coherence - two impls of the same trait can't coexist.


724. The [difference between stack and cabal](https://blog.mgattozzi.dev/package-managers-for-programmers/) is how they deal with package version resolution.


725. Place marks with ```{lowercase_letter}`` and then you can jump to it with `` `{lowercase_letter}`` or check them with `:marks`.

726. Forem does automatic Search Engine Optimization - so it sounds like it's very profitable to post there, and it's FOSS anyways...

727. [Asserting Static properties in Rust](https://yakshav.es/asserting-static-properties/): Send, Sync, and object safety are the 3 big ones that may be implicitly derived but exporting them may silently break things.
Try this for Send and Sync:
```rust
struct MyType {
  inner: i32
}

fn _assert_send<T: Send>() {}
fn _assert_sync<T: Sync>() {}

fn _assertions() {
    _assert_send::<MyType>();
    _assert_sync::<MyType>();
}
```
Ooooh - `_assert_send<T: Senc>(){}`. is cool, as well as the `compile-fail` crate for proper integration into your test suite.

728. Absolutely enraging trying to figure out a working rust-analyzer + nvim combo.

729. Incredibly useful [Lifetime Variance Example](https://lifetime-variance.sunshowers.io/ch01-02-formalizing-variance.html) by `sunshowers`:
```
'b: 'a -> T<'b>: T<'a>    # Covariant     (Immutable data)
'b: 'a -> T<'a>: T<'b>    # Contravariant (uncommon, shows up in params to fn pointers)
'b: 'a -> ???             # Invariant (Inside a mutable context Cell/RefCell/Mutex or mulitple lifetimes conflict)
```

### 02/08/2022

730. When reviewing PRs on Github, use `a` and `i` to toggle showing `a`nnotations and comments.

731. Reading the [rustdoc book](https://doc.rust-lang.org/rustdoc/what-is-rustdoc.html).
* `///` is for outer docs, `//!` for the item present inside
* `rustdoc` only documents items that are publicly reachable - use `--document-private-items` otherwise
* take care with codegen options: `rustdoc --test src/lib.rs --codegen target_feature=+avx`
* run tests: `rustdoc src/lib.rs --test`.
* default theme: `rustdoc src/lib.rs --default-theme=ayu`
* you can prefix search with `mod:` to only restrict search results to `mod`s, `+`, `-`s expand and collapse all sections of the doc.

*Writing Good Docs:*
    * Have a summary of the role of the crate, links to explain technical deets, why you want to use the crate
    * Give an example of how to use it in a real world setting - but no shortcuts so that users can copy paste it.
    * use inline comments to explain complexities of using a `foo`. Good crates are `futures`, `backtrace` and `regex`.
    * first lines within `lib.rs` compose the front-page, and use `//!` to indicate module-level or crate-level docs.
    * public API should have docs:

    ```
    [short sentence explaining what it is]

    [more detailed explanation]

    [at least one code example that users can copy/paste to try it]

    [even more advanced explanations if necessary]
    ```

    * Footnotes:

    ```
    This is an example of a footnote[^note].

    [^note]: This text is the contents of the footnote, which will be rendered
    towards the bottom.
    ```

* You can do `#![warn(missing_docs)]` and `#![deny(missing_docs)]`.
* Also use `#![deny(missing_doc_code_examples)]`
* If you need to hide some lines that add noise, use `#`:

<!--```rust
/// Example
/// ```rust
/// # main() -> Result<(), std::num::ParseIntError> {
/// let fortytwo = "42".parse::<u32>()?;
/// println!("{} + 10 = {}", fortytwo, fortytwo+10);
/// #     Ok(())
/// # }
/// ```
```
-->

* Technically, `/// This is a doc comment` == `#[doc = " This is a doc comment"]`.
* These can be used for including external files via `#[doc = include_str!("../../READEM.md")]`
* Setup a favicon/logo/playground_url:

```rust
#![allow(unused)]
#![doc(html_favicon_url = "https://example.com/favicon.ico")]
fn main() {
}
```

* There's tons of ways [to use links](https://doc.rust-lang.org/rustdoc/write-documentation/linking-to-items-by-name.html).
* If you use results with `?`, stick it in a `main()`.
* macros need special handling
* You can add attributes to the triple ticks: `ignore`, `should_panic`, `no_run`, `compile_fail`, `edition2018`
* Lint with 

```rust
#![deny(rustdoc::broken_intra_doc_links)]
#![deny(rustdoc::missing_crate_level_docs)]
#![deny(rustdoc::missing_doc_code_examples)]
#![deny(rustdoc::invalid_code_block_attributes)]
#![deny(rustdoc::invalid_html_tags)]
#![deny(rustdoc::invalid_rust_codeblocks)]
#![deny(rustdoc::bare_urls)]
```

* omg - `rustdoc` can scrape your `examples/` directory with 

```bash
cargo doc -Zunstable-options -Zrustdoc-scrape-examples=examples
```
and on `docs.rs` with this in your `Cargo.toml`:

```toml
[package.metadata.docs.rs]
cargo-args = ["-Zunstable-options", "-Zrustdoc-scrape-examples=examples"]
```

* Perhaps have platform specific docs for stdsimd?

### 03/08/2022

732. This was a useful setup place for all the C++ shenanigans I needed: [Modern C++ for computer vision and image processing by Ignacio Vizzo and Cyrill Stachniss](https://www.youtube.com/watch?v=9mZw6Rwz1vg&list=PLgnQpQtFTOGRM59sr3nSL8BmeMZR9GCIA&index=5)

733. Hack: To get LLVM people to teach you free compiler lessons, show up to [Office Hours](https://llvm.org/docs/GettingInvolved.html#office-hours) and ask them questions.
Best shot for me right now:
- clicking through with my phone to add all the calendar invites to sync

### 04/08/2022

734. There seems to be very useful [Competitive Programming](https://searleser97.github.io/cpbooster/) plugins - [even for VSCode](https://agrawal-d.github.io/cph/).
- Both work with Codeforces, the first works with OmegaUp!
- You also need to install the `Competitive Programming Plugin`, then run `cpb init`, then `cpb clone` and click the green tab in Firefox to add the problem.

735. Setup [vim leap motion](https://github.com/ggandor/leap.nvim#usage). Not as good as `avy` in Doom emacs, but it's decent.

### 06/08/2022

736. Setting up your C++20 environment is... still painful. Even with item ``732`` above, I needed help with all my VSCode and ``C/C++`` plugin configs.
Recipe:
Open ``code`` in the root folder
In the root folder, run ``Configure Build Task`` and add this in the ``tasks.json`` that pops up:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "build with clang++ (c++20)",
            "command": "clang++",
            "args": [
                "-std=c++20",
                "-O2",
                "-fdiagnostics-color=always",
                "-fsanitize=address,undefined",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "compiler: clang++"
        }
    ]
}

```

This was thanks to ``Léo`` / ``@edhebi`` in the ``includecpp`` Discord Server. Thanks!

And then you can do `Run Build Task`, select the above task, and it should run. The task:
runs on C++20, uses address sanitizers and Undefined Behavior sanitizers, uses debug symbols so you can run the debugger.

### 08/08/2022

737. Uhhhhh, the `rr` guide says that to squeeze max perf from your laptop you should plug it in to the AC and then do:

```bash
sudo apt-get install cpufrequtils
sudo cpufreq-set -g performance
```

Which holds until next restart.

738. Remember (derp!) to get the [nvim-bqn](https://sr.ht/~detegr/nvim-bqn/) working by choosing a line and then doing `<leader>bf + Enter`. Otherwise it won't work. 

### 11/08/2022

739. Remember to set your Terminal font to `JuliaMono` if you want readable BQN code...
740. To convert a BQN array into a string and write it into afile (Like what you would need for `ppm` images for RayTracing in a weekend...)

```bqn
s ← •Repr¨ 1‿2‿4
"test.txt" •FLines s
PGM←{𝕨 •Fbytes ∾"P5 "‿(∾⟜"255" 2↓¯1↓•Fmt ≢𝕩)‿(@+10)‿(⥊𝕩)}
```

the last line writes out a PPM file (Credit to `Cake` from the BQN chat).

### 14/08/2022

741. To make a vector of 100 random Ints between `[1,3]` in APL, do

```apl
?100⍴3
```

742. Warning from APL:

```apl
In the expression A⍳B we search for B in A whereas in A∊B we search for A in B. Do not be confused!
```

This is the classic `Changing the Frame of Reference` concept:a list of area numbers (initial set) is translated into a list of discount rates (the final set):

```apl
r ← finalSet[initialSet ⍳ values]
```

### 15/08/2022

743. How to think about the `where`:

```apl
⍝ What items are greater than 75?

contents > 75

0 0 1 0 1 1 0 0 0 0 1 0

⍝ And where are they?

⍸contents > 75

3 5 6 11
```

744. Enclosures and partitions are powerful:
```apl

dyadic ⊂ (Partitioned enclose)

1 0 1 0 0 0 0⊂'HiEarth'

┌→─────────────┐
│ ┌→─┐ ┌→────┐ │
│ │Hi│ │Earth│ │
│ └──┘ └─────┘ │
└∊─────────────┘

2 0 3 0 0 0 0⊂'HiEarth'

┌→─────────────────────────┐
│ ┌⊖┐ ┌→─┐ ┌⊖┐ ┌⊖┐ ┌→────┐ │
│ │ │ │Hi│ │ │ │ │ │Earth│ │
│ └─┘ └──┘ └─┘ └─┘ └─────┘ │
└∊─────────────────────────┘


dyadic ⊆ (Partition)

1 1 2 2 2 2 2⊆'HiEarth'

┌→─────────────┐
│ ┌→─┐ ┌→────┐ │
│ │Hi│ │Earth│ │
│ └──┘ └─────┘ │
└∊─────────────┘

1 1 2 2 2 0 0⊆'HiEarth'

┌→───────────┐
│ ┌→─┐ ┌→──┐ │
│ │Hi│ │Ear│ │
│ └──┘ └───┘ │
└∊───────────┘

1 1 1 0 1 1 1 0 1 1 1 1⊆'How are you?'

┌→───────────────────┐
│ ┌→──┐ ┌→──┐ ┌→───┐ │
│ │How│ │are│ │you?│ │
│ └───┘ └───┘ └────┘ │
└∊───────────────────┘


```

745. Damn, apply a fill element/operation at a mask on an array with `@`:

```apl

Dyadic @ (At)

(0@2 4) ⍳6

┌→──────────┐
│1 0 3 0 5 6│
└~──────────┘

(3 1@2 4) ⍳6

┌→──────────┐
│1 3 3 1 5 6│
└~──────────┘

÷@2 4 ⍳6

┌→───────────────┐
│1 0.5 3 0.25 5 6│
└~───────────────┘

10 (×@2 4) ⍳5

┌→──────────┐
│1 20 3 40 5│
└~──────────┘

0@(2∘|)⍳6

┌→──────────┐
│0 2 0 4 0 6│
└~──────────┘

⌽@(2∘|)⍳6

┌→──────────┐
│5 2 3 4 1 6│
└~──────────┘

```

### 25/08/2022

746. Classes are tough man :/
747. To find why a package is needed in your repo, try `pkg> why Example`.
748. [dhat](https://docs.rs/dhat/latest/dhat/) can help with Rust precise allocations and testing.
749. [Read the Rust book with a quiz](https://rust-book.cs.brown.edu/) by Will Crichton and Shriram Krishnamurthi.

### 29/08/2022

750. To return a "Union type" of this

```rust
fn main() -> Result<(), ParseIntError> {
```

Say because you could have multiple Errors, and you want the `Result<(), XXX>` to handle those different cases, you can do it dynamically with

```rust
fn main() -> Result<(), Box<dyn error::Error>> {
```

aka we want to make `?` return possibly both types of errors.

The other way to do it is to make a `From` trait implementation from one Error type to another.

751. The `ref` keyword is useful for not moving (and actually borrowing) into a pattern binding:

```rust
let maybe_name = Some(String::from("Alice"));
// Using `ref`, the value is borrowed, not moved ...
match maybe_name {
    Some(ref n) => println!("Hello, {n}"),
    _ => println!("Hello, world"),
}
// ... so it's available here!
println!("Hello again, {}", maybe_name.unwrap_or("world".into()));
```

### 30/08/2022
752. Really like this method of building an `enum` of Rust error types and returning on them when different conditionals weren't handled - [great Rustlings error handling](https://github.com/alstn2468/rustlings-solution/blob/main/exercises/conversions/from_str.rs) exercise!

```rust
// We will use this error type for the `FromStr` implementation.
#[derive(Debug, PartialEq)]
enum ParsePersonError {
    // Empty input string
    Empty,
    // Incorrect number of fields
    BadLen,
    // Empty name field
    NoName,
    // Wrapped error from parse::<usize>()
    ParseInt(ParseIntError),
}
```

753. This was also a neat way to check many intervals of valid values:

```rust
impl TryFrom<(i16, i16, i16)> for Color {
    type Error = IntoColorError;
    fn try_from(tuple: (i16, i16, i16)) -> Result<Self, Self::Error> {
        match tuple {
            (r @ 0..=255, g @ 0..=255, b @ 0..=255) => Ok(Color{r as u8, g as u8, b as u8}),
            _ => Err(IntoColorError::IntConversion),
            }
        }
}
```

### 23/09/2022
754. Scoped threads! They rock! Instead of having to know that `let x: JoinHandle = thread::spawn(|| { ...});` and then to `x.join().unwrap();`

```rust
let mut numbers = vec![1, 2, 3];
    thread::scope(|s| {
        s.spawn(|| {
            numbers.push(1);
        });
        s.spawn(|| {
            numbers.push(2); // Error!
        });
    });
```

755. Use shadowing to your advantage and rename clones:

```rust
let a = Arc::new([1,2,3]);
let b = a.clone();
thread::spawn(move || { dbg!(b); });
dbg!(a);
```

vs

```rust
let a = Arc::new([1,2,3]);
thread::spawn({let a = a.clone(); move || { dbg!(a);}});
dbg!(a);
```

756. `Cell<T>` needs to do copies, `RefCell<T>` has runtime refcounting. Perf will depend on your use case.
757. The concurrent version of a `RefCell` is a `RwLock<T>`.
758. The concurrent version of a `Cell` is an Atomic type.
759. AHHHH! `PhantomData<T>` is treated by the compiler as `T`, but it doesn't exist as runtime, so it lets you opt out of being `Send/Sync`! This lets you prevent `X`

```rust
struct X {
    handle: i32,
    _not_sync: PhantomData<Cell()>>,
}
```

from being `Send + Sync`, since both `i32` and `Cell<()>` are `Send + Sync`!

760. Note: Do *NOT* put these into the same line, unless you really wanna increase the critical section drastically:

```rust
let item = list.lock().unwrap().pop();
if let Some(item) = item {
process_item(item);
}
```

### 24/09/2022

761. Mutexes are kinda primitive - you ideally don't want to get a lock to check a condition *every time*, so you use `parking` and `condition variable`. `Parking` puts a thread to sleep and not consume CPU cycles- then to be `waked up` by another thread.
762. When parking threads, it is possible to have `spurious wake ups` - but if `unpark()` is called before a thread parks itself it clears that signal from its queue and continues what it was doing. (But `park()` doesn't stack)
763. `Condition Variables` permit a `wait` and `notify` operation, which can be sent to 1 thread or all of them.

> To avoid the issue of missing notifications in the brief moment between unlocking a mutex and waiting for a condition variable, condition variables provide a way to atomically unlock the mutex and start waiting. This means there is simply no possible moment for notifications to get lost.

You can use these in Rust as `std::sync::CondVar` (e.g., is "is the quieue non-empty?" and wait on that).

### 25/09/2022

763. Thread parking with condition variables:

```rust
// 1. define the mutex and the Condvar
// 2. Start a thread scope, loop { useful }; drop(q); dbg!(item);
// 3. in a for loop, lock(), pushback(i), notify_one();, sleep
let queue = Mutex::new(VecDeque::new());
let not_empty = Condvar::new();

thread::scope(|s| {
    s.spawn(|| {
        loop {
            let mut q = queue.lock().unwrap();
            let item = loop {
                if let Some(item) = q.pop_front() {
                    break item;
                } else {
                    q = not_empty.wait(q).unwrap();
                }
            }
        };
        drop(q);
        dbg!(item);
    });

    for i in 0.. {
        queue.lock().unwrap().push_back(i);
        not_empty.notify_one();
        thread::sleep(Duration::from_secs(1));
    }
});
```

764. Atomics use `load` and `store`:

```rust
let num_done = AtomicUsize::new(0);
num_done.store(1+1, Relaxed);
num_done.load(Relaxed);
```

765. To avoid the last item in a collection to be waited on, you can `unpark()` the main thread (and `thread::park_timeout(Duration::from_secs(1));`:
```rust
thread::scope(|s| {
    s.spawn(|| {
        for i in 0..100 {
            process_item(i);
            num_done.store(i + 1, Relaxed)
            main_thread.unpark();
        }
    });
loop {
    lent n = num_done.load(Relaxed);
    if n == 100 {break;}
    println!("Working.. {n}/100 done");
    thread::park_timeout(Duraction::from_secs(1));
})
```

766. You can get a `race` that's not a `data race` - like with *lazy ininitialization*

```rust
fn get_x() -> u64 {
    static X: AtomicU64 = AtomicU64::new(0);
    let mut x = x.load(Relaxed);
    if x == 0 {
        x = calculate_x();
        X.store(x, Relaxed);
    }
    x
}
```

2 threads can see `0`, go off and calculate it (with different results!) and overwrite one another atomically.

but this is **Exactly** what Rust gives you with `std::sync::Once` and `std::lazy::SyncOnceCell`!

767. `fetch_add`, `fetch_min`, `fetch_xor`, and `swap(v:i32, ordering: Ordering) -> i32;` are all part of the *Fetch-And-Modify* Operations.
These implement `wrapping` behaviour for overflows.

768. And this is how you can aggregate statistics with threads, atomics and `Instant::now()`, `Instant::elapsed().as_micros()`:

```rust
fn main() {
    let num_done = &AtomicU32::new(0);
    let total_time = &AtomicU64::new(0);
    let max_time = &AtomicU64::new(0);
    thread::scope(|s| {
    // Four background threads to process all 100 items, 25 each.
    for t in 0..4 {
        s.spawn(move || {
            for i in 0..25 {
                let start = Instant::now();
                process_item(t * 25 + i);
                let time_taken = start.elapsed().as_micros() as u64;
                num_done.fetch_add(1, Relaxed);
                total_time.fetch_add(time_taken, Relaxed);
                max_time.fetch_max(time_taken, Relaxed);
            }
        });
    }
    // The main thread shows status updates, every second.
    loop {
    let total_time = Duration::from_micros(total_time.load(Relaxed));
    let max_time = Duration::from_micros(max_time.load(Relaxed));
    let n = num_done.load(Relaxed);
    if n == 100 { break; }
    if n == 0 {
        println!("Working.. nothing done yet.");
    } else {
        println!(
            "Working.. {n}/1000 done, {:?} average, {:?} peak",
            total_time / n,
            max_time,
        );
    }
    thread::sleep(Duration::from_secs(1));
    }
});
    println!("Done!")
}
```

769. If you are increasing a unique counter, and you want it to stop from ever reaching a certain size, you can
- check for it being over 1000, then `NEXT_ID.fetch_sub(1, Relaxed)`
- abort
- compare and exchange ops

770. Ah, `Relaxed Ordering` means that everyone will see the same modification sequence for a given Atomic value!

> 0 0 0 0 0 5 15
> 0 15 15 15

are possible but


> 0 5 0 15
> 0 0 10 15

are impossible. The *specific* sequence isn't specified, but it will be universal to all threads.

770. `Relaxed` Ordering cycles can happen in theory, but not in practice, so don't sweat it. (Called *out of thin air values*)

771. `Release` and `Acquire` are pairs - `Release` applies to store ops, `Acquire` to load ops. *Fetch-and-modify* and *comp-exchange* are both, so they can use `Release` or `Acquire`, or `Ordering::AcqRel`.

772. `Release` -> `Acquire` is the useful combo (Re-Lis + A = Lisa!).
773. What if you wanted to build up data more complex than a number? Try using `AtomicPtr<T>` and

```rust
fn get_data() -> &'static Data {
    static PTR: AtomicPtr<Data> = AtomicPtr::new(ptr::null_mut());
    let mut p = PTR.load(Acquire);
    if p.is_null() {
        p = Box::into_raw(Box::new(generate_data()));
        if let Err(e) = PTR.compare_exchange(ptr::null_mut(), p, AcqRel, Acquire) {
            // Safety: p comes from Box::into_raw right above,
            // and wasn't shared with any other thread.
            drop(unsafe { Box::from_raw(p) });
            p = e;
        }
    }
    // Safety: p is not null and points to a properly initialized value.
    unsafe { &*p }
}
```

buttttt - what if we didn't need the `AcqRel`? How can the data be accessed before it's created? We could use something weaker than `Acquire`, which is called `Consume` ordering.

774. `Consume`: if a `Release`-stored `x` value happens, `Consume`-loads are guaranteed to be later on dependent expressions like `*x`, `array[x]`, `table.lookup(x+1)`, but not necessarily before independent operations (those that don't use `x`).

775. Good news of the above - sometimes its free! Bad news: No compiler implements it :(
(Dead Code Elimination kills data flow dependencies sooooo...)

776. The easiest is `Sequentially Consistent Ordering`:
- every single op using `SeqCst` is part of a single total order all threads agree on 
- all guarantees of `Acquire` for loads
- all guarantees of `Release` for stores
...it's basically a stop sign. Quite inefficient.

777. `SeqCst` is usually a red flag - unless you have a logical `join`, try to use `Release`/`Acquire` combos.

778. You can apply memory ordering to atomic avriables, but also to `atomic fences`!

779. Fence equivalences:

```rust
a.store(1, Release);
// is the same as
fence(Release);
a.store(1, Relaxed);
```

and

```rust
a.load(Acquire);
// is the same as
a.load(Relaxed);
fence(Acquire);
```

780. Atomic fences are not tied to any particular atomic variable!

781. wtf is `std::hint::spin_loop()`???

> Within the while loop, we use a spin loop hint, which tells the processor that we’re 
> spinning while waiting for something to change. On most major platforms, this hint
> results in a special instruction that causes the processor core to optimize its behavior
> for such a situation. For example, it might temporarily slow down or prioritize other
> useful things it can do. Unlike blocking operations such as thread::sleep or
> thread::park, however, a spin loop hint does not cause the operating system to be
> called to put your thread to sleep in favor of another one.

782. You should think of `Release` and `Acquire` as related to `Mutex` locks!
783. Must re-visit -> implemting a `Guard` to make an `Unsafe Spinlock` to a `Safe Spinlock`! Chapter 4 - Atomics in Rust, Mara.
784. If we want to make a Safe One-Shot-Channel (and enforce safety through types), we need to try and restrict not calling `send` or `receive` more than once: make a funciton take an argument `by value`, and for `non-Copy` types, the object will be consumed.

785. To make a blocking interface, you can jam a `std::thread::Thread` inside a `Sender` struct:

```rust
pub struct Sender<'a, T> {
    channel: &'a Channel<T>,
    receiveing_thread: Thread // o.0
}
```

and restricting `Receiver` to not be `Send` with `PhantomData`:

```rust
pub struct Receiver<'a, T> {
    channel: &'a Channel<T>,
    _no_send: PhantomData<*const ()>, // o.0
}
```

786. Remember, `thread::park()` might return spuriously!, you need to loop!

```rust
pub fn receive(self) -> T {
    while !self.channel.ready.swap(false, Acquire) {
        thread::park();
    }
    unsafe {(*self.channel.message.get()).assume_init_read() }
}
```

787. "Exclusively borrowing and splitting borrows can be a powerful tool for forcing correctness!" - Mara :D

### 26/09/2022

788. We can represent a non-null pointer with `std::ptr::NonNull<T>` instead of `*mut T` or `*const T`.
789. Conditions for `Arc<T>` being `Send` iff `T` is both `Send + Sync`, and being `Sync` iff `T` is also both `Send + Sync`:

```rust
unsafe impl<T: Send + Sync> Send for Arc<T> {}
unsafe impl<T: Send + Sync> Sync for Arc<T> {}
```

789. `Box::leak` can be used to give up exclusive ownership of an allocation!
790. You can't unconditionally implement `DerefMut` for an `Arc` since you can't prove there will be exclusive access.
791. Ref counting is hard - especially so with *cyclic structures*. For that you need `Weak Pointers` - which are similar to `Arc`s but don't prevent objects from being dropped.
792. Mara recommends `cargo-show-asm` and `Compiler Explorer` for snippets.
793. WOW - going from

```rust
pub fn a(x: &Atomici32) {
    x.fetch_add(10, Relaxed);
}
// to ->
pub fn a(x: &Atomici32) -> i32 {
    x.fetch_add(10, Relaxed);
}
```

means you get the `exchange and add` instruction

```asm
a:
    move eax, 10
    lock xadd dword ptr[rdi], eax
    ret
```

but it only exists for `xadd` and `xchg` :(

794. On x86-64, there's no difference between `compare_exchange` and `compare_exchange_weak` - both compile down to a `lock cmpxchg` instruction.
795. Compare-and-Exchange loops on RISC architectures are `load linked/store-conditional` (LL/SC) loops. You need `ldxr` (load exclusive register) paired with `stxr` (store exclusive register) and `clxr` (clear exclusive register). This separation lets you have a `fetch_divide` or `fetch_shift_left` (when done with care).
795. `ARMV8.1` on `ARMV64` now has some common atomics: `ldadd` without an LL/SC loop, and it has `fetch_max`! Also a Compare And Swap `cas`.
796. ARM64 is *weakly ordered* - processor can reorder any memory op. x86-64 is *strongly ordered* - `Release/Acquire` semantics are "free" == identical to `Relaxed` operations.

### 30/09/2022

797. `std.rs/chain` will just search the docs for `chain`!
798. `cargo install cargo-show-asm` is super duper cool and easy for getting the assembly/MIR/LLVMIR of a function. (Hat tip to Mara).
799. To fill a slice with a number, just do: 

```rust
let mut buf = vec![0; 10];
buf.fill(1);
assert_eq!(buf, vec![1; 10]);
// Mara Pro tips:
v[1..10].fill(5);
// Or use resize
let mut vec = vec!["hello"];
vec.resize(3, "world");
assert_eq!(vec, ["hello", "world", "world"]);
// Gankra's Pro tips:
[1; 3].into_iter()
  .chain([5; 100])
  .chain([1; 3])
  .collect::<Vec<_>>();
```

800. Instead of accepting super crappy iterator code like this...

```rust
pub fn sgfilter6(v: Vec<f32>) -> Vec<f32> {
    // 5 filler elements
    // [1,1,1,1,1 ...]
    let v2 = v.clone();
    let mut iter = v2.iter();
    iter.next();
    iter.next();
    iter.next();
    iter.next();
    iter.next();

```

you can rock that code like Jubilee and now do:

```rust
fn accept_vec(v: Vec<f32>) -> () {
    if let [_, _, _, _, _, ref interesting @ .., _, _, _, _, _] = *v {
        assert!(interesting.len() > 0);
    } else {
        panic!("lol")
    }
}

#[test]
fn accept_eleven() {
    accept_vec(vec![0.; 11])
}

#[test]
#[should_panic]
fn reject_ten() {
    accept_vec(vec![0.; 10])
}
```

Jubilee says: You can use `iter.skip(5)`, but this has the advantage of pattern matching (which can result at compile time *without* const traits or skip to be const stable).


801. If you use `array_windows`, you are making super const intermediate arrays (no dynamic checking for bounds). (Nightly for now)

```rust
#![feature(array_windows)]
let slice = [0, 1, 2, 3];
let mut iter = slice.array_windows();
assert_eq!(iter.next().unwrap(), &[0, 1]);
assert_eq!(iter.next().unwrap(), &[1, 2]);
assert_eq!(iter.next().unwrap(), &[2, 3]);
assert!(iter.next().is_none());
```

### 03/10/22

802. [Zola](https://www.getzola.org/themes/blow/) is a static site generator that I can use with Rust. Perhaps worth knowing about if it can show images, and math.
803. [Recursion Unrolling for Divide and Conquer Programs](http://people.csail.mit.edu/rinard/paper/lcpc00.pdf). 
804. Finally found a place to learn *some* linear algebra in Rust, [the ndarray crate docs](https://docs.rs/ndarray/latest/ndarray/doc/ndarray_for_numpy_users/simple_math/index.html).

805. Remember to use the [soa_derive](https://crates.io/crates/soa_derive) crate to optimize using SIMD. It's gonna be a killer combo with *Ray tracing in One Weekend* in Rust.

806. Basics of [Data Oriented Design](http://jamesmcm.github.io/blog/2020/07/25/intro-dod/) with Rust.

807. Don't forget to use `RUST_FLAGS= -C target-cpu=native`.

### 03/26/24 

808. Up and at 'em.

Trying to ramp up for an LLVM GSoC and there's 3 cool candidates.

1. On making the `lit-tests`/unit tests UB free
2. On finding optimization parameters and tuning them
3. On adding the `<=>` to C++/Rust/Julia? LLVM IR for proper lowering.

Project 3 sound the most paedagogical and kinda the best deal for learning about a wide path of LLVM.

Things I've done so far:

* Setup a clickup projects with actionable tasks.
* Skimmed over the project [project descriptions](https://discourse.llvm.org/t/rfc-add-3-way-comparison-intrinsics/76685)
* Read the excellent [mcyoung's Gentle Introduction to LLVM IR](https://mcyoung.xyz/2023/08/01/llvm-ir/)
* Read the mentioned [PRs as prior art](https://github.com/llvm/llvm-project/commit/905abe5b5d8bfb0e7819d9215a4b52c9f3296414)
    * This one leaves some good room for learning the basic files to mess with.

Given it's a new intrinsic, there's only new unit tests to add but also some old tests to patch up.

We'll see how it goes.

Tomorrow I'll start by adding the node to `ISDOpcodes.h` and friends with some ample documentation.

I'll focus on doing 
* something concrete first related to the project
* then learning theory

There's [LLVM tutor](https://github.com/banach-space/llvm-tutor), the [DC888 LLVM course](https://homepages.dcc.ufmg.br/~fernando/classes/dcc888/ementa/),
[and the beginner links in the Discourse repo](https://discourse.llvm.org/t/beginner-resources-documentation/5872).



