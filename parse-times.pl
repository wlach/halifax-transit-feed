#!/usr/bin/perl

use strict;

my $first = 1;
my $prev_comment = 0;
while (<STDIN>) {
    if ($_ !~ /^\#/) {
	if (!$first && !$prev_comment) {
	    print ",\n";
	} else {
	    $first = 0;
	    $prev_comment = 0;
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
	$prev_comment = 1;
    }
}

