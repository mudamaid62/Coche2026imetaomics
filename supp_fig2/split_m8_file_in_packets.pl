#!/usr/bin/perl
use warnings;
use strict;

my $m8_file = shift(@ARGV);
my $packet_prefix = shift(@ARGV);
my $max_number_per_split = shift(@ARGV); #1000000

my @data;
open(M8,"$m8_file");

while(my $x = <M8>){
	chomp($x);
	push @data, $x;
}
my $i = 1;
my $final_splits_number = 0;
foreach my $x (@data){
	my $splits_number = 0;
	until((($splits_number * $max_number_per_split)/$i) >= 1){
		$splits_number++;
	}
	if($splits_number > $final_splits_number){
		$final_splits_number = $splits_number;
	}
	open my $out, ">>", "$packet_prefix\_$splits_number\.m8";
        print $out "$x\n";
        close $out;
	if(($i % 1000) == 0){
                print STDERR "Printed $i registers\n";
        }
	$i++;
}
	
print STDERR "Splits --> $final_splits_number\n";

