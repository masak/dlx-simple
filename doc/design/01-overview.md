The purpose of dlx-simple is to make it possible to solve exact cover
problems without having to specify them in the form most fitting to the
algorithm: as a big matrix of ones and zeroes. Instead, we specify a
problem in a form that fits *us*, and rely on the program to parse and
data-munge the input into matrix form.

Similarly, at the other end, solutions will be produced in the form of
subsets of the set of rows in the input matrix, but these subsets are
only meaningful when interpreted through the symbols of the problem
specification. Therefore, the program automatically converts the set of
rows back into a form that looks very similar to the specified problem.

In summary, the data flows like this through the appliction:

                          sparse
     human-              zero-one         set of                 human-
    readable              matrix           rows                 readable
     input ====[ Encoder ]====> [ Solver ] =====[ Decoder ]====> output

In mathematical terms, this could be seen as solving the problem under a
transform:

    human    parsing   algorithm
    input ===========>   input
          [ Encoder ]
                           ||
                           ||
                       [ Solver ]
                           ||
                           ||
                           \/
    
    human    rendering  algorithm
    output <===========   output
            [ Decoder ]

The downwards arrow on the right is what the computer is good at. The
*missing* downwards arrow on the left is the function we (as humans) are
after. Happily, that is the total effect of the program.
