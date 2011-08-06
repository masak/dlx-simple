use 5.010;

use Writer::Sudoku;

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

    my $size_from_body;
    if ($self->body) {
        my $nonempty_rows = 0;
        for (split("\n", $self->body)) {
            next unless $_;
            $nonempty_rows++;
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

    if ($self->body) {
        sub align {
            my ($s1, $s2) = @_;
            $s1 = $s1 . " " x (length($s2)-length($s1));
            $s2 = $s2 . " " x (length($s1)-length($s2));
            for (0..length($s1)-1) {
                return ''
                    if  substr($s1, $_, 1) eq " "
                    xor substr($s2, $_, 1) eq " ";
            }
            return 1;
        }

        my $ssqrt = sqrt $size;
        my $first_line = (split /\n/, $self->body)[0];
        my $l = 0;
        my $after_empty_line = 1;
        for my $line (split /\n/, $self->body) {
            unless ($line) {
                $after_empty_line = 1;
                next;
            }
            die "Expected empty row; found content"
                if $l % $ssqrt == 0 && !$after_empty_line;
            $after_empty_line = '';
            $l++;
            die "Row out of alignment: $line"
                unless align($first_line, $line);
            my $c = 1;
            for (split //, $line) {
                die "Value out of range: $_ > $size"
                    if /\d/ && $_ > $size;
            }
            while ($line) {
                $line =~ s/^ \s* (\S+) //x;
                my $blockwidth = length($1);
                die "Block is $blockwidth chars wide; expected $ssqrt: $1"
                    unless $blockwidth == $ssqrt;
                $line =~ s/^ \s+ //x;
            }
        }
    }
}

sub _build_matrix {
    my $self = shift;

    my $SIZE = $self->size;
    my $NUMBERS = $SIZE;

    my $sqrt_size = sqrt $SIZE;

    # Placing a value $v in row $r, column $c, minibox $m
    # means the following:
    #
    # * This location is taken (rows x columns)
    # * This number in this row is taken (numbers x rows)
    # * This number in this column is taken (numbers x columns)
    # * This number in this minibox is taken (numbers x miniboxes)
    my $NS1 =           $SIZE * $SIZE;
    my $NS2 = $NS1 + $NUMBERS * $SIZE;
    my $NS3 = $NS2 + $NUMBERS * $SIZE;
    my $NS4 = $NS3 + $NUMBERS * $SIZE;

    my @rows;
    my @mapping;
    for my $r (0..$SIZE-1) {
        my $coarse_row = int($r / $sqrt_size);
        for my $c (0..$SIZE-1) {
            my $coarse_column = int($c / $sqrt_size);
            my $m = $coarse_row * $sqrt_size + $coarse_column;

            for my $n (0..$NUMBERS-1) {
                push @rows, [
                           $r * $SIZE    + $c,
                    $NS1 + $r * $NUMBERS + $n,
                    $NS2 + $c * $NUMBERS + $n,
                    $NS3 + $m * $NUMBERS + $n,
                ];
                push @mapping, { r => $r, c => $c, n => $n + 1 };
            }
        }
    }

    my @priors        = $self->_build_priors;
    my @writer_priors = @mapping[ @priors ];

    my %skip_columns;
    for my $row (@priors) {
        for my $column (@{$rows[$row]}) {
            if (exists $skip_columns{$column}) {
                # XXX: Should have much better diagnostics here.
                #      Can get out all the information needed by
                #      analyzing the rows involved and back-translating.
                die "Impossible hints";
            }
            $skip_columns{$column} = $row; # that's why we save $row here
        }
    }
    for my $column (keys %skip_columns) {
        propagate_constraint(\@rows, \@mapping, $column);
    }

    @rows = compact(@rows);
    $self->writer(Writer::Sudoku->new(
        size    => $SIZE,
        mapping => \@mapping,
        priors  => \@writer_priors,
    ));
    return \@rows;
}

sub propagate_constraint {
    my ($matrix, $mapping, $c) = @_;

    my @rows_with_c;
    for my $row (0..@{$matrix}-1) {
        if (grep { $c == $_ } @{$matrix->[$row]}) {
            push @rows_with_c, $row;
        }
    }

    for my $row (reverse @rows_with_c) {
        splice @{$matrix},  $row, 1;
        splice @{$mapping}, $row, 1;
    }

    return;
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

sub _build_writer {
    my $self = shift;
    $self->_build_matrix;
    return $self->writer;
}

sub _build_priors {
    my $self = shift;

    my $SIZE = $self->size;
    my $NUMBERS = $SIZE;
    my @priors;
    my $row = 0;
    for my $line (split /\n/, $self->body()) {
        next unless $line;
        $line =~ s/\s+//g;
        my $column = 0;
        for my $char (split //, $line) {
            if ($char ne '.') {
                die "XXX" if $char !~ /\d/;
                my $value = $char - 1;
                my $prior = $row * $NUMBERS * $SIZE + $column * $NUMBERS + $value;
                push @priors, $prior;
            }
            $column++;
        }
        $row++;
    }
    return @priors;
}

1;
