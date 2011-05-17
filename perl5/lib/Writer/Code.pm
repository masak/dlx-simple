package Writer::Code;
use Moose;

extends 'Writer';

has 'code' => (is => 'ro', isa => 'CodeRef', required => 1);

sub write {
    my ($self, $solution) = @_;
    my $code = $self->code;

    $code->($solution);
}

1;
