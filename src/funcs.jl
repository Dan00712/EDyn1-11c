module funcs

using Base.Threads

using ProgressBars

public calculatesum_primitive, calculatesum_evjen , normalizer, iterate

const ATOL = 1e-4   # is used to get below the rounding error

function iterate(start_value=5; func=calculatesum_primitive, atol=ATOL)
    """
    increment the number of atoms in each dimension by one until the algorithm has converged to three significant digits
    func may be used to specify the used approach
    currently used algorithms are calculatesum_primitive and calculatesum_evjen

    In order to check for convergence it compares the value from the previous iteration
    and checks if the (normalized, i.e using aE+b => a) distance is smaller than atol (default $(ATOL)).
    The distance is chosen in order to account for the rounding inexcatness of the next decimal
    """
    current = 0
    prev = func(start_value-1)

    # use a step of 2 for an equal number of points on each side, 
    # the Δ is artificially boosted by alternating between balanced and unbalanced sides
    for i in start_value:2:10_000+start_value
        current, dt = let
            t0 = time()
            tmp = func(i)
            tmp, time() - t0
        end
        @debug "Iteration and Δ|scaled between iterations" i current - prev (current-prev)/normalizer(current)
        @debug "iteration took" dt

        normalized = abs(current - prev)/normalizer(current)
        if normalized < atol    
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

function calculatesum(n, scalingfunc=scaling_id)
    """
    Calculates the total Potential Energy, 
        relative to two adjacent Atoms.
    This algorithm is parallelize using the built in threading Library of julia.
    For the multithreading to be efficient the --threads or -t parameter needs to be set.
    To allow for maximum speedup the parameter should be \$(nprocs).

    This function is general and allows for a scaling function to be applied, to switch between approaches.
    With scaling_id this takes the primitive approach of summing all the potentials
    With scaling_evjen this takes the form of the evjen method that converges faster
    """
    sum = Atomic{Float64}(0.0)  # Atomic variable to allow concurrent modification
    ub =  ceil((n-1)/2)         # upper bound for iteration
    lb = -floor((n-1)/2)        # lower bound for iteration

    @threads for x in ProgressBar(lb:ub)
        local sub_sum = 0
        for y in lb:ub, z in lb:ub
            if x == 0 && y == 0 && z == 0
                continue
            end
            sub_sum += scalingfunc(x,y,z; ub=ub, lb=lb)  *charge(x,y,z)/distance(x,y,z)
        end
        atomic_add!(sum, sub_sum)
    end
    sum[]
end

function scaling_id(args...; kwargs...)
    """
    The scaling function for the primitive approach is 1 regardless of parameters
    """
    1
end

function calculatesum_primitive(n)
    """
    Calculates the total Potential Energy, 
        relative to two adjacent Atoms.
    This algorithm is parallelize using the built in threading Library of julia.
    For the multithreading to be efficient the --threads or -t parameter needs to be set.
    To allow for maximum speedup the parameter should be \$(nprocs).
    
    This approach is taking the rather primitive approach of summing all the potentials with the charge at 0^m.
    With this primitive approach the Algorithm runs in O(n^3) time, but should run in O(1) space.
    There are more elegant and more importantly faster converging methods
    such as the 'Ewald-Method' or the 'Evjen-Method'.
    """
    calculatesum(n, scaling_id)
end

function scaling_evjen(x,y,z; ub, lb)
    """
    The scaling function for the evjen method is a factor of 1/2 for every indices that reached it's extremal value
    """
    2.0^(-((([x, y, z] .== ub) .|| ([x,y,z] .== lb)) |> sum))
end
function calculatesum_evjen(n)
    """
    Calculates the total Potential Energy, 
        relative to two adjacent Atoms.
    This algorithm is parallelize using the built in threading Library of julia.
    For the multithreading to be efficient the --threads or -t parameter needs to be set.
    To allow for maximum speedup the parameter should be \$(nprocs).
   
    This approach scales the charge of the atoms on the edge by 1/2 for every indices that hits it's extremal value
    The Algorithm still runs in O(n^3) time and O(1) space, but converges much faster than the primitive approach
    """
    calculatesum(n, scaling_evjen)
end

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

function normalizer(val) 
    """ 
     get normalizing factor, this is needed to get access to the significant digits
     When writing a number as aE+b, the 1E+b part is calculated,
        and aE+b is thusly divided by 1E+b, to get the normalized a
     """
    10^floor(log(10, val))             
end

end
