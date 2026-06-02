#!/usr/bin/perl
use warnings;
use strict;

my $full_m8 = shift(@ARGV);
my $list = shift(@ARGV);

my %data;
open(FULL,"$full_m8");
while(my $x = <FULL>){
	chomp($x);
	my @array = split(/\t/,$x);
	my $p = shift(@array);
	my $meta = join "\t",@array;
	$data{$p} = $meta;
}
close FULL;
open(LIST,"$list");
while(my $x = <LIST>){
	chomp($x);
	if(exists($data{$x})){
		print "$x\t$data{$x}\n";
	}else{
		warn "$x not found\n";
	}
}
close LIST;	
