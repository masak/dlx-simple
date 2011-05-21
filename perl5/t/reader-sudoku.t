use 5.010;
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

    my $matrix = $reader->matrix;
    is ref($matrix), 'ARRAY', '$reader->matrix returns an arrayref';
}

done_testing;

# More things to test:
#
# - empty input
# - empty input with size given in header
# - badly-formed input
# - input with values
# - input with illegal values
# - header and body inconsistent
