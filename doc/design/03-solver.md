== Solver

A `Solver` accepts a (sparse) exact cover matrix, and emits sets of row
numbers from the provided matrix; each such set is an exact cover.

    my $matrix = [
        [1, 3],
        [3],
        [0, 1],
        [0, 2],
        [2],
    ];
    my $solver = Solver::DancingLinks.new(:$matrix);
    $solver.solve;
    
    # output:
    #
    # [0, 3]
    # [1, 2, 4]

The `.new` method of a `Solver` optionally accepts a `Writer`, which
will format the solutions in some way or other.

    my $solver = Solver::DancingLinks.new(:$matrix, :$writer);

(See `04-writer.md` for more on `Writer`s, and `02-reader.md` for more
on how to create them from a `Reader`.)

An optional integer argument `primaries` may be passed, which
denotes how many of the columns in the matrix are to be considered
primary columns. In the exact cover algorithm, a primary column needs
to be covered *exactly* once, whereas a secondary column only needs
to be covered *at most* once. A value `$p` for this argument will make
the first `$p` columns in the matrix primary columns, and the
remaining columns secondary columns. If no such argument is passed in,
it is assumed that all columns in the matrix are primary columns.

Another optional argument `column_choice` denotes the way the next
column to cover is to be selected in the algorithm. The choice of column
at each step can greatly affect the running time of the algorithm.
`column_choice`, if passed, needs to be of type `ColumnChoice`. The
default is `ColumnChoice::MinimizeOnes`.
