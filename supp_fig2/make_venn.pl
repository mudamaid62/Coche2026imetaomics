#!/usr/bin/perl
use warnings;
use strict;

my $hmm_list = shift(@ARGV);
my $mmseqs_list = shift(@ARGV);

my %all_proteins;
my %mmseqs_proteins;
my %hmm_proteins;

open(HMM,"$hmm_list");
while(my $x = <HMM>){
	chomp($x);
	$all_proteins{$x} = "seen";
	$hmm_proteins{$x} = "seen";
}
close HMM;
open(MMSEQS,"$mmseqs_list");
while(my $x = <MMSEQS>){
	chomp($x);
	$mmseqs_proteins{$x} = "seen";
	if(!exists($all_proteins{$x})){
		$all_proteins{$x} = "seen";
	}
}
close MMSEQS;
my $all = scalar(keys %all_proteins);
my $both = 0;
my $mmseqs = 0;
my $hmm = 0;
foreach my $x(sort keys %all_proteins){
	if(exists($mmseqs_proteins{$x}) and exists($hmm_proteins{$x})){
		$both++;
		print "$x\tBoth\n";
	}elsif(exists($mmseqs_proteins{$x})){
		$mmseqs++;
		print "$x\tMMSeqs2\n";
	}else{
		$hmm++;
		print "$x\thmmscan\n";
	}
}
print STDERR "ALL $all, BOTH $both, MMSEQS $mmseqs, HMM $hmm\n";
