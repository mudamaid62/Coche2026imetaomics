#!/usr/bin/perl
use warnings;
use strict;

for my $k(60..84){
	system "/home/patricio/CAT_pack/CAT_pack/CAT_pack reads --mode cr -c ../relevant_contigs.fasta -1 MetaAn_$k\_blas.fastq -d /media/databases/cat_database_GTDB_r220_27-08-24/db/ -t /media/databases/cat_database_GTDB_r220_27-08-24/tax/ --c2c ../CAT_relevant_contigs.contig2classification.txt -o cat_MetaAn_$k --no_stars -n 20 --sensitive --block_size 6 --tmpdir temp";
}
