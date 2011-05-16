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
