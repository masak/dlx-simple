package Solver::DancingLinks;
use Moose;

use Writer::Rowset;

has 'matrix' => (is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]', required => 1);
has 'writer' => (is => 'ro', isa => 'Writer',
                 default => sub { Writer::Rowset->new() });

sub solve {
    my ($self) = @_;
    my $matrix = $self->matrix;
    my $writer = $self->writer;

    if (@$matrix) {
        $writer->write([ 0 .. scalar(@$matrix) - 1 ]);
    }
}

1;
