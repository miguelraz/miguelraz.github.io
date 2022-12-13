@def title = "Why Julia - Meet Dispatch"
@def author = "Miguel Raz Guzmán Macedo"
@def tags = ["dispatch"]
@def rss = "This blog is a friendly introduction to multiple dispatch in Julia"
@def rss_pubdate = Date(2021, 05, 09)
@def published = "09 May 2021"
@def rss_guid = 1


@@colbox-blue
# Hello, World! :wave: I'm Dispatch

My name's **Dispatch**,  your friendly neighbourhood walkie-talkie, and I'm here to talk to you all about Julia -  a cool programming language and why I think they made the right calls when they built it.
@@center ![](/assets/bigdispatch.png) @@
@@


#### Reading time: 20 minutes
#### Summary:
This post is about Julia and *multiple dispatch* as its foundation.
Julia is not
- the first language to implement multiple dispatch (see the lecture link below)
- the only language to use multiple dispatch (Dylan does use it, also available as a lib in Python and others)
but it definitely feels like the first to stick the landing. 
My **claim** is this: Julia is unique in implementing multiple dispatch as a fundamental design feature *and* building a language around it. Don't take it too seriously; it's more an invitation to learn than anything else.
If you like this topic, check out ["The Unreasonable effectiveness of Multiple Dispatch" JuliaCon](https://www.youtube.com/watch?v=kc9HwsxE1OY&t=346s) by Stefan Karpinski, and [this article on "The Expression problem"](https://eli.thegreenplace.net/2016/the-expression-problem-and-its-solutions/) which inspired that talk. If I was being uncharitable, this post is the watered-down, kawaii-fied version of that talk with some Lisp memorabilia sprinkled on top. Your mileage may vary.

The **audience** of this post are programmers who like Python/C++/80s MIT Lisp courses
who have heard of Julia but don't get what new things it brings to the table.
If you want to dive deeper into emergent Julia features, check out [Frame's](https://invenia.github.io/blog/2019/10/30/julialang-features-part-1/) 2 part posts.

Sure, there's a fancy subtyping algorithm that Jeff Bezanson (Julia co-creator) pulled out of Turing-knows-where
and that Swift re-adapted with some unholy [term rewriting](https://fullstackfeed.com/formalizing-swift-generics-as-a-term-rewriting-system/) shenanigans,
but that's not the "new contribution" I mean - careful design iteration around multiple dispatch with measured trade-offs is.

The rest of this post are code snippets in different programming languages and how they look like next to a Julian re-implementation.

To talk about all these things, we'll be hearing from our newest battery-powered friend, **Dispatch**.

\dispatch{Hey peeps, that's me!}

... interspersed with a comments of our not-yet-super-proficient-but-keeps-working-at-it-student, **miguelito**:


\miguelito{¡Hola Dispatch! Nice to meet you!}

Off we go! 🚀

## What is dispatch?

To begin our journey, we sould define some terms. Per [Merriam-Webster](https://www.merriam-webster.com/dictionary/dispatch), `to dispatch` means:
> to send off or away with promptness or speed

> to dispatch a letter

> dispatch an ambulance to the scene

\dispatch{And if you have a dispatcher, which is what I do, then you call what you need at the right time. There's no need for extra fussing about! Sometimes you need to call a cab, sometimes its a delivery driver, sometimes its a helicopter. Just dispatch on what you need.}

\miguelito{Ok, call what you nee-- Aaaaaah, now I get why you're a walkie-talkie. Clever! [I'll have to tell my friend Cool Bear](https://fasterthanli.me/series/advent-of-code-2020/part-3) about this one...

At any rate - dispatch sounds simple I guess... but all these programmers from the Object Oriented Land keep asking me about where I stand in [inheritance vs composition](https://en.wikipedia.org/wiki/Composition_over_inheritance), and my takeaway was that there's a lot of terms I *thought* knew what they meant, but I have to re-learn for all this programming stuff. I guess I'm just not that into Rectangle vs Square debates...}

\dispatch{Yup, there's a lot of fancy words. It can be hard to describe where you are standing to other people because [the Kingdoms of Nouns](https://www.eecis.udel.edu/~decker/courses/280f07/paper/KingJava.pdf) monopolized the programming language map-making business decades ago. 

Now it sucks to get directions anywhere.

But it's cool - just take a deep breath, and, like a well oiled StepMaster, we'll do this one step at a time. 

On namespaces as well, those debates are just not going to be as big a problem in Julia Land - we're not too far from them in the theory, but the language doesn't actively prevent you from doing what you already know. In fact, if you know addition, you already have a natural notion of what multiple dispatch is about.} 

\miguelito{What? No way.}

\dispatch{Of course! What's more natural than addition? You just haven't used the name multiple dispatch for it, which is fine. Bear with me for some simple arithmetic: Can you describe the procedure you know for adding integers? Say you want to add `123 + 890`. (This is a good moment to install and open julia from [julialang.org](https://www.julialang.org) if you haven't already done so.)}

\miguelito{Sure, you line up the digits, add the columns right to left, carry the ones...}

```julia-repl
julia> 123 + 890
1013
```
\dispatch{Yup. What about trying to add `1//2 + 1//3`. Those "fractions" are what we call `Rationals` in Julia. What procedure do you follow then?}

\miguelito{Oh right, the famous `regla de tres` - find the common denominator, cancel, add up apples to apples...}

```julia-repl
julia> 1//2 + 1//3
5//6
```

\dispatch{Swell. And `.25 + 5.2`? You're still *"adding"* things right?}

\miguelito{Yup, like adding natural numbers - line 'em up, carry the one.}
```julia-repl
julia> .25 + 5.5
5.75
```

\dispatch{Excelente, ignore the decimals for now. Did you ever face matrices? Can you try to add `2x2` matrix of `1`s and a `2x2` matrix of `3`s?}

\miguelito{Yup - I think we defined it as element to element. So you end up with a `2x2` matrix of `4`s.}

```julia-repl
julia> [1 1; 1 1] + [3 3; 3 3]
2×2 Matrix{Int64}:
 4  4
 4  4
```

\dispatch{Alright - thanks for following along. Now here's the tickler question - Who does the `+` belong to?}

\miguelito{...qué.}

\dispatch{**Exactly**. If you know you're adding 2 Natural numbers, you just use, (or when coding, *call*) the right procedure. If you `+` 2 decimal numbers, you call the right thing. It's the addition you've always known! There's this *notion* of what `+` should do in different cases, and we wrap them all up under the same `+` umbrella - even though addition of matrices, decimals and natural numbers mean different procedures. You can check all the ones that come out of the box if you try this:}

```julia-repl
julia> methods(+)
# 195 methods for generic function "+":
[1] +(x::T, y::T) where T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8} in Base at int.jl:87
[2] +(c::Union{UInt16, UInt32, UInt64, UInt8}, x::BigInt) in Base.GMP at gmp.jl:528
[3] +(c::Union{Int16, Int32, Int64, Int8}, x::BigInt) in Base.GMP at gmp.jl:534
...
```

\miguelito{Oh! But you stated that `+` "belongs" to someone, so what does `+` have to do with property?}

\dispatch{Nothing - that's the point! At least not in Julia. It doesn't make sense to say that the `+` belongs to the `1` or the `2` in the statement `1 + 2`, and that's where the headaches come from: when you bind identity to objects, you're gonna have a bad time, [as 80s lisp hackers and philosophers alike have struggled with that question for a long, long time](https://youtu.be/dO1aqPBJCPg?t=3583) -- it's just *devilishly* hard to reason about identity when objects change. Avoid worrying about that if you can. Just worry about calling the right procedure in the right case. In other words, "just dispatch and carry on."}

---
### Single dispatch

This post promised comparing different languages. Now that we've discussed what we mean by dispatching, let's see how it's implemented. Astute readers have picked up that dispatching already exists in other languages, albeit in limited form: single dispatch.

I'm going to do some serious hand-waving here, so strap in: in Python and C++, and other object oriented languages, you have the barebones version of dispatch. If a function takes an argument `f(a)` you can only dispatch on the type of the first argument.

Specifically, we want the function `f` to behave differently when the types of `a` are different. Recall our previous examples for addition: if `a` is an `Int`, we want it to do one thing - if it's an `Float64`, another thing.

Whipping up a Python REPL:
```python
>>> class Foo:
...     x = 1
...
>>> class Bar:
...     x = 1
...
>>> def f(a: Foo):
...     print("Just Foo")
...
>>> a = Foo()
>>> b = Bar()
>>> f(a)
Just Foo
>>> def f(b: Bar):
...     print("Just Bar")
...
>>> f(b)
"Just Bar"
>>> f(a)
"Just Bar"
```

**💥WHOOPS!💥** - something went wrong, we should have gotten a `"Just Foo"` in that last line!

## Multiple Dispatch

 In the previous section, we wanted `f` to have two different behaviours depending on the types (and call it `polymorphic operator overloading`, if we want to bait some Dunning-Krugers on the [god-forsaken orange-site](http://n-gate.com/)). But we won't worry about fancy terms - we just want to our programming language tools to able to behave like the `+` we know from primary school.

\miguelito{OK - I'll take a crack at this. I've read and reread the [Julia Manual page for Methods](https://docs.julialang.org/en/v1/manual/methods/), and I think I have a better idea of this now. Here's what my Julia code looks like:
```julia
abstract type Things end # We'll come back to this line
struct Foo <: Things end
struct Bar <: Things end
f(::Things) = "Just a Thing"
f(x::Foo) = "Just Foo"
f(x::Bar) = "Just Bar"
x = Foo()
y = Bar()
f(x)
f(y)
```
And it works! I like thinking about this as a table, just like what we talked about with `+`: I just check what types the arguments I'm applying `+` to are, and apply to proper procedure. Adding integers means line them up and carry the digits. Fractions, common denominators, etc. For `f`, if I apply it to an `Foo`, the procedure is to return the string `"Just Foo"`. If I apply `f` to an object `Bar`, it returns the string `"Just Bar."`. Dispatch and carry on, ach so...}

\dispatch{Great! You're on your way to learn the *Zen of Julia!*. It usually looks like
1. Setup an abstract type like `Things`.
2. Make some structs that are subtypes of `Things` with `<:`
3. Define functions `f` that act on specific subtypes of `Things` - aka dispatching.
4. Create your structs/objects with constructors like `x = Foo()` and then call `f(x)` to handle different behaviors.

That's it!

Small nitpick - You actually *can* dispatch in Python, but it requires a bit of boilerplate, but that's a secondary concern. Since it wasn't a foundational design of the language, people didn't build a vocabulary or an ecosystem around it. In the words of Turing award winner Barbara Liskov,

> The quality of software depends primarily on the programming methodology in use. [...] A methodology can be easy or difficult to apply in a given language, depending on how well the language constructs match the structures that the methodology deems desirable. [...] -- Barbara Liskov, Abstractions Mechanisms in CLU (1977)

(Shoutout to [Quinn Wilton and her great Gleam presentation were I took this quote from](https://youtu.be/UCIcJBM_YDw?t=478)). Basically, not all [tools can fit nicely into a particular niche](https://www.youtube.com/watch?v=evthRoKoE1o), and insisting otherwise is a recipe for frustration, but I guess some companies just have billions in cash for R+D to burn. It's not only honest, but necessary, to know the limitations of your own tools.

}

\miguelito{Huh - sounds like Julia got really... lucky (?) in that it didn't need to be the first to run up against these problems? That knowledge accrues over decades by loads of smart people by trying, failing, and figuring things out.}

\dispatch{:tada: Correct! :tada: Julia has benefitted immensely from the efforts of others. We gain nothing from being smug about recent successes - there's still lots of problems to solve and it's in our best interests that we nurture a diverse community of people that we can cross-pollinate ideas with. Maybe someone implements multiple dispatch with some different tradeoffs in Python (like the [Plum library!](https://github.com/wesselb/plum)), or [type class resolution in Lean](https://youtu.be/UeGvhfW1v9M?t=3011) or whatever they're building with [F\*](https://www.fstar-lang.org/tutorial/) that shows us a new way of thinking. We lose nothing by encouraging people to experiment, far and wide.}

\miguelito{Hold up, you had mentioned that Julia's not the first to get multiple dispatch. Why didn't it pick up in the other languages?}

\dispatch{Hmmm, hard to say, I think we'd need to reach out to a legit PL historian for that. However, looking at some of the other key components that coalesce together helps suss some of it out:
1. Common Lisp had an easy opt-in multiple dispatch system, but it was slow. People didn't buy in because it cost performance. There's a social factor to this - if your paradigm takes more effort to use, it's less likely to be grow.
2. Performance was not an afterthought. Look at the graveyard of attempts to [speed up Python](https://wiki.python.org/moin/PythonImplementations), all mutually incompatible. The Julia devs designed the abstractions to match LLVM semantics to optimize for performance. At some point, you have to ask if you're standing in the right place to begin with, like the London cabby:

> Excuse me, what's the best way to get to Manchester?

> Ah, Manchester? I wouldn't start from here...

I don't think Python for performance has failed, but [wouldn't start with a language that takes 28 bytes to store an integer:](https://youtu.be/6JcMuFgnA6U?t=1089)
```python
Python 3.9.3 (default, Apr  8 2021, 23:35:02)
[GCC 10.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from sys import getsizeof
>>> getsizeof(1)
28
```

whereas
```julia-repl
julia> sizeof(1) # This is in bytes, so an Int on my system is 64 bits
8 
```

3. Speaking of LLVM - JIT compilers are a recent invention, and if LLVM didn't have an open source implementation, who knows if Julia would have picked up. Caching the computation really helps to overcome the beaurocratic overhead of the dispatching system, and it's not at all trivial to see those two things and put them together. But don't take my word for it, hear **them** say why it wasn't practical then:

[![Lisp hackers preaching the Julia gospel](https://imgur.com/zA72zGB.png)](https://youtu.be/OscT4N2qq7o?t=1598)

4. That video tells precisely the pain-point that Stefan talked about for functional languages in his talk: In Functional Land, it's easy to add new procedures to old types, but *unwieldy* to add new types to old functions.

Concretely, the code that stumps object oriented PLs is
```julia
f(x::Foo) = "Just Foo"
f(x::Bar) = "Just Bar"
```

and the one that stumps functional language oriented PLs without multiple dispatch is
```julia
struct Qux <: Things end
t = Qux()
f(t)
```


}

\miguelito{Alright so what I'm really getting here is 

1. I should really, really [just go watch Stefan's talk](https://youtu.be/kc9HwsxE1OY?t=1564).
2. A big "the Romans had a steam engine but didn't industrialize because they didn't have carbon deposits" vibe from all the convergence of PL ideas and techniques.

There's a time and a place I guess.
}

\dispatch{Yeesh. 

Remember the starting claim for this discussion? It felt so long ago... but the gist was that for all the bells and whistles that Julia has, they needed time and effort to figure out some hard problems that other people had come up against (and whose expertise they drew from!). Julia is the place to park a decision until it gets done right, with oodles of discussions from experts back and forth. That's not a linear process, but I can't complain, we're still increasing the `SmileFactor` of all the things that feel like they should work, and do. Like [the REPL](https://www.youtube.com/watch?v=EkgCENBFrAY).
}



Until next time. Toodles. :wave:

---

If you want to see more posts like this, consider chucking a buck or two on my [GitHub sponsors](https://github.com/miguelraz), or, you know, hire me as a grad student.


*Note*: 
----
I created **Dispatch** by copy/pasting the icon from [flaticon.com](https://www.flaticon.com/free-icon/walkie-talkie_1362060?related_id=1362009&origin=search&k=1618671790997) under the terms of their Flaticon License. It is free for personal and commercial purpse with attribution. I changed the colors to match the Julia dot logo colors. If you plan to use it for commerical purposes, please donate a non-trivial part of your profits from the **Dispatch** merch to [Doctors without Borders](https://donate.doctorswithoutborders.org/onetime.cfm).

Thanks a lot to the Julia community for helping with this post, but especially to Thiebaut Lienart and the Franklin.jl team, Stefan Karpinski for his talk and Frames for her blog posts diving into these similar materials.
