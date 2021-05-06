@def title = "Why Julia - introducing multiple dispatch"
@def author = "Miguel Raz Guzmán Macedo"
@def tags = ["dispatch"]


@@colbox-blue
# Hello, World! :wave: I'm Dispatch

My name's **Dispatch**,  your friendly neighbourhood walkie-talkie, and I'm here to talk to you all about Julia -  a cool programming language and why I think they made the right calls when they built it.
@@center ![](/assets/pixlr-bg-result.png) @@
@@


#### Reading time: 20 minutes
#### Summary:
This post is about Julia and *multiple dispatch* as its foundation.
Julia is not
- the first language to implement multiple dispatch (Common Lisp had it since a while ago)
- the only language to use multiple dispatch (Dylan does use it, available as a lib in Python and others)
but it definitely feels like the first to stick the landing. 
My **claim** is this: Julia is unique in implementing multiple dispatch as a fundamental design feature *and* build a language around it. Don't take it too seriously; it's more an invitation to learn than anything else.
If you like this topic, check out ["The Unreasonable effectiveness of Multiple Dispatch" JuliaCon](https://www.youtube.com/watch?v=kc9HwsxE1OY&t=346s) by Stefan Karpinski, so if you want to hear a more in-depth talk about this, go for it. This post is heavily inspired from that talk, but you don't wanna miss it. If I was being uncharitable, this post is the watered-down, kawaii-fied version of that talk with some Lisp memorabilia on top. Your mileage may vary.

The **audience** of this post are programmers who like Python/C++/80s MIT Lisp courses
who have heard of Julia but don't get what new things it brings to the table.
If you want to read articles that are more in depth, check out [Lyndon White's](https://invenia.github.io/blog/2019/10/30/julialang-features-part-1/) 2 part posts.

Sure, there's a fancy subtyping algorithm that Jeff Bezanson (Julia co-creator) pulled out of Turing-knows-where
and that Swift re-adapted with some unholy [term rewriting](https://fullstackfeed.com/formalizing-swift-generics-as-a-term-rewriting-system/) shenanigans,
but that's not the "new contribution" I mean - careful design iteration around multiple dispatch with measured trade-offs is.

The rest of this post are code snippets in other programming languages and how they look like next to a Julian re-implementation.

To talk about all these things, we'll be hearing from our newest battery-powered friend, **Dispatch**.

\dispatch{Hey peeps, that's me!}

... interspersed with a comments of our not-quite-yet-super-proficient-but-keeps-working-at-it-student, **miguelito**:


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

\dispatch{Of course! What's more natural than addition? You just haven't used the name multiple dispatch for it, which is fine. Bear with me for some simple arithmetic: Can you describe the procedure you know for adding integers? Say you want to add `123 + 890`. (This is a good moment to install and open julia from [julialang.org](julialang.org)) if you haven't already done so)}

\miguelito{Sure, you line up the digits, add the columns right to left, carry the ones...}

```julia-repl
julia> 123 + 890
```
\dispatch{Yup. What about trying to add `1//2 + 1//3`. What procedure do you follow then?}

\miguelito{Oh right, the famous `regla de tres` - find the common denominator, cancel, add up apples to apples...}

```julia-repl
julia> 1//2 + 1//3
5//6
```

\dispatch{Swell. And `.25 + 5.2`? You're still *"adding"* things right?}

\miguelito{Yup, like adding natural numbers - line 'em up, carry the one.}
```julia-repl
julia> .25 + 5.2
```

\dispatch{Excellent, ignore the decimals for now. Did you ever face matrices? Can you try to add `2x2` matrix of `1`s and a `2x2` matrix of `3`s?}

\miguelito{Yup - I think we defined it as element to element. So you end up with a `2x2` matrix of `4`s.}

```julia-repl
julia> [1 1; 1 1] + [3 3; 3 3]
[4 4; 4 4]
```

\dispatch{Alright - thanks for following along. Now here's the tickler question - Who does the `+` belong to?}

\miguelito{...qué.}

\dispatch{**Exactly**. If you know you're adding 2 Natural numbers, you just use, (or when coding, *call*) the right procedure. If you `+` 2 decimal numbers, you call the right thing. It's the addition you've always known! There's this *notion* of what `+` should do in different cases, and we wrap them all up under the same `+` umbrella - even though addition of matrices, decimals and natural numbers mean different procedures. You can check all the ones that come out of the box if you try this:}

```julia-repl
julia> methods(+)
```

\miguelito{Oh! So what does `+` have to do with property?}

\dispatch{Nothing - that's the point! It doesn't make sense to say that the `+` belongs to the `1` or the `2` in the statement `1 + 2`, and that's where the headaches come from: when you bind identity to objects, you're gonna have a bad time, [as 80s lisp hackers and philosophers alike have struggled with that question for a long, long time](https://youtu.be/dO1aqPBJCPg?t=3583) -- it's just *devilishly* hard to reason about identity when objects change. Avoid worrying about that if you can. Just worry about calling the right procedure in the right case. In other words, "just dispatch and carry on."}

---
### Single dispatch

This post promised comparing different languages. Now that we've discussed what we mean by dispatching, let's see how it's implemented. Astute readers have picked up that dispatching already exists in other languages, albeit in limited form: single dispatch.

I'm going to do some serious hand-waving here, so strap in: in Python and C++, and many other object oriented languages, you have the barebones version of dispatch. If a function takes an argument `f(a)` you can only dispatch on the type of the first argument.

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

 In the previous section, we wanted `f` to have two different behaviours depending on the types (and call it `polymorphic operator overloading`, if we want to bait some Dunning-Krugers on the [god-forsaken orange-site](http://n-gate.com/)). But we won't worry about fancy terms - we just want to our programming language tools to able to behave like the `+` we know from primary school. If you wanted 

\miguelito{Yeah, for reference, here's what the Julia code looks like:
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
And it works!}

\dispatch{Small nitpick - You actually *can* dispatch in Python, but it requires a bit of boilerplate, but that's a secondary concern. Since it wasn't a foundational design of the language, people didn't build a vocabulary or an ecosystem around it. In the words of Turing award winner Barbara Liskov,

> The quality of software depends primarily on the programming methodology in use. [...] A methodology can be easy or difficult to apply in a given language, depending on how well the language constructs match the structures that the methodology deems desirable. [...] -- Barbara Liskov, Abstractions Mechanisms in CLU (1977)

(Shoutout to [Quinn Wilton and her great Gleam presentation were I took this quote from](https://youtu.be/UCIcJBM_YDw?t=478)). Basically, not all [tools can fit nicely into a particular niche](https://www.youtube.com/watch?v=evthRoKoE1o), and insisting otherwise is a recipe for frustration, but I guess some companies just have billions in cash for R+D to burn. It's not only honest, but necessary, to know the limitations of your own tools.

}

\miguelito{Huh - sounds like Julia got really... lucky (?) in that it didn't need to be the first to run up against these problems? That knowledge seems to be accrued over decades by loads of smart people.}

\dispatch{:tada: Correct! :tada: Julia has benefitted immensely from the efforts of others. We gain nothing from being smug about recent successes - there's still lots of problems to solve and it's in our best interests that we nurture a diverse community of people that we can cross-pollinate ideas with. Maybe someone implements multiple dispatch with some different tradeoffs in Python (like the [Plum library!](https://github.com/wesselb/plum)) that show us a new way of thinking.   }

\miguelito{Hold up, you had mentioned that Julia's not the first to get multiple dispatch. Why didn't it pick up in the other languages?}

\dispatch{Hmmm, hard to say, I think we'd need to reach out to a legit PL historian for that. However, looking at some of the other key components that coalesce together helps suss some of it out:
1. Common Lisp had a very easy opt-in multiple dispatch system, but it was slow. People didn't buy in because it cost performance.
2. Performance was not an afterthought. Look at the graveyard of attempts to [speed up Python](https://wiki.python.org/moin/PythonImplementations), all mutually incompatible. The Julia devs designed the abstractions to match LLVM semantics to optimize for performance. At some point, you have to ask if you're standing in the right place to begin with, like the London cabby:

> Excuse me, what's the best way to get to Manchester?

> Ah, Manchester? I wouldn't start from here...

I just [wouldn't start with a language that takes 28 bytes to store an integer:](https://youtu.be/6JcMuFgnA6U?t=1089)
```python
Python 3.9.3 (default, Apr  8 2021, 23:35:02)
[GCC 10.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from sys import getsizeof
>>> x = 1
>>> getsizeof(1)
28
```

whereas
```julia-repl
julia> x = 1
1

julia> sizeof(x)
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
2. A big "the Romans had a steam engine but didn't industrialize because they didn't have carbon deposits" vibe.

There's a time and a place I guess.
}

\dispatch{Yeesh. 

Remember the starting claim for this discussion? It felt so long ago... but the gist was that for all the bells and whistles that Julia has, they needed time and effort to figure out some hard problems that other people had come up against (and whose expertise they drew from!). Julia is very much the place to park a decision until it gets done right, with oodles of discussions from experts back and forth. That's not a linear process, but I can't complain, we're still increasing the `SmileFactor` of all the things that feel like they should work, and do.
}

Until next time. Toodles. :wave:
If you want to see more posts like this, consider chucking a buck or two on my [GitHub sponsors](https://github.com/miguelraz), or, you know, hiring me as a grad student.
----


*Note*: **Dispatch** was made by copy/pasting the icon from [flaticon.com](https://www.flaticon.com/free-icon/walkie-talkie_1362060?related_id=1362009&origin=search&k=1618671790997) under the terms of their Flaticon License. It is free for personal and commercial purpse with attribution. I changed the colors to match the Julia dot logo colors. If you plan to use it for commerical purposes, please donate a non-trivial part of your profits from the **Dispatch** merch to [Doctors without Borders](https://donate.doctorswithoutborders.org/onetime.cfm). Thanks.
