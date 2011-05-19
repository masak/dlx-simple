package Solver::DancingLinks;
use Moose;

use Writer::Rowset;

has 'matrix' => (is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]', required => 1);
has 'writer' => (is => 'ro', isa => 'Writer',
                 default => sub { Writer::Rowset->new() });

sub max {
    my $max = shift(@_) // die "&max needs at least one value";
    for (@_) {
        if ($max < $_) {
            $max = $_;
        }
    }
    return $max;
}

sub width {
    my ($matrix) = @_;

    return 1 + max(map { max @{$_} } @{$matrix});
}

sub search {
    my ($matrix, $writer, $column, $rows_ref, $covered_columns_ref) = @_;
    $column              //= 0;
    $rows_ref            //= [];
    $covered_columns_ref //= [];

    my $width = width($matrix);
    if ($column >= $width) {
        $writer->write([@{$rows_ref}]);
        return;
    }

    if (grep { $_ == $column } @{$covered_columns_ref}) {
        search($matrix, $writer, $column + 1, $rows_ref,
               $covered_columns_ref);
        return;
    }

    my $height = scalar @{$matrix};
    for my $row (0..$height-1) {
        if (grep { $_ == $column } @{$matrix->[$row]}) {
            push @{$rows_ref}, $row;
            push @{$covered_columns_ref}, @{$matrix->[$row]};
            search($matrix, $writer, $column + 1, $rows_ref,
                   $covered_columns_ref);
            pop @{$covered_columns_ref} for @{$matrix->[$row]};
            pop @{$rows_ref};
        }
    }
}

sub solve {
    my ($self) = @_;
    my $matrix = $self->matrix;
    return unless @{$matrix};

    my $writer = $self->writer;
    search($matrix, $writer);
}

1;
