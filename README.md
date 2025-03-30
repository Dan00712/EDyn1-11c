# Calculations
## Calculating the Distance

The distance, from the origin to the point r^i,
     is given by the numbers $r_1 = d*x$; $r_2 =  d*y$; $r_3 = d*z$.
This leads the norm to be $r = d \cdot sqrt(x^2 + y^2 + z^2)$ =: d \cdot dist(x^m)

## Calculating the Charge

At each step (i.e. increment by one of x, y or z) the sign of the charge changes,
    so it is entirely dependant on the parity of the sum of x, y, z.
If the modulus of the value is 0, 
    the charge value should be 1 but because of the negative sign in the reference energy
    -1 is used,
logically for a value of 1 the function should return 1,
    to produce a negative value.
like:
`charge_sign(x,y,z) = if (x+y+z)%2 == 0 -1 else 1 end`

## Summation of the Potential (primitive approach)

for one point charge, between the charges e and e*charge_sign(x^m), the formula for the potential Energy is
$V = q * Phi = charge_sign(x^m) * e^2/(4\pi*\epsilon_0) * 1/|r^m|$

The Total charge is then given by superposition principle

$$ V_t = -\sum_{x^m\neq 0} \text{charge\_sign}(x^m)*e^2/(4\pi*\epsilon_0) * 1/|r^m|
    = -e^2 /(4\pi*\epsilon_0*d) * \sum_{x^m\neq 0} \text{charge\_sign}(x^m)/\text{dist}(x^m)
    = E_{2\times 1\times 1}  * \sum_{x^m\neq 0} \text{charge\_sign}(x^m)/\text{dist}(x^m) $$

If the primitive approach is used, with an even number, 
    its calculation is over an unbalanced crystal (there is one extra atom on the positive side),
    and emulates a slightly wrong version of the Evjen method.

## Evjen Approach
In the Evjen method each indices that is on the edge of the cube adds a multiple of 1/2 to the charge.
For a more detailed explanation as to how and why this works, I would refer to the publication at [On the Stability of Certain Heteropolar Crystals.](https://catalogplus.tuwien.at/permalink/f/8agg25/TN_cdi_crossref_primary_10_1103_PhysRev_39_675)
The Evjen method is used because it converges much quicker that the primitive approach.


# Usage

To use the implementations it is required that the [julia programming language](https://julialang.org/) is installed,
These Computations were done using version `1.11.4`.

Scripts for the usage are in the scripts folder,
    please make sure that your current working directory is the root of the project when executing them.
Both approaches support an iterative and positional method.
- the iterative approach iterates through all the n values until a convergence has been reached 
    (i.e. the normalised change between n and n-1 is smaller than the ATOL). 
    All arguments are passed to the spawned julia instance.
- the positional approach takes an n as an Argument and compares the value with n-1,
    it succeeds if the normalised difference is smaller than the allowed ATOL.
    All but the last argument are passed to the spawned julia instance.

Please note that for the primitive approach it is suggested that one should use multiple threads 
    (specifiable by the -t or --threads flag).

Example usages:
```sh
./scripts/iterated_approach_evjen
./scripts/iterated_approach --threads=$(nproc) # not recommended since this method takes a long time to converge
./scripts/positional_approach -t $(nproc) 2001
```

The scripts can also be executed manually using the `julia` command line interface, 
    the same scripts would be (before running the scripts manually, ensure that the julia environment is properly instantiated by running `julia --project=. --eval 'using Pkg; Pkg.instantiate()'`):
```sh
julia --project=. src/main.evjen.jl
julia --threads=$(nproc) --project=. src/main.jl
julia -t $(nproc) --project=. src/main.2.jl 2001
```
