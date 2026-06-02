#!/usr/bin/perl
use warnings;
use strict;

my $go_table = shift(@ARGV);
my $metadata_table = shift(@ARGV);

my %metadata;
open(DATA,"$metadata_table");
while(my $m = <DATA>){
	chomp($m);
	my @array = split(/\t/,$m);
	$metadata{$array[0]} = "$array[4]~$array[17]~$array[5]~$array[18]~$array[1]~$array[16]~$array[6]~$array[19]~$array[11]~$array[14]";
}
close DATA;
open(GO,"$go_table");
while(my $x = <GO>){
	chomp($x);
	my @array = split(/\t/,$x);
	my $protein = shift(@array);
	my @meta = split(/~/,$metadata{$protein});
	my $go_terms = join "\t",@array;
	my $data = join "\t",@meta;
	print "$protein\t$data\t$go_terms\n";
}
