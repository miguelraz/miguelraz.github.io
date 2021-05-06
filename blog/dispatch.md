@def title = "Why Julia - introducing multiple dispatch"
@def author = "Miguel Raz Guzmán Macedo"
@def tags = ["dispatch"]


@@colbox-blue
# Hello, World! :wave: I'm Dispatch

My name's **Dispatch**,  your friendly neighbourhood walkie-talkie, and I'm here to talk to you all about Julia -  a cool programming language and why I think it's just so neat.
@@center ![](/assets/pixlr-bg-result.png) @@
@@


#### Reading time: 20 minutes
#### Summary:
This post is about Julia and *multiple dispatch* as its foundation.
Julia is not
- the first language to implement multiple dispatch
- the only language to use multiple dispatch

but it definitely feels like the first to stick the landing. 
My **claim** is this: Julia is unique in implementing multiple dispatch as a fundamental design feature *and* build a language around it.

The **audience** of this post are programmers who like Python/R/C++/Rust
who have heard of Julia but don't get what new things it brings to the table.

Sure, there's a fancy subtyping algorithm that Jeff Bezanson (Julia co-creator) pulled out of Turing-knows-where
and that Swift re-adapted with some unholy [term rewriting](https://fullstackfeed.com/formalizing-swift-generics-as-a-term-rewriting-system/) shenanigans,
but that's not the "new contribution" I mean - careful design iteration around multiple dispatch with measured trade-offs is.

The rest of this post are code snippets in other programming languages and how they look like next to a Julian re-implementation.

To talk about all these things, we'll be hearing from our newest battery-powered friend, **Dispatch**.

\dispatch{Hey peeps, that's me!}

... interspersed with a comments of our not-quite-yet-super-proficient-but-keeps-working-at-it-student, **miguelito**:


\miguelito{¡Hola Dispatch! Nice to meet you!}

Off we go! 🚀
---

#### What is dispatch?

To begin our journey, we sould define some terms. Per [Merriam-Webster](https://www.merriam-webster.com/dictionary/dispatch):
> to send off or away with promptness or speed

> to dispatch a letter

> dispatch an ambulance to the scene

\dispatch{And if you have a dispatcher, which is what I do, then you call what you need at the right time. There's no need for extra fussing about! Sometimes you need to call a cab, sometimes its a delivery driver, sometimes its a helicopter. Just dispatch on what you need.}

\miguelito{Ok, call what you need. That sounds friendly I guess... but all these programmers from the Object Oriented Land keep asking me about [inheritance vs composition](https://en.wikipedia.org/wiki/Composition_over_inheritance), and my takeaway was that there's a lot of terms I *thought* knew what they meant, but I have to re-learn for all this programming stuff.}

\dispatch{Yup, there's a lot of fancy words. It can be hard to describe where you are standing to other people that only accept maps officially sanctioned by [the kingdoms of nouns](https://www.eecis.udel.edu/~decker/courses/280f07/paper/KingJava.pdf). Like namespaces, that's just not going to be as big a problem in Julia Land - you already know how to dispatch functions if you know addition.}

\miguelito{What? No way.}

\dispatch{Yup, it's why we say that multiple dispatch based design is natural! You just haven't used the name. Bear with me for some simple arithmetic: Can you describe the procedure you know for adding integers? Say you want to add `123 + 890`. (This is a good moment to install and open julia from [julialang.org](julialang.org)) if you haven't already done so)}

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

\dispatch{Excellent, ignore the decimals for now. Did you ever face matrices? Can you try to add `2x2` matrix of `1` and a `2x2` matrix of `3`s?}

\miguelito{Yup - I think we defined it as element to element. So you end up with a `2x2` matrix of `4`s.}

```julia-repl
julia> [1 1; 1 1] + [3 3; 3 3]
[4 4; 4 4]
```

\dispatch{Alright - thanks for following along. Now here's the tickler question - Who does the `+` belong to?}

\miguelito{...qué.}

\dispatch{**Exactly**. If you know you're adding 2 Natural numbers, or `Int`s in Julia, you just call the right procedure. If you `+` 2 decimals, call the right thing. It's the addition you've always known! There's this *notion* of what `+` should do in different cases, and we wrap them all up under the same `+` umbrella - even though addition of matrices, decimals and natural numbers are mean different procedures. You can check all the ones that come out of the box if you try this:}

```julia-repl
julia> methods(+)
```

\miguelito{Oh! So what does `+` have to do with property?}

\dispatch{Nothing - that's the point! It doesn't make sense to say that the `+` belongs to the `1` or the `2` in the statement `1 + 2`, and that's precisely where many of their headaches come from: they're tying identity to objects, and, as 80s Lisp hackers figured out a while ago, [philosophers have struggled with that question for a long, long time](https://youtu.be/dO1aqPBJCPg?t=3583), and it's *notoriously* hard to reason about identity when objects change. Avoid worrying about that if you can. Just worry about calling the right procedure in the right case. In other words, "just dispatch and carry on.}

#### Single dispatch

This post promised comparing different languages. Now that we've discussed a bit what we mean by dispatching, let's see how it's applied. Astute readers have picked up that dispatching already exists in other languages, albeit in limited form: single dispatch. This topic relates to one of the best [JuliaCon talks on Multiple Dispatch](https://www.youtube.com/watch?v=kc9HwsxE1OY&t=346s) by Stefan Karpinski, so if you want to hear a more in-depth talk about this, go for it. This post is heavily inspired from that talk.

I'm going to do some serious hand-waving here, so strap in: in Python and C++, and many other object oriented languages, you have the barebones version of dispatch. If a function takes two arguments `f(a, b)` you can only dispatch on the type of the first argument.

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

 We wanted `f` to have two different behaviours depending on the types (and call it `polymorphic operator overloading`, if we want to start a flame war on the [god-forsaken orange-site](http://n-gate.com/)). But we won't worry about fancy terms - we just want to our programming language tools to able to behave like the `+` we know from primary school.

\dispatch{Ruh roh! Something doesn't seem right there- just because you can't overload operators directly, doesn't mean you can't have single dispatch! See for example:}


##### C++ example

#### Java not being able to compile function


#### multiple dispatch

Common Lisp []
Plum []

Dylan


#### 


Turns out some people have actually done this in Python too!
[If you check out the plum project](https://github.com/wesselb/plum), you can do things like this:


@@row
@@container
@@colbox-blue
@@left ![image|<SCALE(180x180)>](/assets/favicon.ico)
@@
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
Marine iguanas are splendid creatures! check this math $\exp(-i\pi)+1$ but super cool 
@@
@@
@@
~~~
<div style="clear: both"></div>
~~~

-------
\dispatch{Hello this is me}

----
sep

@@row
@@container
@@colbox-red
@@right ![](/assets/astrofavicon/favicon.ico)
@@

**miguelito:**

And this is me!
@@
@@
@@
~~~
<div style="clear: both"></div>
~~~


------
testing new command
-----
\miguelito{wazzzzaaa}

\dispatch{this is now a dialog!}

\miguelito{Yes it is!

How about some Julia code here?

```julia
f(x) = x^2
```
}

\dispatch{How about some quotes?

> This is somehting very important that someone must have said

}

Convo finished!
