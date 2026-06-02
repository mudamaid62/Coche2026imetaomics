#!/usr/bin/perl
use warnings;
use strict;

my $otu_table = shift(@ARGV);
my %coverage;
my %hits;

open(TABLE,"$otu_table");
while(my $x = <TABLE>){
	chomp($x);
	if($x =~ m/sample/){
		next;
	}
	my @array = split(/\t/,$x);
	my $base_name = "$array[0]:$array[2]:$array[4]";
	if(!exists($coverage{$array[0]})){
		$coverage{$array[0]} = $array[4];
		$hits{$array[0]} = $array[3];
	}else{
		$coverage{$array[0]} += $array[4];
		$hits{$array[0]} += $array[3];
	}
	my @read_names = split(/ /,$array[6]);
	my @read_seqs = split(/ /,$array[9]);
	my $last = $array[3] - 1;
	for my $i(0..$last){
		my $length = length($read_seqs[$i]);
		my $quality = "=" x $length;
		my $full_name = "$base_name:$read_names[$i]";
		print "\@$full_name\n$read_seqs[$i]\n+\n$quality\n";
	}
}	 	
foreach my $z(sort keys %coverage){
	print STDERR "$z --> $hits{$z}\t$coverage{$z}\n";

}
