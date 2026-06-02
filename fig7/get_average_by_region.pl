#!/usr/bin/perl
use warnings;
use strict;

my $metadata = shift(@ARGV);
my $abundance_table = shift(@ARGV);
my $code_file = shift(@ARGV);

my %name;
open(CODE,$code_file);
while(my $x = <CODE>){
	chomp($x);
	my($code,$id) = split(/\t/,$x);
	$name{$code} = $id;
}
close CODE;

my %data;
my %region;
my @regions = ("CD", "AP", "SI");
my %metagenomes;
open(METADATA,"$metadata");
while(my $x = <METADATA>){
	chomp($x);
	my @array = split(/\t/,$x);
	my $metagenome = $array[1];
	$data{$metagenome} = $x;
	$region{$metagenome} = $array[0];
	if(!exists($metagenomes{$metagenome})){
		$metagenomes{$metagenome} = "added";
	}
}
close METADATA;

my %abundance;
my %bins;
open(ABUNDANCE,"$abundance_table");
while(my $x = <ABUNDANCE>){
	chomp($x);
	my($bin,$ab,$meta) = split(/\t/,$x);
	if(!exists($bins{$bin})){
		$bins{$bin} = "added";
	}
	my $id = "$bin~$name{$meta}";
	$abundance{$id} = $ab;
}
close ABUNDANCE;

my %averages_by_region;

foreach my $r(@regions){
	my %sum;
	foreach my $b(sort keys %bins){
		my $r_id = "$r~$b";
		$sum{$r_id} = 0;
		my $n = 0;
		foreach my $m(sort keys %metagenomes){
			if($region{$m} eq $r){
				my $id = "$b~$m";
				$sum{$r_id} += $abundance{$id};
				$n++;
			}
		}
		$averages_by_region{$r_id} = $sum{$r_id}/$n;
	}
}	
print "MAG\tCD_ab(\%)\tAP_ab(\%)\tSI_ab(\%)\n";
foreach my $b(sort keys %bins){
	print "$b";
	foreach my $r(@regions){
		my $r_id = "$r~$b";
		print "\t$averages_by_region{$r_id}";
	}
	print "\n";
}		
