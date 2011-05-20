package Data::Node;
use Moose;

with 'Data::Object';

has 'row' => (
    is => 'ro',
    isa => 'Int',
    required => 1,
);

has 'C' => (
    is => 'ro',
    isa => 'Data::Header',
    required => 1
);

sub BUILD {
    my ($self) = @_;

    $self->C->increase_S();
}

__PACKAGE__->meta->make_immutable;
1;
