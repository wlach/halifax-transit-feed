#!/usr/bin/perl

use strict;

my $first = 1;
while (<STDIN>) {
    if ($first) {
	$first = 0;
	print "  - $_";
    } else {
	print "    $_";
    }
}
