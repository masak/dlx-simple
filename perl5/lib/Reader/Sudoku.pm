package Reader::Sudoku;
use Moose;

has 'matrix' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_matrix',
);

sub _build_matrix {
    return [];
}

1;
