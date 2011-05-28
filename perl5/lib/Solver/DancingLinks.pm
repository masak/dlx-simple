package Solver::DancingLinks;
use Moose;

use Writer::Rowset;
use Data::Node;
use Data::Header;

has 'matrix' => (
    is       => 'ro',
    isa      => 'ArrayRef[ArrayRef[Int]]',
    required => 1,
);

has 'writer' => (
    is      => 'ro',
    isa     => 'Writer',
    default => sub { Writer::Rowset->new() },
);

has 'linked_matrix' => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_linked_representation',
    init_arg => undef,
);

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

sub _build_linked_representation {
    my ($self) = @_;
    my $matrix = $self->matrix;
    my $width = width($matrix);
    my $height = height($matrix);

    my $root = Data::Header->new();
    my $last_seen_header = $root;
    my @last_seen_on_row;
    for my $column (0..$width-1) {
        my $list_header = Data::Header->new();
        $list_header->attach_to_right_of($last_seen_header);
        $last_seen_header = $list_header;

        my $last_seen_node = $list_header;
        for my $row (0..$height-1) {
            next unless grep { $_ == $column } @{$matrix->[$row]};

            my $data_node = Data::Node->new(row => $row, C => $list_header);
            $data_node->attach_below($last_seen_node);
            $last_seen_node = $data_node;

            if (defined (my $o = $last_seen_on_row[$row])) {
                $data_node->attach_to_right_of($o);
            }
            $last_seen_on_row[$row] = $data_node;
        }
    }

    return $root;
}

sub choose_column {
    my ($self) = @_;
    my $h = $self->linked_matrix;
    # For now, we just make the simplest possible choice.
    # We'll want to make this a Strategy later.
    return $h->R;
}

sub cover_column {
    my ($c) = @_;

    $c->R->L($c->L);
    $c->L->R($c->R);
    for (my $i = $c->D; $i ne $c; $i = $i->D) {
        for (my $j = $i->R; $j ne $i; $j = $j->R) {
            $j->D->U($j->U);
            $j->U->D($j->D);
            $j->C->decrease_S();
        }
    }
}

sub uncover_column {
    my ($c) = @_;

    for (my $i = $c->U; $i ne $c; $i = $i->U) {
        for (my $j = $i->L; $j ne $i; $j = $j->L) {
            $j->C->increase_S();
            $j->D->U($j);
            $j->U->D($j);
        }
    }
    $c->R->L($c);
    $c->L->R($c);
}

{
    my @O;

    # The variable names are chosen to correspond closely to the
    # algorithm on page 5 in
    # http://www-cs-faculty.stanford.edu/~uno/papers/dancing-color.ps.gz
    sub solve {
        my ($self) = @_;
        my $h = $self->linked_matrix;

        if ($h->R eq $h) {
            $self->writer->write([@O]);
            return;
        }

        my $c = $self->choose_column;
        cover_column($c);
        for (my $r = $c->D; $r ne $c; $r = $r->D) {
            push @O, $r->row;
            for (my $j = $r->R; $j ne $r; $j = $j->R) {
                cover_column($j->C);
            }

            $self->solve();

            pop @O;
            for (my $j = $r->L; $j ne $r; $j = $j->L) {
                uncover_column($j->C);
            }
        }
        uncover_column($c);
        return;
    }
}

__PACKAGE__->meta->make_immutable;
1;
