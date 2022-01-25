@def title = "Smoothing data with Julia's `@generated` functions - remixed"
@def tags = ["metaprogramming", "@generated"]
@def author = "Miguel Raz Guzmán Macedo"

**NB**: The following is a post that was originally written by [Dr. Jiahao Chen](https://medium.com/@acidflask/smoothing-data-with-julia-s-generated-functions-c80e240e05f3), 
a Julia pioneer and coding rockstar. Matt Bauman also contributed to the code,
but I updated it for Julia 1.+ in the hopes of learning some things about metaprogramming.

The heaviest editing is showing a different metaprogrammed code closer to what Stefan 
showed in his talk, as I think it's also easier to read and understand.
I packaged the code into a single function repository, benchmarking at 2x
the speed of the SciPy implementation.
You can find that [code here](https://github.com/miguelraz/StagedFilters.jl).

As usual, if you are a beginner and are wondering what metaprogramming is about,
check out [Dr. David Sander's tutorials](https://www.youtube.com/watch?v=rAxzR7lMGDM) 
on metaprogramming and remember Steven G Johnson's words to beginners on metaprogramming: 
["You probably don't need to metaprogram"](https://www.youtube.com/watch?v=mSgXWpvQEHE).

Additionally, if you want to have Stefan Karpinski himself give you a summary
of how the code works, there's a video of him talking 
[about this implementation specifically here](https://www.youtube.com/watch?v=DRKKAFYM9yo&feature=youtu.be&t=2047).

My contribution (Miguel Raz) was to make the code friendlier for SIMD analysis by massaging some of the index ordering. Hopefully people will look upon me kindly when [remixing the great work done by others](https://en.wikipedia.org/wiki/Ecce_Homo_Mart%C3%ADnez_and_Gim%C3%A9nez). This code should be parallelizable and scalable for GPU kernels, but that's for a future post.

**Table of Contents**
---

\toc

## Smoothing data with Julia's @generated functions - by Jiahao Chen

One of Julia’s great strengths for technical computing is its metaprogramming features, which allow users to write collections of related code with minimal repetition. One such feature is generated functions, a feature recently implemented in Julia 0.4 that allows users to write customized compute kernels at “compile time”.

## Another use case for generated functions

Section 5.7 of Jeff Bezanson’s thesis mentions an application of generated functions to boundary element method (BEM) computations, as described and implemented by Steven G. Johnson. These computations construct a Galerkin discretization of an integral equation, but the discretization process must take into account characteristics of the underlying integral kernel such as its singularities (pole structure) and the range of interactions, which in turn determine suitable choices of numerical integration (cubature) schemes. The Julia implementation uses Julia types to encode the essential features of the integral kernel in two type parameters that control the dispatch of cubature scheme, and is an elegant solution to what would otherwise be a tedious exercise in specialized code generation. Nonetheless, the BEM example may be difficult to follow for readers who are not familiar with the challenges of solving integral equations numerically. Instead, this post describes another application of generated functions to the smoothing of noisy data, which may be easier to understand.

## Smoothing data using a Savitzky-Golay filter

Generated functions can be used to construct a collection of filters to clean up data. One such filter was developed by [Savitzky and Golay](http://pubs.acs.org/doi/abs/10.1021/ac60214a047) in the context of cleaning up spectroscopic signals in analytical chemistry. The filtering method invented by Savitzky and Golay relies on least squares polynomial interpolation (of degree N) within a local moving window (of size 2M+1). An important property which makes the Savitzky-Golay method so incredibly useful in practice is that it [preserves the low moments of the data](https://inst.eecs.berkeley.edu/~ee123/sp15/docs/SGFilter.pdf), and thus the smoothening process preserves essential features of the peak structure in the data.

Given a degree N for the desired interpolating polynomial and a window size 2M+1, Savitzky and Golay derived a system of equations that governs the choice of optimal interpolation coefficients, which depend on M and N but not on the actual input data to be smoothened. In practice, the choice of parameters M and N are fixed (or scanned over a small range) and then applied to a large data vector. Hence, it would be ideal to generate specialized code for a particular choice of M and N, which can be applied quickly and efficiently. The problem, of course, is that we don’t know a priori which M and N a user wants. In a static language we would have no choice but to specify at compile time the allowed values of the parameters. However, Julia’s generated functions allow us to generate specialized methods when the filter is first applied to the data, without needing to compile all possible methods corresponding to all possible combinations of type parameters.
Implementation of Savitzky-Golay filters in Julia using generated functions.

```julia

"""
Savitzky-Golay filter of window half-width M and degree
N. M is the number of points before and after to interpolate, i.e. the full
width of the window is 2M+1.
"""
abstract type AbstractStagedFilters end

struct SavitzkyGolayFilter{M,N} <: AbstractStagedFilters end
wrapL(i, n) = ifelse(1 ≤ i, i, i + n)
wrapR(i, n) = ifelse(i ≤ n, i, i - n)

"""
smooth!(filter,data, smoothed) -
apply `filter` to `data` writing result to `smoothed`.
Note that feeding `Int`s and not floats as data will result in a performance slowdown.
"""
@generated function smooth!(::Type{SavitzkyGolayFilter{M,N}}, data :: AbstractArray{T}, smoothed :: AbstractArray{S}) where {M,N,T,S}

  J = T[(i - M - 1 )^(j - 1) for i = 1:2M + 1, j = 1:N + 1]
  e₁ = [one(T); zeros(T,N)]
  C = J' \ e₁
  pre = :(for i = 1:$M end)
  main = :(for i = $(M + 1):n - $M end)
  post = :(for i = n - $(M - 1):n end)

  for loop in (pre, main, post)
      body = loop.args[2].args

      idx = loop !== pre ? :(i - $M) : :(wrapL(i - $M, n))   # Manually start the first iteration. See the "false" branch below.
      push!(body, :( x = muladd($(C[1]), data[$idx], $(zero(T))))) # Swap `muladd` instead of the additions. Note the index of 1.

      for j = reverse(1:M-1) # Because we bumped out the first iteration, we have to reduce the for loop index by one.
          idx = loop !== pre ? :(i - $j) : :(wrapL(i - $j, n))
          push!(body, :( x = muladd($(C[M + 1 - j]),data[$idx],x))) # muladd
      end

      push!(body, :( x = muladd($(C[M + 1]), data[i], x))) # muladd

      for j = 1:M
          idx = loop !== post ? :(i + $j) : :(wrapR(i + $j, n))
          push!(body, :( x = muladd($(C[M + 1 + j]), data[$idx], x))) # muladd
      end
      push!(body, :(smoothed[i] = x))
  end

 last_expr = quote
          n = length(data)
          n == length(smoothed) || throw(DimensionMismatch())
          @inbounds $pre; @inbounds  $main; @inbounds $post
          return smoothed
  end

  return last_expr = Base.remove_linenums!(last_expr)
end;

```
## What this code do?

Unlike ordinary Julia functions, which return an ordinary value, generated functions return a quoted expression, which is then constructed and evaluated when when Julia’s dispatch mechanism decides to use this particular method family. In this generated function, the code for the function body undergoes delayed evaluation, and is first captured in expr while being manipulated. The actual interpolation coefficients C are not computed until the generated function is first called. In effect, generated functions allow us to customize how code is generated for Julia’s multimethod system. This example takes advantage of custom code generation in several ways:

1. The generated function does some linear algebra to determine what values to insert into the desired method body, first calculating the interpolation coefficients C from M and N by constructing J, the Jacobian (a.k.a. design matrix) of the filter, and then extracting the first row of its pseudoinverse by doing a least-squares solve on the canonical basis vector $e1$. The interpolation coefficients are then spliced into the generated expression using the `$(C[k])` dollar-sign syntax for [expression interpolation](https://docs.julialang.org/en/v1/manual/metaprogramming/#man-expression-interpolation).

2. 2M conditional additions are also inserted into the abstract syntax tree in expr before the function body gets compiled. M determines the number of terms in the interpolating expression, and at the end points the expression must be truncated to avoid going out of bounds when indexing into the data. (`expr.args[6].args[2].args[2]` is the particular tree traversal that gets us to the appropriate place to insert new leaf nodes into the AST.)
3. Some simple type arithmetic is needed to determine To, the element type of the output vector. Not all input vectors have element types that are closed under the interpolation process, which require taking linear combinations with floating point coefficients. (The Savitzky-Golay coefficients are actually rational, but proving this to be true remains elusive…) Since the output type can be determined when the generated function is called, there is no need to do the type computation at run time; instead, it can be hoisted into the generated function as part of the code generation process.

## Call overloading

This implementation of the Savitzky-Golay filter also makes use of call overloading, yet another feature introduced in Julia 0.4. Defining a new method for call() allows users to apply the SavitzkyGolayFilter type just like an ordinary function, by defining its constructor to perform the filtering. In fact, this snippet defines a family of new call methods, parametrized by the window halfwidth M, the polynomial degree N of the interpolant, and the element type of the data vector. The type parameters thus allow us to minimize repetition, while generating specialized code for each filter as it is called for a particular combination of type parameters.

**N.B**: Call overloading in modern Julia does not need to overload the `Base.call` method anymore. Now, we can write
```julia
@generated (::SavitzkyGolay{N,M} where {N, M})(xs)
```
And that is enough to overload the constructor call.


## Inspecting exprs as they are constructed

Putting an appropriate @show annotation on the returned expr allows us to see that the methods are indeed generated on demand, when the specific method associated with the appropriate run time values of M, N and T are invoked:

Astute readers will notice that:

1. The filter reasonably reproduces the original [1:11;] data set with reasonable fidelity, except at the very end where it starts to clamp the data. This is a well known limitation of polynomial interpolation that results from truncation — there simply aren’t enough data points at the end points for a reliable interpolation using the same polynomial used for the bulk. A proper treatment of the end points is needed.
2. `SavitzskyGolayFilter{M,1}` reduces to a simple moving average. Thus one interpretation of the Savitzsky-Golay filter is that it generalizes the moving average to also preserve higher moments other than just the mean.


## Similar constructs in other languages

In the beginning, I wrote that generated functions allow for “compile time” code manipulations. Strictly speaking, the term “compile time” is meaningless for a dynamic language like Julia, which by definition has no static semantics. In practice, however, Julia’s just-in-time compiler provides such a “compile time” stage which allows for delayed evaluation and manipulation of code. (See [Jeff’s JuliaCon 2014 presentation](https://www.youtube.com/watch?v=osdeT-tWjzk) where he goes through the various stages of code transformations that happen in Julia.) Put another way, generated functions cannot be explained with the usual compile/run model for evaluating code, but rather should be thought of as having an additional intermediate stage immediately prior run time where the code is not yet executed and the programmer is allowed to manipulate the code.

## Multistaged programming (MSP)

Julia’s generated functions are closely related to the [multistaged programming](http://link.springer.com/chapter/10.1007/978-3-540-25935-0_3) (MSP) paradigm popularized by [Taha and Sheard](http://dl.acm.org/citation.cfm?id=259019), which generalizes the compile time/run time stages of program execution by allowing for multiple stages of delayed code execution. Having at least one intermediate stage where code manipulations can take place before run time facilitates the writing of custom program generators and helps reduce the run time cost of abstraction. However, MSP cannot be retrofitted onto an existing language that does not support the requisite features for [AST manipulation, symbol renaming (gensym) and code reflection](http://link.springer.com/chapter/10.1007%2F978-3-540-39815-8_4). As a result, MSP usually requires a second language to describe the necessary annotations of code generation stages. The literature contains many examples of two-language systems such as [MetaML/ML, MetaOCaML/OCaML](http://link.springer.com/chapter/10.1007/978-3-540-25935-0_3#page-1), and [Terra/Lua](http://dl.acm.org/citation.cfm?doid=2594291.2594307). Similar tandem systems have been used for scientific computing purposes, such as the C code generator written in OCaML used to generate the [FFTW3 library](http://ieeexplore.ieee.org/xpl/tocresult.jsp?isNumber=30187&puNumber=5). In contrast, Julia’s generated functions provide built-in program generation without the need to reason about the intermediate stage in a different language, and is therefore closer to Rompf and Odersky’s [lightweight modular staging](http://dl.acm.org/citation.cfm?doid=2184319.2184345) approach for Delite, which is implemented entirely using Scala’s type system and requires no additional syntax.

## Parameteric polymorphism of method families

The use of type parameters here allows us to express an entire family of related computations (differing only in input data type and degree of polynomial filter) using [parametrically polymorphic](https://en.wikipedia.org/wiki/Parametric_polymorphism) generic functions. Similar constructs for parametric polymorphism exist in other languages also, such as C++ expression templates with overloaded operators, [Haskell typeclasses](http://dl.acm.org/citation.cfm?id=158698), as well as related language constructs in [Typed Racket](http://docs.racket-lang.org/ts-guide/types.html#%28part._.Polymorphism%29), [Fortress](http://dl.acm.org/citation.cfm?id=2048140), and [Dylan](https://dl.acm.org/citation.cfm?id=1869643.1869645).

However, I don’t think that the theoretical basis for parametric polymorphism in Julia is well understood. Parametric polymorphism is conventionally described in programming language theory using existentially quantified kinds in a Hindley-Milner type system, along the lines of [Cardelli and Wegner](http://dl.acm.org/citation.cfm?id=6042). Expressing parametric polymorphism in a static language construct (such as in C++ expression templates) becomes tedious in practice, because the compiler must either do whole program analysis to determine which methods are actually used by the user’s program, or in the absence of such information exhaustively generate all allowed methods. The result is long compile times, since program analysis is expensive and the number of possible methods grows combinatorially. However, in practice a user may use just a very few of the possibilities, or may even want a parameter combination that was not accounted for at compile time, or may want to write a program where the choice of parameters is only known at run time. Julia sidesteps this generation problem by registering the existence of these methods in the function’s method table, but compiles the method bodies only on demand, usually when function dispatch resolves to that specific method.

Since Julia allows for defining new methods at any point in program execution, existential quantification of parametric polymorphism, if it exists in Julia, must be thought of in a run time sense. Furthermore, it’s unclear if Julia’s type system, as formulated in terms of data flow analysis over type lattices, is even relatable to the ML-style Hindley-Milner type system. Furthermore, the Fortress development team have found that the formal type theory of parametrically polymorphic generic functions can get fantastically complex. Some recent work on the theory of [polymorphic functions](http://dl.acm.org/citation.cfm?id=2048140) over set theoretic types by Castagna and coworkers [1](http://dl.acm.org/citation.cfm?id=2535840) [2](http://dl.acm.org/citation.cfm?id=2676991) seems like a closer match to what Julia has, and is worth further scrutiny from a PL-theoretic perspective.
