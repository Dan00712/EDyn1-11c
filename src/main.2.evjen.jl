include(joinpath(
                 dirname(@__FILE__),
                 "logging_config.jl"
                ))
include(joinpath(
                 dirname(@__FILE__),
                 "funcs.jl"
                ))
using .funcs: calculatesum_evjen, normalizer, ATOL

@debug ARGS
n0 = if length(ARGS) >= 1
    parse(Int, ARGS[1])
else 5 end

@assert n0 >= 3
V0 = calculatesum_evjen(n0-2)
println("V₀=\t$(V0)")
V1 = calculatesum_evjen(n0)
println("V₁=\t$(V1)")

Δ = abs(V1-V0)
dV = Δ/normalizer(V1)
println("Δ =\t$(Δ)")
println("dV =\t$(dV)")

if dV < ATOL
    println("solution is excat")
else
    println("solution is to inexcat")
end
