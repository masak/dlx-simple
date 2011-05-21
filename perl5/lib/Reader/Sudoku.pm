package Reader::Sudoku;
use Moose;

has 'matrix' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_matrix',
);

sub _build_matrix {
    my $size = 4;
    my @rows;
    for my $r (1..$size) {
        for my $c (1..$size) {
            for my $n (1..$size) {
                push @rows, undef;
            }
        }
    }
    return \@rows;
}

1;
