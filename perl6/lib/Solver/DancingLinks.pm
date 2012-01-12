use Data::Node;
use Data::Header;

class Solver::DancingLinks {
    has @.matrix;
    has $.writer;
    has $!linked-matrix;

    sub width(@matrix) {
        return 0 unless @matrix;
        return 1 + max(map { max @($_) }, @matrix);
    }

    sub height(@matrix) {
        return +@matrix;
    }

    method linked-matrix {
        $!linked-matrix //= build-linked-representation(@!matrix);
    }

    sub build-linked-representation(@matrix) {
        my $width = width(@matrix);
        my $height = height(@matrix);

        my $root = Data::Header.new();
        my $last-seen-header = $root;
        my @last-seen-on-row;
        for ^$width -> $column {
            my $header = Data::Header.new();
            $header.attach-to-right-of($last-seen-header);
            $last-seen-header = $header;

            my $last-seen-node = $header;
            for ^$height -> $row {
                next unless any(@matrix[$row].list) == $column;

                my $data-node = Data::Node.new(:$row, :C($header));
                $data-node.attach-below($last-seen-node);
                $last-seen-node = $data-node;

                if defined(my $o = @last-seen-on-row[$row]) {
                    $data-node.attach-to-right-of($o);
                }
                @last-seen-on-row[$row] = $data-node;
            }
        }

        return $root;
    }

    method !choose-column() {
        my $r = self.linked-matrix;
        # RAKUDO: .min(*.S) is broken
        my $min = Inf;
        my $smallest;
        for $r.R, *.R ...^ $r {
            if $min > .S {
                $min = .S;
                $smallest = $_;
            }
        }
        die unless defined $smallest;
        return $smallest;
    }

    sub cover-column(Data::Header $c) {
        $c.R.L = $c.L;
        $c.L.R = $c.R;
        for $c.D, *.D ...^ $c -> $i {
            for $i.R, *.R ...^ $i -> $j {
                $j.D.U = $j.U;
                $j.U.D = $j.D;
                $j.C.decrease-S;
            }
        }
    }

    sub uncover-column(Data::Header $c) {
        for $c.U, *.U ...^ $c -> $i {
            for $i.L, *.L ...^ $i -> $j {
                $j.C.increase-S;
                $j.D.U = $j;
                $j.U.D = $j;
            }
        }
        $c.R.L = $c;
        $c.L.R = $c;
    }

    method solve {
        my @*O;
        self!solve_helper(self.linked-matrix);
    }

    method !solve_helper(Data::Header $h) {
        if $h.R === $h {
            my @solution = @*O; # copy values
            $!writer.write(@solution);
            return;
        }

        my Data::Header $c = self!choose-column;
        cover-column($c);
        for $c.D, *.D ...^ $c -> $r {
            push @*O, $r.row;
            cover-column(.C) for $r.R, *.R ...^ $r;
            self!solve_helper($h);
            uncover-column(.C) for $r.L, *.L ...^ $r;
            pop @*O;
        }
        uncover-column($c);
        return;
    }
}
