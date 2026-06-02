#!/usr/bin/perl
use warnings;
use strict;

my $contig_dir = shift(@ARGV);
my $contig_list = shift(@ARGV);

open(CONTIG,"$contig_list");
my %contigs;
my %metagenomes;
my $all_names = 0;
my $nr_names = 0;
my %nr;
my $redundant = 0;

while(my $x = <CONTIG>){
	chomp($x);
	my($metagenome,$contig) = split(/\t/,$x);
	my $name = "$metagenome~$contig";
	$all_names++;
	if(!exists($nr{$name})){
		$contigs{$name} = $metagenome;
		$nr_names++;
		$nr{$name} = "yes";
	}else{
		$redundant++;
	}
	if(!exists($metagenomes{$metagenome})){
		$metagenomes{$metagenome} = "added";
	}
}
print STDERR "all_names --> $all_names, nr_names --> $nr_names, redundant_names --> $redundant\n";
close CONTIG;
foreach my $z(sort keys %metagenomes){
	my $fasta = read_fasta("$contig_dir/$z");
	my %seqs = fasta_parser($fasta);
	foreach my $k(sort keys %contigs){
		my($meta,$contig) = split(/~/,$k);
		if($meta eq $z){
			print STDERR "Searching $contig in $meta\n";
			print ">$k\n$seqs{$contig}\n";
		}
	}
}

sub read_fasta{
        my $file = shift;
        my @lines;
        open(FASTA,"$file") or die "$file not found $!";
        while(my $x = <FASTA>){
                chomp($x);
                if($x =~ m/>/){
                        my @x_array = split(/>/,$x);
                        my $white = shift(@x_array);
                        my $pre = join "_",@x_array;
                        my $y = ">$pre";
                        $x = ">$pre";
                }
                push @lines, $x;
        }
        my $fasta = join "\n",@lines;
        return $fasta;
        close FASTA;
}
sub fasta_parser{
        my $fasta = shift;
        my @seqs = split(/>/,$fasta);
        my %out;
        foreach my $x(@seqs){
                if($x eq ""){
                        next;
                }else{
                        my @f_array = split(/\n/,$x);
                        my $header = shift(@f_array);
                        $header =~ s/[ >\:]+/_/g;
                        my $seq = join "",@f_array;
                        $out{$header} = $seq;
                }
        }
        return %out;
}
