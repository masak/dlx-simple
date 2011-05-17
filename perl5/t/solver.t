use 5.010;
use Test::More;

use Solver::DancingLinks;
use Writer::Code;

{
    my $matrix = [];
    my @output;
    my $writer = Writer::Code->new(code => sub { push @output, shift });
    my $solver = Solver::DancingLinks->new(
        matrix => $matrix,
        writer => $writer,
    );

    $solver->solve();

    is scalar(@output), 0, 'empty matrix gives no solutions';
}

{
    my $matrix = [ [0], [1], [2] ];
    my @output;
    my $writer = Writer::Code->new(code => sub { push @output, shift });
    my $solver = Solver::DancingLinks->new(
        matrix => $matrix,
        writer => $writer,
    );

    $solver->solve();

    is_deeply \@output, [[0, 1, 2]], 'identity matrix gives all lines';
}

done_testing;
