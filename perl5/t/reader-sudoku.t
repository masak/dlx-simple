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

sub first_1 {
    for my $index (0..@_-1) {
        return $index if $_[$index] == 1;
    }
    die "Expected to find a 1 but didn't";
}

sub is_sudoku_matrix {
    my ($matrix, $SIZE) = @_;

    is ref($matrix), 'ARRAY', '$reader->matrix returns an arrayref';
    return unless ref($matrix) eq 'ARRAY';

    my $NUMBERS = $SIZE;
    is scalar(@{$matrix}),
       # all possible placements of all numbers in the grid
       (my $HEIGHT = $NUMBERS * $SIZE * $SIZE),
       'matrix has the right number of rows';

    my $NS0 = $NUMBERS;
    my $NS1 = $NUMBERS + $SIZE;
    my $NS2 = $NUMBERS + $SIZE * 2;
    my $NS3 = $NUMBERS + $SIZE * 3;

    my @tile_indices     =    0 .. $NS0 - 1;
    my @row_indices      = $NS0 .. $NS1 - 1;
    my @column_indices   = $NS1 .. $NS2 - 1;
    my @minibox_indices  = $NS2 .. $NS3 - 1;

    my $accepted = 1; # until proven faulty
    my %seen;
    for my $matrix_row (@{$matrix}) {
        next unless ref($matrix_row) eq 'ARRAY';
        my @matrix_row = @{$matrix_row};
        next unless scalar(@matrix_row) == $NS3;

        my $tile    = first_1(@matrix_row[@tile_indices]);
        my $row     = first_1(@matrix_row[@row_indices]);
        my $column  = first_1(@matrix_row[@column_indices]);
        my $minibox = first_1(@matrix_row[@minibox_indices]);

        my $key = join ';', $tile, $row, $column;
        if (exists $seen{$key}) {
            ok 0, 'all matrix rows are unique';
            $accepted = '';
            last;
        }
        $seen{$key} = $minibox;
    }

    unless (keys(%seen) == $HEIGHT) {
        ok 0, 'matrix rows are array refs of the right length';
        $accepted = '';
    }

    last unless $accepted;

    for my $key (keys %seen) {
        my ($tile, $row, $column) = split /;/, $key;

        # Remember that $row and $column are now 0-based. This actually
        # simplifies calculations a bit.
        my $sqrt_size = sqrt $SIZE;
        my $coarse_row = int($row / $sqrt_size);
        my $coarse_column = int($column / $sqrt_size);

        # We'll do the minibox values 0-based too.
        my $expected_minibox = $coarse_row * $sqrt_size + $coarse_column;
        my $actual_minibox = $seen{$key};

        unless ($expected_minibox == $actual_minibox) {
            die "Failed on $key with expected minibox $expected_minibox and actual minibox $actual_minibox\n";
            $accepted = '';
            last;
        }
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
    is_sudoku_priors(
        $reader->matrix,
        4,
        $reader->priors,
        1, 1, 1,
        1, 2, 2,
        1, 3, 4,
        2, 4, 1,
        3, 1, 2,
        3, 3, 3,
        3, 4, 4,
        4, 2, 3,
        4, 3, 1,
    );
}

done_testing;

# More things to test:
#
# - body with illegal values
