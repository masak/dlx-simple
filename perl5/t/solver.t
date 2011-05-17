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

done_testing;
