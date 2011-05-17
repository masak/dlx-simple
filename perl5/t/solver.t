use 5.010;
use Test::More;

use Solver::DancingLinks;
use Writer::Code;

sub test_solve {
    my ($matrix, $expected_output, $description) = @_;

    my @output;
    my $writer = Writer::Code->new(code => sub { push @output, shift });
    my $solver = Solver::DancingLinks->new(
        matrix => $matrix,
        writer => $writer,
    );

    $solver->solve();

    is_deeply \@output, $expected_output, $description;
}

test_solve [], [], 'empty matrix gives no solutions';
test_solve [[0], [1], [2]], [[0, 1, 2]], 'identity matrix gives all lines';

done_testing;
