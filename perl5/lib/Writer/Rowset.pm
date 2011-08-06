use 5.010;
use strict;
use warnings;

package Writer::Rowset;

use Moose;

extends 'Writer';

sub write {
    my ($self, $rowset) = @_;

    say sprintf "[%s]", join ", ", @{$rowset};
    return;
}

1;
