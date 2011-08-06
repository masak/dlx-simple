package Writer;
use Moose;

sub write {
    my ($self) = @_;

    die "Class ", ref($self), " doesn't override abstract method 'write'.";
}

1;
