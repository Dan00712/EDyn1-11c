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

try
    @debug ARGS
    n0 = if length(ARGS) >= 1
        parse(Int, ARGS[1])
    else 4 end

    @assert n0 >= 4
    V0 = calculate_sum(n0-1)
    V1 = calculate_sum(n0)

    dV = abs(V1-V0)
    if dV < 1e-4
        println("solution is excat")
        println(V1)
        println(dV)
    else
        println("solution is to inexcat")
        println(V1)
        println(dV)
    end
catch e
    e isa InterruptException && exit(138)
    rethrow(e)
end
