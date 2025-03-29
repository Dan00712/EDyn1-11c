include(joinpath(
                 dirname(@__FILE__),
                 "logging_config.jl"
                ))
include(joinpath(
                 dirname(@__FILE__),
                 "funcs.jl"
                ))
using .funcs: calculatesum_evjen, normalizer, iterate

start_value = 3
println("convergent value $(iterate(start_value; func=calculatesum_evjen))")
