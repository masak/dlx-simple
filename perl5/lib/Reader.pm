package Reader;
use Moose;

sub matrix_for_c {
    my ($self) = @_;

    my $s = "";
    for my $row (@{ $self->matrix }) {
        if ($s) {
            $s .= " -1\n";
        }
        $s .= join(" ", @{ $row });
    }
    $s .= " -2\n";
    return $s;
}

1;
