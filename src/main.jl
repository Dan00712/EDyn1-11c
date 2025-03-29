using Logging
Logging.global_logger(ConsoleLogger(Logging.Debug))

include(joinpath(
                 dirname(@__FILE__),
                 "funcs.jl"
                ))
using .funcs: calculatesum, normalizer

function iterate(start_value=3)
    current = 0
    prev = calculatesum(start_value-1)
    for i in start_value:10_000+start_value
        current, dt = let
            t0 = time()
            tmp = calculatesum(i) #calculate_partial_sum(i, prev)
            tmp, time() - t0
        end
        @debug "Iteration and Δ between iterations" i current - prev
        @debug "iteration took" dt

        normalized = abs(current - prev)/normalizer(current)
        if normalized < 5e-4    # 5e-4 is used to get below the rounding error
            break
        end
        @debug "Current Value" current
        prev = current

        if i == 10_000+start_value  # if this point is reached, the series did not converge
            println(current)
            current = nothing
        end
    end
    current
end

try
    @debug ARGS
    start_value = if length(ARGS) >= 1
        parse(Int, ARGS[1])
    else 3 end

    @assert start_value >= 3
    println("konvergent value $(iterate(start_value))")
catch e
    e isa InterruptException && exit(138)
    rethrow(e)
end
