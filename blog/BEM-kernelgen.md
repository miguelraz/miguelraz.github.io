@def title = "The Boundary Element Method as an application of Julia's @generated functions"
@def tags = ["metaprogramming", "@generated", "compile time"]


**NB** - This notebook was originally made, some years ago, by Steven G. Johnson. I took the pre 1.0 Julia code and updated it so as to teach myself and others some useful concepts about generated functions in Julia.
It is based on the idea of generated functions and staged programming of chapter 3.5.2 of Jeff Bezanson's PhD thesis [on the Julia Language](https://github.com/JeffBezanson/phdthesis/blob/master/main.pdf).This transcription is shared with the author's permission.

-- Miguel Raz, 2020

\toc

# Kernel transformation

Input: kernel function $ K(r) $.  Output "first integral" of $ K $ : 

$$
\mathcal{K}_n(X) = \int_0^1 w^n K(wX) dw
$$

for $X \in (0,\infty)$.   Some small set of $n$ values, to be determined, will be supplied at compile time.

$K$ will be specified as a subtype of `AbstractKernel`.

* For some kernel types, $\mathcal{K}_n$ is known analytically.  (See Table I in [Homer's paper](http://math.mit.edu/~stevenj/papers/ReidWhJo14.pdf).)

* $K$ may depend on some compile-time numeric parameters, specified as type parameters.

* If the $\mathcal{K}_n$ integral is *not* known analytically, we may have to compute it numerically.  This will be done at *compile time* by staged functions, with the numeric integration results used to compute the coefficients of a Chebyshev polynomial fit, which can then be compiled into an efficient polynomial approximation of $\mathcal{K}_n$.   However, to compute a Chebyshev approximation for a function defined on $(0,\infty)$, we will have to perform a coordinate transform from $X \to (0,1)$, and the type of coordinate transformation will depend on how fast $\mathcal{K}_n$ decays asymptotically as $X\to\infty$.  This decay rate can be *specified via the type* of `K`.

The $\mathcal{K}_n$ function will be parameterized by a `FirstIntegral{K,n}` type parameterized by an `AbstractKernel` type `K` and an integer `n`.
```julia
abstract type AbstractKernel end
```
Any kernel ~ X^P for X ≪ S and ~ X^Q for X ≫ S
```julia
abstract type PowerLawScaling{P,Q,S} <: AbstractKernel end
```
```julia
immutable FirstIntegral{K<:AbstractKernel,N} end
```
# Analytically known integrals:
```julia
immutable PowerLaw{p} <: PowerLawScaling{p,p,p} end # rᵖ power law}

function (::FirstIntegral{PowerLaw{p},n})(X::Number) where {p,n}
    return p >= 0 ? X^p / (1 + n + p) : inv(X^(-p) * (1 + n + p))
end

F = FirstIntegral{PowerLaw{-1}, 3}()
F(3.7)
```
```julia
@code_llvm F(3.7)
```
# Numerically computed integrals

In a general multi-physics BEM package, one might conceivably have a user-specified kernel $K$ for which the first integral $\mathcal{K}_n$ is *not* known analytically.   Performing the integral numerically at runtime would be too expensive, however, especially since the integrand may have an integrable singularity.

Instead, we will perform the integral $\mathcal{K}_n$ at *compile-time* (or, at least, outside the innermost BEM loops) for various $X$ and use these values to compute a *Chebyshev interpolating polynomial* $C(\xi)$.  This polynomial will then be used to generate an efficient $\mathcal{K}_n(X)$.

There are three tricky points:

* $\mathcal{K}_n(X)$ will probably be singular as $X\to 0$, which means we can't fit it directly to a polynomial.  (This is not a problem for how $\mathcal{K}_n$ is *used*, because $\mathcal{K}_n$ is always used for integration over domains that do not include $X=0$.)   This will be dealt with by requiring the user to specify the degree $p$ of the singularity as $X \to 0$: i.e. $\mathcal{K}_n(X) = O(X^p)$ for $X\to 0$.  We will factor out this singularity from $\mathcal{K}_n$ and fit the remaining (non-singular) function to a polynomial.

* We need $\mathcal{K}_n(X)$ for $X \in (0,\infty)$, whereas polynomial interpolation requires a finite interval, typically $(-1,1)$.   We will handle this by choosing a coordinate mapping $\xi(X) \in (-1,1)$.  Because such a coordinate mapping is necessarily singular, however, it will screw up the convergence of polynomial interpolation if we choose the wrong degree of singularity — we want a mapping such that $\mathcal{K}_n(\xi(X))$ is nonsingular (e.g. a low-degree polynomial in $\xi$) as $X\to\infty$.   To choose this, the user will specify a degree $q$ of the decay rate as $X\to\infty$, i.e. $\mathcal{K}_n(X) = O(X^q)$ for $X\to \infty$.

* $X$ is dimensionful (it is a physical distance within one of the triangles or other geometric elements of the BEM basis).  Mapping it to a dimensionless $\xi$ inevitably involves choosing a scale $s$ of $X$.   This $s$ should be user-specified (e.g. it can be the median diameter of the BEM elements).  That is, $\mathcal{K}_n(X) \sim X^p$ for $X \ll s$ and $\mathcal{K}_n(X) \sim X^q$ for $X \gg s$.

In summary, the user will specify a `PowerLawScaling{p,q,s}` kernel type parameterized by `p`, `q`, and `s`.  They will also define a `(::PowerLawScaling{p,q,s})(r::Number)` method that computes $K(r)$.

The polynomial fit will be performed as follows, assuming $p \le 0$ and $q \le 0$.  First, we let $L_n(X) = \mathcal{K}_n(X) / (s^p + X^p)$, which eliminates the $x\to 0$ singularity while still having $L_n \sim X^q$ for $X \gg s$.   Second, we let $X = (1-\xi)^{1/q} - 2^{1/q}$ [or equivalently $\xi = 1 - (x+2^{1/q})^q$], which maps $\xi \in (-1,1)$ to $X \in (0,\infty)$, and has the property that $X^q \approx 1-\xi$ as $\xi\to 1$, so the coordinate remapping produces a nice degree-1 polynomial.   Finally, we fit $L_n(\xi(X)) = C(\xi)$ to a Chebyshev polynomial $C$, and compute $\mathcal{K}_n(X)$ via $\mathcal{K}_n(X) = (s^p + X^p) \times L_n(\xi(X))$.

# Chebyshev interpolation

The following routines compute the coefficients $c_n$ of a Chebyshev interpolating polynomial $C(x) = \sum_{n=0}^{N-1} c_n T_n(x)$ for a function $f(x)$ on $(-1,1)$, where $T_n(x) = \cos(n \cos^{-1}x)$ are the first-kind Chebyshev polynomials.

We compute these coefficients $c_n$ by first evaluating $f(x)$ at the Chebyshev points $\cos\left(\pi\frac{n+1/2}{N}\right)$ for $n=0,\ldots,N-1$, for which the Chebyshev sum is equivalent to a type-III discrete cosine transform (DCT-III), so that the coefficients $c_n$ are computed by a DCT-II.   These are *not* quite the typical Chebyshev points, which correspond to a DCT-I: the difference is that the DCT-I corresponds to the closed interval $[-1,1]$, i.e. it includes the endpoints, whereas our function may involve terms that blow up at the endpoints (although the overall function should be okay) so we don't want to evaluate it there.

We also provide a function `evalcheb` to evaluate $C(x)$ for any $x\in(-1,1)$ by a Clenshaw recurrence, and a macro version `@evalcheb` (analogous to `Base.@horner`) that generates a completely inlined version of this recurrence for the case where $c$ is fixed.

```julia
#Pkg.add("FFTW");
using FFTW
```
$N$ chebyshev points (order N) on the interval $(-1,1)$
```julia
chebx(N) = [cos(π*(n+0.5)/N) for n in 0:N-1]
```

$N$ chebyshev coefficients for vector of $f(x)$ values on $chebx$ points $x$
```julia
function chebcoef(f::AbstractVector)
    a = FFTW.r2r(f, FFTW.REDFT10) / length(f)
    a[1] /= 2
    return a
end
```

Given a function $f$ and a tolerance, return enough Chebyshev coefficients to reconstruct $f$ to that tolerance on $(-1,1)$

```julia
function chebcoef(f, tol=1e-13)
    N = 10
    local c
    while true
        x = chebx(N)
        c = chebcoef(float[f(y) for y in x])
        # look at last 3 coefs, since individual c's might be zero
        if maximum(abs,c[end:end-2]) < tol * maximum(abs,c)
            break
        end
        N *= 2
    end
    v₀ = maximum(abs,c) * tol
    return c[1:findlast(v -> abs(v) > tol, c)] # shrink to minimum length
end

function chebcoef(f, tol=1e-13)
    N = 10
    local c
    while true
        x = chebx(N)
        c = chebcoef(Float64[f(y) for y in x])
        # look at last 3 coefs, since individual c's might be zero
        if maximum(abs,c[end:end-2]) < tol * maximum(abs,c)
            break
        end
        N *= 2
    end
    v₀ = maximum(abs,c) * tol
    return c[1:findlast(v -> abs(v) > tol, c)] # shrink to minimum length
end
```

Given $cheb$ coefficients $a$, evaluate them for $x$ in $(-1,1)$ by Clenshaw recurrence
```julia
function evalcheb(x, a)
    isempty(a) && throw(BoundsError())
    -1 ≤ x ≤ 1 || throw(DomainError())
    bₖ₊₁ = bₖ₊₂ = zero(x)
    for k = length(a):-1:2
        bₖ = a[k] + 2x*bₖ₊₁ - bₖ₊₂
        bₖ₊₂ = bₖ₊₁
        bₖ₊₁ = bₖ
    end
    return a[1] + x*bₖ₊₁ - bₖ₊₂
end

# inlined version of evalcheb given coefficents a, and x in (-1,1)
macro evalcheb(x, a...)
    isempty(a) && throw(BoundsError())
    # Clenshaw recurrence, evaluated symbolically:
    bₖ₊₁ = bₖ₊₂ = 0
    for k = length(a):-1:2
        bₖ = esc(a[k])
        if bₖ₊₁ != 0
            bₖ = :(muladd(t2, $bₖ₊₁, $bₖ))
        end
        if bₖ₊₂ != 0
            bₖ = :($bₖ - $bₖ₊₂)
        end
        bₖ₊₂ = bₖ₊₁
        bₖ₊₁ = bₖ
    end
    ex = esc(a[1])
    if bₖ₊₁ != 0
        ex = :(muladd(t, $bₖ₊₁, $ex))
    end
    if bₖ₊₂ != 0
        ex = :($ex - $bₖ₊₂)
    end
    Expr(:block, :(t = $(esc(x))), :(t2 = 2t), ex)
end
```

Let's try a simple test case: performing Chebyshev interpolation of $\exp(x)$:
```julia
c = chebcoef(exp)
x = linspace(-1,1,100)
maximum(abs.(Float64[evalcheb(y,c) for y in x] - exp.(x))) # the maximum error on [-1,1]

# check that the evalcheb macro works
evalcheb(0.1234, c[1:4]) - @evalcheb(0.1234, c[1],c[2],c[3],c[4])
```

# First-integral generation

```julia
# extract parameters from PowerLawScaling type
pqsPowerLawScaling{p,q,s}(::PowerLawScaling{p,q,s}) = (p,q,s)
```

Extract parameters from PowerLawScaling type
```julia
pqsPowerLawScaling{p,q,s}(::PowerLawScaling{p,q,s}) = (p,q,s)

@generated function (::FirstIntegral{P,n}, X::Real) where {P<:PowerLawScaling,n}
    # compute the Chebyshev coefficients (of the rescaled 𝒦ₙ as described above)
    K = P()
    p,q,s = pqsPowerLawScaling(K)
    
    𝒦ₙ = X -> quadgk(w -> w^n * K(w*X), 0,1, abstol=1e-12, reltol=1e-10)[1]
    Lₙ = p < 0 ? X -> 𝒦ₙ(X) / (s^p + X^p) : 𝒦ₙ # scale out X ≪ s singularity
    q > 0 && throw(DomainError()) # don't know how to deal with growing kernels
    qinv = 1/q
    c = chebcoef(ξ -> Lₙ((1-ξ)^qinv - 2^qinv), 1e-9)
    
    # return an expression that inlines the evaluation of 𝒦ₙ via C(ξ)
    quote
        X <= 0 && throw(DomainError())
        ξ = 1 - (X + $(2^qinv))^$q
        C = @evalcheb ξ $(c...)
        return $p < 0 ? C * (X^$p + $(s^p)) : C
    end
end
```

A simple example where the result is known analytically:
```julia
immutable DumbPowerLaw{p,s} <: PowerLawScaling{p,p,s}; end # rᵖ power law
(::FirstIntegral{DumbPowerLaw{p,s}})(r)  where {p,s} = r^p
F = FirstIntegral{DumbPowerLaw{-1,1.0},3}()
F(3.7)
@code_llvm F(3.7)
```

```julia
#Pkg.add("PyPlot")
using PyPlot
x = [0.01:.0125:1.0;]; 
plot(x, map(FirstIntegral{DumbPowerLaw{-1,1.}, 3}(),x))
```
