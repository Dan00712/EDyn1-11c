using Logging
Logging.global_logger(ConsoleLogger(Logging.Debug))

include(joinpath(
                 dirname(@__FILE__),
                 "funcs.jl"
                ))
using .funcs: calculatesum_primitive, normalizer, iterate

start_value = 3
println("convergent value $(iterate(start_value; func=calculatesum_primitive))")
