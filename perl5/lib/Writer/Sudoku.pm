use 5.010;

package Writer::Sudoku;
use Moose;
extends 'Writer';

has 'size' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

has 'priors' => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef[Int]]',
    default  => sub { [] },
);

has 'mapping' => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef[Int]]',
    required => 1,
);

sub write {
    my ($self, $solution) = @_;

    my $size = $self->size;
    my $matrix = [map { [('.') x $size] } 1..$size];
    for (@{$self->priors}, (@{$self->mapping})[@{$solution}]) {
        my $n = $_->{n};
        my $c = $_->{c};
        my $r = $_->{r};
        $matrix->[$r][$c] = $n;
    }
    for my $row (0 .. $size-1) {
        say "" if $row % sqrt($size) == 0;
        for my $col (0 .. $size-1) {
            if ($col != 0 && $col % sqrt($size) == 0) {
                print ' ';
            }
            print $matrix->[$row][$col];
        }
        print "\n";
    }
    say "";
}

1;
