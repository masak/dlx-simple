use 5.010;
use Test::More;

use Solver::DancingLinks;
use Writer::Code;

sub output_eqv {
    my ($actual, $expected, $description) = @_;

    if (@{$actual} != @{$expected}) {
        is @{$actual}, @{$expected},
           $description . ' - wrong number of solutions';
        return;
    }

    my (%actual, %expected);
    for (@{$actual}) {
        my @row = @{$_};
        my $canonical = join ',', sort { $a <=> $b } @row;
        $actual{$canonical}++;
    }
    for (@{$expected}) {
        my @row = @{$_};
        my $canonical = join ',', sort { $a <=> $b } @row;
        $expected{$canonical}++;
    }

    is_deeply [sort keys %actual],
              [sort keys %expected],
              $description;
}

sub test_solve {
    my ($matrix, $expected_output, $description) = @_;

    my @output;
    my $writer = Writer::Code->new(code => sub { push @output, shift });
    my $solver = Solver::DancingLinks->new(
        matrix => $matrix,
        writer => $writer,
    );

    $solver->solve();

    output_eqv \@output, $expected_output, $description;
}

sub sparsify {
    my ($matrix) = @_;
    return [] unless @{$matrix};

    my $width = scalar @{$matrix->[0]};
    my @sparse_matrix;
    for my $row_ref (@{$matrix}) {
        my @sparse_row;
        for my $column (0 .. $width - 1) {
            if ($row_ref->[$column] != 0) {
                push @sparse_row, $column;
            }
        }
        push @sparse_matrix, \@sparse_row;
    }
    return \@sparse_matrix;
}

test_solve [], [], 'empty matrix gives no solutions';

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

done_testing;
