use 5.010;
use Test::More;

use Solver::DancingLinks;
use Writer::Code;

sub output_eqv {
    my ($actual, $expected, $description) = @_;

    if (@{$actual} != @{$expected}) {
        is @{$actual}, @{$expected}, $description;
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

test_solve [], [], 'empty matrix gives no solutions';

test_solve [[0], [1], [2]], [[0, 1, 2]], 'identity matrix gives all lines';

test_solve [[0], [0], [1], [1]],
           [[0, 2], [0, 3], [1, 2], [1, 3]],
           '2 x 2 candidates gives 4 solutions';

test_solve [[0], [1], [0], [1]],
           [[0, 1], [0, 3], [1, 2], [2, 3]],
           'same rows in different order';

done_testing;
