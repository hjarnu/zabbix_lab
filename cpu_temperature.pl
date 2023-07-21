#!/usr/bin/perl

use strict;
use warnings;

$_ = qx{sensors};

my @list;

for (split /^\n/m) {
    if (/^coretemp/) {
        my $sum = 0;
        my $cores = 0;
        $cores++, $sum += $_ for /^Core \d+: +\+(\d+)/mg;
        push @list, sprintf "%.1f", $sum / $cores;
    }
}

print join ", ", @list;
