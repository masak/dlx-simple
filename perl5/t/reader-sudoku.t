use 5.010;
use strict;
use warnings;

use Test::More;
use Test::Exception;

use Reader::Sudoku;

sub outdent {
    my ($text) = @_;

    my @lines = split /\n/, $text;
    for (@lines) {
        s/^\x20{4}//;
    }
    return join "\n", @lines;
}

sub max {
    my $max = 0; # which is fine in our case
    for (@_) {
        if ($max < $_) {
            $max = $_;
        }
    }
    return $max;
}

sub width {
    my ($matrix) = @_;
    return 0 unless @{$matrix};
    return 1 + max(map { max @{$_} } @{$matrix});
}

sub height {
    my ($matrix) = @_;

    return scalar @{$matrix};
}

sub is_sudoku_matrix {
    my ($matrix, $SIZE) = @_;

    is ref($matrix), 'ARRAY', '$reader->matrix returns an arrayref';
    return unless ref($matrix) eq 'ARRAY';

    my $accepted = 1; # until proven faulty
    my %seen;
    for my $matrix_row (@{$matrix}) {
        next unless ref($matrix_row) eq 'ARRAY';
        my @matrix_row = @{$matrix_row};
        next unless scalar(@matrix_row) == 4;

        my ($location, $row, $column, $minibox) = @matrix_row;

        my $key = join ';', $location, $row, $column;
        if (exists $seen{$key}) {
            ok 0, 'all matrix rows are unique';
            $accepted = '';
            return;
        }
        $seen{$key}++;
    }

    ok $accepted, 'matrix contains all the right stuff';
}

sub is_sudoku_priors {
    my ($matrix, $SIZE, $priors, @values) = @_;
    my $sqrt_size = sqrt $SIZE;
    my $NUMBERS = $SIZE;
    my $NS0 = $NUMBERS;
    my $NS1 = $NUMBERS + $SIZE;
    my $NS2 = $NUMBERS + $SIZE * 2;
    my $NS3 = $NUMBERS + $SIZE * 3;

    my @matrix_rows;
    TRIPLET:
    while (@values) {
        my $row    = shift(@values) - 1;
        my $column = shift(@values) - 1;
        my $value  = shift(@values) - 1;

        my $coarse_row = int($row / $sqrt_size);
        my $coarse_column = int($column / $sqrt_size);
        my $minibox = $coarse_row * $sqrt_size + $coarse_column;

        my @lookup = (0) x $NS3;
        $lookup[       $value  ] = 1;
        $lookup[$NS0 + $row    ] = 1;
        $lookup[$NS1 + $column ] = 1;
        $lookup[$NS2 + $minibox] = 1;

        MATRIX_ROW:
        for my $matrix_row (0..@{$matrix}-1) {
            for (0..@{$matrix->[$matrix_row]}-1) {
                next MATRIX_ROW
                    if $lookup[$_] != $matrix->[$matrix_row][$_];
            }
            push @matrix_rows, $matrix_row;
            next TRIPLET;
        }
        die "Couldn't find matrix row @lookup";
    }
    is_deeply $priors, \@matrix_rows, 'priors came out ok';
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    .. ..
    .. ..
    
    .. ..
    .. ..
EOD

    my $reader = Reader::Sudoku->new(
        header => $header,
        body   => $body,
    );

    is_sudoku_matrix($reader->matrix, 4);
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
EOD

    my $reader = Reader::Sudoku->new(
        header => $header,
        body   => $body,
    );

    is_sudoku_matrix($reader->matrix, 9);
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
    .... .... .... ....
EOD

    my $reader = Reader::Sudoku->new(
        header => $header,
        body   => $body,
    );

    is_sudoku_matrix($reader->matrix, 16);
}

{
    my $header = { size => 4 };
    my $body = outdent(<<'EOD');
EOD

    my $reader = Reader::Sudoku->new(
        header => $header,
        body   => $body,
    );

    is_sudoku_matrix($reader->matrix, 4);
}

{
    my $header = { size => 5 };
    my $body = outdent(<<'EOD');
EOD

    throws_ok { Reader::Sudoku->new(
        header => $header,
        body   => $body,
    ) } qr/not a square/, 'non-square exception caught okay';
}

{
    my $header = { size => 9 };
    my $body = outdent(<<'EOD');
    .. ..
    .. ..
    
    .. ..
    .. ..
EOD

    throws_ok { Reader::Sudoku->new(
        header => $header,
        body   => $body,
    ) } qr/header says 9 but body says 4/,
        'header/body inconsistent caught okay';
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    ....
    ....
    
    ....
    ....
EOD

    throws_ok { Reader::Sudoku->new(
        header => $header,
        body   => $body,
    ) } qr/Block is 4 chars wide; expected 2/,
        'missing empty column caught okay';
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    .. ..
    .. ..
    .. ..
    .. ..
EOD

    throws_ok { Reader::Sudoku->new(
        header => $header,
        body   => $body,
    ) } qr/Expected empty row; found content/,
        'missing empty row caught okay';
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    .. ..
    .. ..

    .. ..
     .. ..
EOD

    throws_ok { Reader::Sudoku->new(
        header => $header,
        body   => $body,
    ) } qr/Row out of alignment/,
        'misaligned row caught okay';
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    12 4.
    .. .1
    
    2. 34
    .3 1.
EOD

    my $reader = Reader::Sudoku->new(
        header => $header,
        body   => $body,
    );

    is_sudoku_matrix($reader->matrix, 4);
}

{
    my $header = {};
    my $body = outdent(<<'EOD');
    .. ..
    .. 5.

    .. ..
    .. ..
EOD

    throws_ok { Reader::Sudoku->new(
        header => $header,
        body   => $body,
    ) } qr/Value out of range/,
        'value out of range caught okay';
}

done_testing;
