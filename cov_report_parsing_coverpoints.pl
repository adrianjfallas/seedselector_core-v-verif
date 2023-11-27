#!/usr/bin/env perl

use strict 'vars';
use warnings;

my $file = "merged_functional_coverage_detailed.log";

open(LOG,"$file") or die "Can't open [$file]: $!\n";

foreach my $line(<LOG>) {
   if($line =~ /cg_(\S+)\s+(\S+)%,\s+(\S+)%\s+\((\d+)\/(\d+)\)/) {
      print "-----------------------------------------------------------------------------------------------------\n";
      print "  coverpoint                          = cg_$1\n";
      print "  functional_coverage_overall_covered = $3%\n";
      print "  functional_coverage_points_covered  = $4\n";
      print "  functional_coverage_points_total    = $5\n";
      print "-----------------------------------------------------------------------------------------------------\n";
   };
};

exit(0);
