#!/usr/bin/perl
use warnings;
use strict;

my $m8_file = shift(@ARGV);
my $consolidation_table = shift(@ARGV);

open(CONS,"$consolidation_table");
my %sc;
while(my $x = <CONS>){
	chomp($x);
	my @array = split(/\t/,$x);
	$sc{$array[0]} = $array[1];
}
close CONS;
open(M8,"$m8_file");
while(my $x = <M8>){
	chomp($x);
	my @array = split(/\t/,$x);
	my $target = $array[2];
	print "$x\t$sc{$target}\n";
}	
	
