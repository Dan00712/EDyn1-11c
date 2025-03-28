using LinearAlgebra

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
    sum = 0
    ub =  ceil((n-1)/2)
    lb = -floor((n-1)/2)

    #@debug "" ub lb

    for x in lb:ub
        for y in lb:ub
            for z in lb:ub
                if x == 0 && y == 0 && z == 0
                    continue
                end
                #@debug "" x y z charge(x,y,z) distance(x,y,z) sum
                sum += charge(x,y,z)/distance(x,y,z)
            end
        end
    end
    sum
end

function iterate()
    current = 0
    prev = 0
    for i in 3:2_000
        current = calculate_sum(i)
        @debug "" i current - prev
        if abs(current - prev) < 1e-4
            break
        end
        @debug current
        prev = current
    end
    current
end

println(iterate())
