use 5.010;

package Writer::Pentominoes;
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
    isa      => 'ArrayRef[HashRef]',
    required => 1,
);

sub write {
    my ($self, $solution) = @_;

    my $size = $self->size;
    my $matrix = [map { [('.') x $size] } 1..$size];
    $matrix->[3][3] = $matrix->[3][4] = ' ';
    $matrix->[4][3] = $matrix->[4][4] = ' ';
    for (@{$self->priors}, (@{$self->mapping})[@{$solution}]) {
        my $p = $_->{p};
        $matrix->[$_->{r1}][$_->{c1}] = $p;
        $matrix->[$_->{r2}][$_->{c2}] = $p;
        $matrix->[$_->{r3}][$_->{c3}] = $p;
        $matrix->[$_->{r4}][$_->{c4}] = $p;
        $matrix->[$_->{r5}][$_->{c5}] = $p;
    }
    say "";
    for my $row (0 .. $size-1) {
        say join "", map { $matrix->[$row][$_] } 0 .. $size-1;
    }
}

1;
