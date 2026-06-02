#!/usr/bin/perl
use warnings;
use strict;

my $code_file = shift(@ARGV);

open(CODE,"$code_file");
while(my $x = <CODE>){
	chomp($x);
	my($code,$name) = split(/\t/,$x);
	system "singlem microbial_fraction -1 /media/databases/metagenomas_beta_antartica/$code\/$code\_filtp_woHU_1.fastq.gz -2 /media/databases/metagenomas_beta_antartica/$code\/$code\_filtp_woHU_2.fastq.gz -p $name\_taxonomic_profile --output-tsv $name\_smf";
}
