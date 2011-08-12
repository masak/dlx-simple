use 5.010;

use Writer::Pentominoes;

package Reader::Pentominoes;
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
    init_arg => undef,
);

has 'writer' => (
    is       => 'rw',
    lazy     => 1,
    builder  => '_build_writer',
    init_arg => undef,
);

sub BUILD {
    my $self = shift;

    $self->size(8);
}

my %pieces = (
    'F' => <<"EOP",
.XX
XX.
.X.
EOP

    'I' => <<"EOP",
X
X
X
X
X
EOP

    'L' => <<"EOP",
X.
X.
X.
XX
EOP

    'P' => <<"EOP",
XX
XX
X.
EOP

    'N' => <<"EOP",
X..
XXX
..X
EOP

    'T' => <<"EOP",
XXX
.X.
.X.
EOP

    'U' => <<"EOP",
X.X
XXX
EOP

    'V' => <<"EOP",
X..
X..
XXX
EOP

    'W' => <<"EOP",
X..
XX.
.XX
EOP

    'X' => <<"EOP",
.X.
XXX
.X.
EOP

    'Y' => <<"EOP",
.X
XX
.X
.X
EOP

    'Z' => <<"EOP",
..XX
XXX.
EOP
);

sub fits {
    my ($piece, $sr, $sc, $size) = @_;
    my @rows = split /\n/, $piece;
    my $width = length($rows[0]);
    return if $sr + @rows - 1 > $size - 1;
    return if $sc + $width - 1 > $size - 1;
    for my $r (0..@rows-1) {
        my $row = $rows[$r];
        for my $c (0..$width-1) {
            if (substr($row, $c, 1) eq "X") {
                return if (3 == $sr + $r || 4 == $sr + $r)
                       && (3 == $sc + $c || 4 == $sc + $c);
            }
        }
    }
    return 1;
}

sub positions {
    my ($piece, $sr, $sc, $size) = @_;
    my @rows = split /\n/, $piece;
    my $width = length($rows[0]);
    my @positions;
    for my $r (0..@rows-1) {
        my $row = $rows[$r];
        for my $c (0..$width-1) {
            if (substr($row, $c, 1) eq "X") {
                push @positions, keys(%pieces)
                                 + ($sr + $r) * $size
                                 + $sc + $c;
            }
        }
    }
    return @positions;
}

sub rows_cols {
    my ($piece, $sr, $sc) = @_;
    my @rows = split /\n/, $piece;
    my $width = length($rows[0]);
    my %rows_cols;
    my $i = 1;
    for my $r (0..@rows-1) {
        my $row = $rows[$r];
        for my $c (0..$width-1) {
            if (substr($row, $c, 1) eq "X") {
                $rows_cols{"r$i"} = $sr + $r;
                $rows_cols{"c$i"} = $sc + $c;
                $i++;
            }
        }
    }
    return %rows_cols;
}

sub rotate {
    my ($piece, $rotations) = @_;
    for (1..$rotations) {
        my @rows = split /\n/, $piece;
        my $width = length($rows[0]);
        my @new_piece;
        for my $c (reverse 0..$width-1) {
            push @new_piece, join "", map { substr($_, $c, 1) } @rows;
        }
        $piece = join "\n", @new_piece;
    }
    return $piece;
}

sub flip {
    my ($piece) = @_;
    return join "\n", reverse split /\n/, $piece;
}

sub variants {
    my ($piece) = @_;

    my @rotations = map { rotate($piece, $_) } 0..3;
    my %uniq = map { $_ => 1, flip($_) => 1 } @rotations;

    return keys %uniq;
}

sub _build_matrix {
    my $self = shift;

    my $SIZE = $self->size;

    my @rows;
    my @mapping;
    my $pieceindex = 0;
    for my $name (sort keys %pieces) {
        my $piece = $pieces{$name};
        chomp $piece;
        for my $variant (variants($piece)) {
            for my $r (0..$SIZE-1) {
                for my $c (0..$SIZE-1) {
                    if (fits($variant, $r, $c, $SIZE)) {
                        push @rows, [$pieceindex,
                                     positions($variant, $r, $c, $SIZE)];
                        my %rows_cols = rows_cols($variant, $r, $c);
                        push @mapping, {
                            p => $name,
                            %rows_cols,
                        };
                    }
                }
            }
        }
        $pieceindex++;
    }

    @rows = compact(@rows);
    $self->writer(Writer::Pentominoes->new(
        size    => $SIZE,
        mapping => \@mapping,
        priors  => [],
    ));
    return \@rows;
}

sub _build_writer {
    my $self = shift;
    $self->_build_matrix;
    return $self->writer;
}

sub compact {
    my (@rows) = @_;

    my %remaining_columns;
    for (@rows) {
        @remaining_columns{ @{$_} } = (1) x @{$_};
    }
    my %numbering;
    my $i;
    for (sort { $a <=> $b } keys %remaining_columns) {
        $numbering{$_} = $i++;
    }

    my @renumbered_rows;
    for (@rows) {
        push @renumbered_rows, [map { $numbering{$_} } @{$_}];
    }
    return @renumbered_rows;
}

1;
