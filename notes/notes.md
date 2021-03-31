Symbolics.jl grew out of ModelingToolkit.jl
all ODE/PDE stuff is in ModelingToolkit.jl



julia> @btime A .+= 1.0;
  671.889 μs (2 allocations: 64 bytes)

julia> function do_add2!(A, n)
           for j=1:n
               for i=1:n
                   A[i,j] += 1.0
               end
           end
       end
do_add2! (generic function with 1 method)

julia> @btime do_add2!($A, 1000);
  678.599 μs (0 allocations: 0 bytes)

julia> function do_add3!(A, n)
           for j=1:n
               for i=1:n
                   @inbounds A[i,j] += 1.0
               end
           end
       end
do_add3! (generic function with 1 method)

julia> @btime do_add3!($A, 1000);
  605.119 μs (0 allocations: 0 bytes)


