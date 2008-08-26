#!/usr/bin/perl

use strict;

sub parse_time {
    my ($time) = @_;
    if ($time =~ /a\Z/) {
	$time =~ s/([0-9]+)([0-9][0-9])a/\1:\2:00/;
	if ($time =~ /^[0-9]:/) {
	    $time = "0" . $time;
	}
    } elsif ($time =~ /p\Z/) {
	my $hour = $time;
	$hour =~ s/^([0-9]+)[0-9][0-9]p/\1/;
	$time =~ s/[0-9]+([0-9][0-9])p/:\1:00/;
	if ($hour < 12) {
	    $hour += 12;
	}
	$time = $hour . $time;
    } elsif ($time =~ /x\Z/) {
	my $hour = $time;
	$hour =~ s/^([0-9]+)[0-9][0-9]x/\1/;
	$time =~ s/[0-9]+([0-9][0-9])x/:\1:00/;
	if ($hour == 12) {
	    $hour += 12;
	} else {
	    $hour += 24;
	}
	$time = $hour . $time;
    } elsif ($time =~ /^-\Z/) {
	# no stop at this time
    } else {
	print "Should not happen! Time misformed.\n";
	exit;
    }

    return $time;

}

while (<STDIN>) {
    if ($_ !~ /^\#/) {
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
	print "],\n";
    } else {
	print $_;
    }
}  

