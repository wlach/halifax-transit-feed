#!/usr/bin/perl

use strict;

open FILE, $ARGV[0] or die $!;

my $done_places = 0;
my @sched;
my $sched_name;

while (<FILE>) {
    chomp;
    if ($_ !~ /^\Z/) {
	$sched_name = $_;	
    } else {
	last
    }
}

print "$sched_name\n";

while (<FILE>) {
    if ($_ !~ /^\#/) {
	chomp;
	if ($_ !~ /^\Z/) {
	    push @sched, $_;
	    #print "$_\n";
	} else {
	    last;
	}
    }
}

#print "\n";

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

while (<FILE>) {
    if ($_ !~ /^\#/) {
	chomp;
	my @times = split /\ +/;
	my $i = 0;
	foreach (@times) {
	    my $time = parse_time($_);
	    $sched[$i] .= "\t$time";
	    $i++;
	}
    }   
}  

foreach (@sched) {
    print "$_\n";
}

print "\n";
