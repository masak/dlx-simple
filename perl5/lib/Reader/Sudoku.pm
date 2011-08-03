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

has 'priors' => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_priors',
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
    return [@priors];
}

1;
