#/usr/bin/perl
use warnings;
use strict;
use List::MoreUtils qw(any);

my $venn_table = shift(@ARGV);
my $all_best_m8 = shift(@ARGV);

my @A_blas = ('A-I','A-II','A-III','A-IV','A-V','A-VI','A-VII','A-VIII','A-IX','A-X','A-XI');
my @B1_blas = ('B1-I','B1-II','B1-III','B1-IV','B1-V','B1-VI','B1-VII','B1-VIII','B1-IX','B1-X','B1-XI','B1-XII','B1-XIII');
my @B2_blas = ('B2-I');
my @B3_blas = ('B3-I','B3-II','B3-III','B3-IV','B3-V','B3-VI','B3-VII','B3-VIII','B3-IX','B3-X','B3-XI','B3-XII');
my @C_blas = ('C-I','C-II','C-III','C-IV');
my @D_blas = ('D-I','D-II','D-III','D-IV','D-V');
my @PBPs = ('Carboxylesterase EstU1', 'Carboxylesterase PBP-5', 'Carboxylesterase PBP-A', 'Endopeptidase carboxipeptidase', 'Transpeptidase', 'Transpeptidase PBP2X'); 
my @MBLs = ('AHL-lactonase','Arylsulfatase','Beta-CASP ribonuclase','Chlorothalonil dehalogenase','Cyclase','Dinitroanisole o-demethylase','Flavoprotein','Glyoxolase II 1xm8-like','Glyoxolase II gloB-like','Lactonase','Methyl-parathion hydrolase','Phosphate phosphodiesterase','Phosphorylcholine esterase','PQQ biosynthesis protein B','Putative ribonuclease','Pyridoxolactonase','Ribonuclease Z','Sulfur dioxygenase');
my %venn;

open(VENN,"$venn_table");
while(my $x = <VENN>){
	chomp($x);
	my ($protein, $type) = split(/\t/,$x);
	$venn{$protein} = $type;
}
close VENN;
open(M8,"$all_best_m8");
print "query\tqlen\ttarget\ttlen\tqstart\tqend\tstart\ttend\te-value\tbits\tpident\tqcov\ttcov\tlen_frac\tstructural_cluster\ttype\tsuperfamily\tclass\tmethod\n";

while(my $x = <M8>){
	chomp($x);
	my @array = split(/\t/,$x);
	my $protein = shift(@array);
	my $sc = pop(@array);
	my $type = "placeholder"; #BLA or TN
	my $superfamily = "placeholder"; #PBP or MBL
	my $class = "placeholder";
	if(any {$_ eq $sc} @A_blas or any {$_ eq $sc} @B1_blas or any {$_ eq $sc} @B2_blas or any {$_ eq $sc} @B3_blas or any {$_ eq $sc} @C_blas or any {$_ eq $sc} @D_blas){
		$type = "BLA";
	}else{
		$type = "TN";
	}
	if(any {$_ eq $sc} @A_blas or any {$_ eq $sc} @C_blas or any {$_ eq $sc} @D_blas or any {$_ eq $sc} @PBPs){
		$superfamily = "PBP";
	}else{
		$superfamily = "MBL";
	}
	if(any {$_ eq $sc} @A_blas){
		$class = "A";
	}elsif(any {$_ eq $sc} @B1_blas){
		$class = "B1";
	}elsif(any {$_ eq $sc} @B2_blas){
                $class = "B2";
	}elsif(any {$_ eq $sc} @B3_blas){
                $class = "B3";
	}elsif(any {$_ eq $sc} @C_blas){
                $class = "C";
	}elsif(any {$_ eq $sc} @D_blas){
                $class = "D";
	}elsif(any {$_ eq $sc} @PBPs){
		$class = "PBP_TN";
	}else{
		$class = "MBL_TN";
	}
	print "$x\t$type\t$superfamily\t$class\t$venn{$protein}\n";
}	
	
 
