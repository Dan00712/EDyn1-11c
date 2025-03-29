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

    # use a step of 2 for an equal number of points on each side, 
    # the Δ is artificially boosted by alternating between balanced and unbalanced sides
    for i in start_value:2:10_000+start_value
        current, dt = let
            t0 = time()
            tmp = calculatesum(i)
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
            @error "does not convergend in allowed range" current i
            current = nothing
        end
    end
    current
end


start_value = 1999
println("convergent value $(iterate(start_value))")
