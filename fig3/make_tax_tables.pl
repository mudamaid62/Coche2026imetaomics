#!/usr/bin/perl
use warnings;
use strict;

my $cat = shift(@ARGV);
my $diamond = shift(@ARGV);

my %class;
my %hits;
my %tax;

open(TAX,"$cat");
while(my $x = <TAX>){
	chomp($x);
	my @array = split(/\t/,$x);
	my @t_array = split(/\;/,$array[3]);
	my $kingdom = "k__";
	my $phylum = "p__";
	my $class = "c__";
	my $order = "o__";
	my $family = "f__";
	my $genus = "g__";
	my $species = "s__";
	foreach my $t(@t_array){
		$t =~ s/__/_/g;
		my($type,$definition) = split(/_/,$t);
		if($definition =~ m/\*/){
			$definition = "";
		}
		if($type eq "d"){
			$kingdom.= $definition;
		}elsif($type eq "p"){
			$phylum.= $definition;
		}elsif($type eq "c"){
                        $class.= $definition;
		}elsif($type eq "o"){
                        $order.= $definition;
		}elsif($type eq "f"){
                        $family.= $definition;
		}elsif($type eq "g"){
                        $genus.= $definition;
		}elsif($type eq "s"){
                        $species.= $definition;
		}
	}
	my $tax = "$kingdom\; $phylum\; $class\; $order\; $family\; $genus\; $species";
	$tax{$array[0]} = $tax;
}
close TAX;
open(HITS,"$diamond");
my $unique = "A";
my %class_check;
my @classes;
while(my $y = <HITS>){
	chomp($y);
	my @array = split(/\t/,$y);
	my $name = "$unique~$array[0]~$array[1]";
	if(!exists($class_check{$array[6]})){
		push @classes, $array[6];
		$class_check{$array[6]} = "class added";
	}
	$hits{$name} = $array[4];
	$class{$name} = $array[6];
	$unique++;
}
foreach my $z(@classes){
	open(OUT,">$z\_tax_table");
	foreach my $k(sort keys %hits){
		my ($id,$meta,$contig) = split(/~/,$k);
		my $name = "$meta~$contig";
		if($class{$k} eq $z){
			print OUT "$hits{$k}\t$tax{$name}\n";
		}
	}
}
