package Data::Header;
use Moose;

with 'Data::Object';

has 'S' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

sub increase_S {
    my ($self) = @_;

    $self->S( $self->S + 1 );
    return;
}

sub decrease_S {
    my ($self) = @_;

    $self->S( $self->S - 1 );
    return;
}

__PACKAGE__->meta->make_immutable;
1;
