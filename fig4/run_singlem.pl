#!/usr/bin/perl
use warnings;
use strict;

my $code_file = shift(@ARGV);

open(CODE,"$code_file");
while(my $x = <CODE>){
	chomp($x);
	my($code,$name) = split(/\t/,$x);
	system "singlem pipe -1 /media/databases/metagenomas_beta_antartica/$code\/$code\_filtp_woHU_1.fastq.gz -2 /media/databases/metagenomas_beta_antartica/$code\/$code\_filtp_woHU_2.fastq.gz --otu-table $name\_blas_otu_table --threads 20 --output-extras --singlem-packages ../singlem_packages/class_A_BLAs.spkg ../singlem_packages/class_B1_BLAs.spkg ../singlem_packages/class_B2_BLAs.spkg ../singlem_packages/class_B3_BLAs.spkg ../singlem_packages/class_C_BLAs.spkg ../singlem_packages/class_D_BLAs.spkg --no-assign-taxonomy";
}
