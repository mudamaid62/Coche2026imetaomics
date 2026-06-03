#!/usr/bin/perl
use warnings;
use strict;

my $list = shift(@ARGV);
my $fasta_file = shift(@ARGV);

my @contigs;
open(LIST,"$list");
while(my $x = <LIST>){
	chomp($x);
	push @contigs, $x;
}
close LIST;
my $fasta = read_fasta($fasta_file);
my %seqs = fasta_parser($fasta);
foreach my $z(@contigs){
	print ">$z\n$seqs{$z}\n";
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
                        $header =~ s/[ >\:\[\/\\]+/_/g;
                        $header =~ s/\]//g;
                        my $seq = join "",@f_array;
                        $out{$header} = $seq;
                }
        }
        return %out;
}
