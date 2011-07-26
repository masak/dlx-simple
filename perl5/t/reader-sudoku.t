use 5.010;
use strict;
use warnings;

use Test::More;

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

done_testing;

# More things to test:
#
# - badly-formed body
# - body with values
# - body with illegal values
# - header and body inconsistent
