function (var"##out#903", var"##arg#902")
    #= /home/mrg/.julia/dev/SymbolicUtils/src/code.jl:279 =#
    #= /home/mrg/.julia/dev/SymbolicUtils/src/code.jl:280 =#
    let u₁ = var"##arg#902"[1], u₂ = var"##arg#902"[2], u₃ = var"##arg#902"[3]
        #= /home/mrg/.julia/dev/Symbolics/src/build_function.jl:323 =#
        #= /home/mrg/.julia/dev/SymbolicUtils/src/code.jl:326 =# @inbounds begin
                #= /home/mrg/.julia/dev/SymbolicUtils/src/code.jl:322 =#
                var"##out#903"[1] = (+)(u₁, (*)(-1, u₃))
                var"##out#903"[2] = (+)((^)(u₁, 2), (*)(-1, u₂))
                var"##out#903"[3] = (+)(u₂, u₃)
                #= /home/mrg/.julia/dev/SymbolicUtils/src/code.jl:324 =#
                nothing
            end
    end
end