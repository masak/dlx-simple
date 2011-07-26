package Reader::Sudoku;
use Moose;

has 'header' => (
    is       => 'ro',
    isa      => 'HashRef[Str]',
    required => 1,
);

has 'body' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'size' => (
    is       => 'rw',
    isa      => 'Int',
    init_arg => undef,
);

has 'matrix' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_matrix',
);

sub BUILD {
    my $self = shift;

    my $size_from_body;
    if ($self->body) {
        my $nonempty_rows = 0;
        for (split("\n", $self->body)) {
            unless ($_ eq "") {
                $nonempty_rows++;
            }
        }
        $size_from_body = $nonempty_rows;
    }

    my $size_from_header = $self->header->{size};

    die "header says $size_from_header but body says $size_from_body"
        if defined $size_from_body && defined $size_from_header
           && $size_from_header != $size_from_body;

    my $size = defined $size_from_header ? $size_from_header
             : defined $size_from_body   ? $size_from_body
             : 9;

    die "$size is not a square"
        unless sqrt($size) == int(sqrt($size));

    $self->size($size);
}

sub _build_matrix {
    my $self = shift;

    my $SIZE = $self->size;
    my $NUMBERS = $SIZE;

    my ($NS0, $NS1, $NS2, $NS3) = map { $NUMBERS + $SIZE * $_ } 0..3;
    my @rows;
    my $sqrt_size = sqrt $SIZE;
    for my $r (1..$SIZE) {
        my $coarse_row = int(($r - 1) / $sqrt_size);
        for my $c (1..$SIZE) {
            my $coarse_column = int(($c - 1) / $sqrt_size);
            my $m = $coarse_row * $sqrt_size + $coarse_column + 1;

            for my $n (1..$NUMBERS) {
                my @row = (0) x $NS3;
                $row[       $n - 1] = 1;
                $row[$NS0 + $r - 1] = 1;
                $row[$NS1 + $c - 1] = 1;
                $row[$NS2 + $m - 1] = 1;
                push @rows, \@row;
            }
        }
    }
    return \@rows;
}

1;
