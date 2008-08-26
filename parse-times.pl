#!/usr/bin/perl

use strict;

my $first = 1;
while (<STDIN>) {
    if ($_ !~ /^\#/) {
	if (!$first) {
	    print ",\n";
	} else {
	    $first = 0;
	}
	chomp;
	my @times = split /\ +/;
	print "  [ ";
	my $first = 1;
	foreach (@times) {
	    if (!$first) {
		print ", ";
	    } else {
		$first = 0;
	    }
	    print $_;
	}
	print "]";
    } else {
	# yes, this conditional is loaded with assumptions...
	print ",\n" . $_;
    }
}

