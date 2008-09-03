#!/usr/bin/perl

use strict;

sub parse_time {
    my ($time) = @_;

    my ($hour, $minute);

    if ($time =~ /a\Z/) {
	$time =~ m/([0-9]+)([0-9][0-9])a/;
	($hour, $minute) = ($1, $2);
    } elsif ($time =~ /p\Z/) {
	$time =~ m/([0-9]+)([0-9][0-9])p/;
	($hour, $minute) = ($1, $2);
	if ($hour < 12) {
	    $hour += 12;
	}
    } elsif ($time =~ /x\Z/) {
	$time =~ m/([0-9]+)([0-9][0-9])x/;
	($hour, $minute) = ($1, $2);
	if ($hour == 12) {
	    $hour += 12;
	} else {
	    $hour += 24;
	}
    } elsif ($time =~ /^-\Z/) {
	($hour, $minute) = (0, 0);
	# no stop at this time
    } else {
	print "Should not happen! Time misformed.\n";
	exit;
    }

    return ($hour, $minute);
}

my $num_intervals = $ARGV[0] or die "No num intervals given!";

my @times;

$_ = <STDIN>;
print $_;

if ($_ !~ /^\#/) {
    my @timestrs = split /\ +/;
    foreach (@timestrs) {
	my ($hour, $minute) = parse_time($_);
	push @times, [ $hour, $minute ];
    }
}

for (my $i=1; $i<($num_intervals+1); $i++) {
    my $first = 1;
    foreach (@times) {
	my $mytime = $_;
	my ($hour, $minute) = (@$mytime[0], @$mytime[1]);
	if ($hour > 0 || $minute > 0) {
	    $minute += 30 * $i;
	    if ($minute > 59) {
		$hour += int($minute / 60);
		$minute = $minute % 60;
		if ($minute < 10) {
		    $minute = "0" . $minute;
		}
	    }
	}
	
	sub print_time {
	    my ($hour, $minute) = @_;
	    if ($hour == 0 && $minute == 0) {
		print "-";
	    } else {
		if ($hour < 12) {
		    print "$hour$minute" . "a";
		} else {
		    if ($hour > 12) {
			$hour -= 12;
		    }
		    print "$hour$minute" . "p";
		}
	    }
	}

	if (!$first) {
	    print " ";
	    print_time($hour, $minute);
	} else {
	    $first = 0;
	    print_time($hour, $minute);
	}
    }
print "\n";
}
