## Calculating the Distance

The distance, from the origin to the point r^i,
     is given by the numbers r1 = d*x; r2 =  d*y; r3 d*z.
This leads the norm to be r = d * sqrt(x^2 + y^2 + z^2) =: d* dist(x^m)

## Calculating the Charge

Overy step (i.e. increment by one of x, y or z) the sign changes,
    so it is entirely dependant on the parity, of the sum of x,y,z.
If the modulus of the value is 0, 
    the charge value should be 1 but because of the negative sign in the reference energy
    -1 is used,
logically for a value of 1 the function should return 1,
    to produce a negative value.
like:
charge_sign(x,y,z) = if (x+y+z)%2 == 0 -1 else 1 end

## Cummulation to the Potential

for one point charge, between the charges e and e*charge_sign(x^m), the formula for the potential Energy is
V = q * Phi = charge_sign(x^m) * e^2/(4Pi*epsilon_0) * 1/|r^m|

The Total charge is by superposition principle

V_t = -\sum_{x^m\neq0} charge\_sign(x^m)*e^2/(4Pi*\epsilon_0) * 1/|r^m|
    = -e^2 /4Pi*\epsilon_0*d) * \sum_{x^m\neq 0} charge\_sign(x^m)/dist(x^m)
    = E_{2\times1\times1}  * \sum_{x^m\neq 0} charge\_sign(x^m)/dist(x^m)

