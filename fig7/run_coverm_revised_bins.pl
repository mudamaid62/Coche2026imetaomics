#!/usr/bin/perl
use warnings;
use strict;

my $code_file = shift(@ARGV);
my $dir = "/media/databases/metagenomas_beta_antartica";

open(CODE,"$code_file");
while(my $x = <CODE>){
	chomp($x);
	my($code,$name) = split(/\t/,$x);
	system "coverm genome -1 $dir/$code/$code\_filtp_woHU_1.fastq.gz -2 $dir/$code/$code\_filtp_woHU_1.fastq.gz -d /media/databases/metagenomas_beta_antartica/all_bins/revision_bla_bins -x fa -p bwa-mem2 --min-read-aligned-percent 75 --min-read-percent-identity 95 --proper-pairs-only --exclude-supplementary -m relative_bundance -o $name\_rel_ab.txt -t 28";
}
