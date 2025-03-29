module funcs

using Base.Threads

using ProgressBars

public calculatesum, normalizer

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

function calculatesum(n)
    """
    Calculates the total Potential Energy, 
        relative to two adjacent Atoms
    This algorithm is parallelize using the built in threading Library of julia
    For the multithreading to be efficient the --threads or -t parameter needs to be set
    To allow for maximum speedup the parameter should be \$(nprocs).
    """
    sum = Atomic{Float64}(0.0)  # Atomic variable to allow concurrent modification
    ub =  ceil((n-1)/2)
    lb = -floor((n-1)/2)

    #@debug "lower and upper iteration bounds" lb ub

    @threads for x in ProgressBar(lb:ub)
        local sub_sum = 0
        for y in lb:ub, z in lb:ub
            if x == 0 && y == 0 && z == 0
                continue
            end
            #=@debug ("current position in cristal, charge at this position,"*
               " distance at this point and the current sum",
               x, y, z, charge(x,y,z), distance(x,y,z), sum) =#
            sub_sum += charge(x,y,z)/distance(x,y,z)
        end
        atomic_add!(sum, sub_sum)
    end
    sum[]
end

function normalizer(val) 
    """ 
     get normalizing factor, this is needed to get access to the significant digits
     When writing a number as aE+b, the 1E+b part is calculated,
        and aE+b is thusly divided by 1E+b, to get the normalized a
     """
    10^floor(log(10, val))             
end
end
