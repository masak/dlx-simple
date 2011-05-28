package Data::Object;
use Moose::Role;
use MooseX::Params::Validate;

has 'L' => (is => 'rw', isa => 'Data::Object', builder => '_point_to_self');
has 'R' => (is => 'rw', isa => 'Data::Object', builder => '_point_to_self');
has 'U' => (is => 'rw', isa => 'Data::Object', builder => '_point_to_self');
has 'D' => (is => 'rw', isa => 'Data::Object', builder => '_point_to_self');

sub _point_to_self {
    my ($self) = @_;

    return $self;
}

sub attach_below {
    my $self = shift;
    my ($other) = pos_validated_list(
        \@_,
        { isa => 'Data::Object' },
    );

    $other->D->U($self);
    $self->D($other->D);
    $self->U($other);
    $other->D($self);
    return;
}

sub attach_to_right_of {
    my $self = shift;
    my ($other) = pos_validated_list(
        \@_,
        { isa => 'Data::Object' },
    );

    $other->R->L($self);
    $self->R($other->R);
    $self->L($other);
    $other->R($self);
    return;
}

sub attach_to_left_of {
    my $self = shift;
    my ($other) = pos_validated_list(
        \@_,
        { isa => 'Data::Object' },
    );

    $other->attach_to_right_of($self);
}

1;
