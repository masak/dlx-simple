package Reader::Sudoku;
use Moose;

has 'body' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'matrix' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_matrix',
);

sub _build_matrix {
    my $self = shift;

    my $SIZE = 9;
    if ($self->body) {
        $SIZE = 4;
    }
    my $NUMBERS = $SIZE;

    my ($NS0, $NS1, $NS2, $NS3) = map { $NUMBERS + $SIZE * $_ } 0..3;
    my @rows;
    my $sqrt_size = sqrt $SIZE;
    for my $r (1..$SIZE) {
        my $coarse_row = int(($r - 1) / $sqrt_size);
        for my $c (1..$SIZE) {
            my $coarse_column = int(($c - 1) / $sqrt_size);
            my $m = $coarse_row * $sqrt_size + $coarse_column + 1;

            for my $n (1..$NUMBERS) {
                my @row = (0) x $NS3;
                $row[       $n - 1] = 1;
                $row[$NS0 + $r - 1] = 1;
                $row[$NS1 + $c - 1] = 1;
                $row[$NS2 + $m - 1] = 1;
                push @rows, \@row;
            }
        }
    }
    return \@rows;
}

1;
