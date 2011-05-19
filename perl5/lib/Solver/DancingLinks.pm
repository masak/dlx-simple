package Solver::DancingLinks;
use Moose;

use Writer::Rowset;

has 'matrix' => (is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]', required => 1);
has 'writer' => (is => 'ro', isa => 'Writer',
                 default => sub { Writer::Rowset->new() });

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

    return 1 + max(map { max @{$_} } @{$matrix});
}

sub search {
    my ($matrix, $writer, $column, $rows_ref, $covered_columns_ref,
        $width) = @_;
    $column              //= 0;
    $rows_ref            //= [];
    $covered_columns_ref //= [];
    $width               //= width($matrix);

    if ($column >= $width) {
        $writer->write([@{$rows_ref}]);
        return;
    }

    if (grep { $_ == $column } @{$covered_columns_ref}) {
        search($matrix, $writer, $column + 1, $rows_ref,
               $covered_columns_ref, $width);
        return;
    }

    my $height = scalar @{$matrix};
    for my $row (0..$height-1) {
        next unless grep { $_ == $column } @{$matrix->[$row]};

        push @{$rows_ref}, $row;
        push @{$covered_columns_ref}, @{$matrix->[$row]};
        my @deleted_rows;
        for my $covered_column (@{$matrix->[$row]}) {
            for my $i (0..$height-1) {
                next unless grep { $_ == $covered_column } @{$matrix->[$i]};
                $deleted_rows[$i] = $matrix->[$i];
                $matrix->[$i] = [];
            }
        }
        search($matrix, $writer, $column + 1, $rows_ref,
               $covered_columns_ref, $width);
        for my $i (0..@deleted_rows-1) {
            next unless defined $deleted_rows[$i];
            $matrix->[$i] = $deleted_rows[$i];
        }
        pop @{$covered_columns_ref} for @{$matrix->[$row]};
        pop @{$rows_ref};
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
