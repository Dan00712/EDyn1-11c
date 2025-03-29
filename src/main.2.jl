using Logging
Logging.global_logger(ConsoleLogger(Logging.Debug))

include(joinpath(
                 dirname(@__FILE__),
                 "funcs.jl"
                ))
using .funcs: calculatesum, normalizer

@debug ARGS
n0 = if length(ARGS) >= 1
    parse(Int, ARGS[1])
else 4 end

@assert n0 >= 4
V0 = calculatesum(n0-1)
println(V0)
V1 = calculatesum(n0)
println(V1)
println(dV)
dV = abs(V1-V0)/normalizer(V1)
if dV < 5e-4
    println("solution is excat")
else
    println("solution is to inexcat")
end
