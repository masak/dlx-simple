use v6;
use Test;

use Solver::DancingLinks;
use Writer::Code;

sub output_eqv(@actual, @expected, $description) {
    if @actual != @expected {
        is @actual.elems, @expected.elems,
           $description ~ ' - wrong number of solutions';
        return;
    }

    my (%actual, %expected);
    for @actual -> @row {
        my $canonical = @row.sort(+*).join(',');
        %actual{$canonical}++;
    }
    for @expected -> @row {
        my $canonical = @row.sort(+*).join(',');
        %expected{$canonical}++;
    }

    is_deeply [%actual.keys.sort],
              [%expected.keys.sort],
              $description;
}

sub test_solve($matrix, @expected_output, $description) {
    my @output;
    my $writer = Writer::Code.new(
        code => sub { push @output, $^solution }
    );
    my $solver = Solver::DancingLinks.new(
        matrix => @($matrix),
        writer => $writer,
    );

    $solver.solve();

    output_eqv @output, @expected_output, $description;
}

sub sparsify(@matrix) {
    return [] unless @matrix;

    my $width = @matrix[0].elems;
    my @sparse_matrix;
    for @matrix -> @row {
        my @sparse_row;
        for 0 .. $width - 1 -> $column {
            if @row[$column] != 0 {
                push @sparse_row, $column;
            }
        }
        push @sparse_matrix, [@sparse_row];
    }
    return @sparse_matrix;
}

test_solve [], [[]], 'empty matrix gives one solution';

{
    my $matrix = [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
    ];
    test_solve sparsify($matrix),
               [[0, 1, 2]],
               'identity matrix gives all lines';
}

{
    my $matrix = [
        [1, 0],
        [1, 0],
        [0, 1],
        [0, 1],
    ];
    test_solve sparsify($matrix),
               [[0, 2], [0, 3], [1, 2], [1, 3]],
               '2 x 2 candidates gives 4 solutions';
}

{
    my $matrix = [
        [1, 0],
        [0, 1],
        [1, 0],
        [0, 1],
    ];
    test_solve sparsify($matrix),
               [[0, 1], [0, 3], [1, 2], [2, 3]],
               'same rows in different order';
}

{
    my $matrix = [
        [1, 0, 1, 0],
        [0, 1, 0, 1],
    ];
    test_solve sparsify($matrix), [[0, 1]], 'only one solution';
}

{
    my $matrix = [
        [0, 0, 1, 0, 1, 1, 0],
        [1, 0, 0, 1, 0, 0, 1],
        [0, 1, 1, 0, 0, 1, 0],
        [1, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 0, 1],
    ];
    test_solve sparsify($matrix), [[0, 3, 4]], q[Knuth's example];
}

done;
