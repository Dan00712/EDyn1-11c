using LinearAlgebra
using Base.Threads

using Logging
Logging.global_logger(ConsoleLogger(Logging.Debug))


function distance(x,y,z)
    """
    Calculate the distance between the point (x,y,z) to 0^m
    The Common factor of d is not included, 
        since it is already accountet for in the relative factor of E_2×1×1
    """
    sqrt(x^2 + y^2 + z^2)
end

function charge(x,y,z)
    """
    Calculate the sign of the charge at a point(x, y, z), relative to the sign at 0^m
    Since the sign changes every move and the sign at (0, 0, 0)^T is 1, 
        the sign of (1, 0 ,0)^T, (0, 1, 0)^T and (0, 0, 1)^T is -1
    This culminates in the formula of (x%2 + y%2 + z%2)%2 = (x+y+z)%2, which is used here
    """
    if (x+y+z)%2 == 0
        -1
    else
        1
    end
end

function calculate_sum(n)
    sum = Atomic{Float64}(0.0)  # Atomic variable to allow concurrent modification
    ub =  ceil((n-1)/2)
    lb = -floor((n-1)/2)

    #@debug "lower and upper iteration bounds" lb ub

    @threads for x in lb:ub
        sub_sum = 0
        for y in lb:ub
            for z in lb:ub
                if x == 0 && y == 0 && z == 0
                    continue
                end
                #=@debug ("current position in cristal, charge at this position,"*
                   " distance at this point and the current sum",
                   x, y, z, charge(x,y,z), distance(x,y,z), sum) =#
                sub_sum += charge(x,y,z)/distance(x,y,z)
            end
        end
        atomic_add!(sum, sub_sum)
    end
    sum[]
end

function iterate(start_value=3)
    current = 0
    prev = 0
    for i in start_value:10_000+start_value
        current, dt = let
            t0 = time()
            tmp = calculate_sum(i)
            tmp, time() - t0
        end
        @debug "Iteration and Δ between iterations" i current - prev
        @debug "iteration took" dt
        if abs(current - prev) < 1e-4
            break
        end
        @debug "Current Value" current
        prev = current
    end
    current
end

try
    @debug ARGS
    start_value = if length(ARGS) >= 1
        parse(Int, ARGS[1])
    else 3 end

    @assert start_value >= 3
    println(iterate(start_value))
catch e
    e isa InterruptException && exit(138)
    rethrow(e)
end
