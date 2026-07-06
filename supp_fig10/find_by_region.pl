#!/usr/bin/perl
use warnings;
use strict;

my $metadata = shift(@ARGV);
my $by_site = shift(@ARGV);
my $protein_metadata = shift(@ARGV);

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

open(BY_SITE, "$by_site");

my %abundance;
my %taxonomy;
my %proteins;

while(my $x = <BY_SITE>){
	chomp($x);
	my ($metagenome,$protein,$count,$ab,$tax) = split(/\t/,$x);
	my $name = "$metagenome~$protein";
	$abundance{$name} = $ab;
	$taxonomy{$name} = $tax;
	if(!exists($proteins{$protein})){
		$proteins{$protein} = "added";
	}
}
close BY_SITE;
my %p_meta;
open(P_META,"$protein_metadata");
while(my $x = <P_META>){
	chomp($x);
	my @array = split(/\t/,$x);
	my $p = shift(@array);
	$p_meta{$p} = $x;
}
close P_META;

my %region_average;
my %region_tax;

foreach my $r(@regions){
	my $default_tax = "no taxid assigned";
	my $default_ab = 0;
	foreach my $p(keys %proteins){
        	my @abs;
        	my @taxes;
		my $n = 0;
		foreach my $m(keys %metagenomes){
			if($region{$m} eq $r){
				my $name = "$m~$p";
				if(exists($abundance{$name})){
					push @abs, $abundance{$name};
					push @taxes, $taxonomy{$name};
				}else{
					push @abs, $default_ab;
					push @taxes, $default_tax;
				}
			}
			$n++;
		}
		my @sorted = sort{$a <=> $b}@abs;
		my $avg_sum = 0;
                foreach my $i(@sorted){
                        $avg_sum += $i;
                }
		my $tax_to_solve = join "~",@taxes;
		my $r_name = "$r~$p";
		$region_average{$r_name} = $avg_sum/$n; 	
		$region_tax{$r_name} = solve_tax($tax_to_solve);
	}
}

print "Protein\tStrutural_cluster\tClass\tTotal_abundance\tConsensus_taxonomy\tCD_ab\tCD_tax\tAP_ab\tAP_tax\tSI_ab\tSI_tax\n";
foreach my $p(sort keys %proteins){
	print "$p_meta{$p}";
        foreach my $r(@regions){
		my $r_name = "$r~$p";
		print "\t$region_average{$r_name}\t$region_tax{$r_name}";
	}
	print "\n";
}

sub get_percentile{
        my ($number,$values) = @_;
        my @array = split(/\t/,$values);
        my $len = scalar(@array);
        my $rank = int(($number/100)*$len);
        my $index = $rank - 1;
        my $value = $array[$index];
        return $value;
}

sub solve_tax{
        my $string = shift;
        my @taxonomies = split(/~/,$string);
        my $best_tax = "no taxid assigned";
        if(scalar(@taxonomies) == 1){
                $best_tax = $taxonomies[0];
                #print STDERR "No need to solve, tax is $best_tax\n";
                return $best_tax;
        }else{
                my $conflict = "no conflict";
                my @roots;
                my @domains;
                my @phyla;
                my @classes;
                my @orders;
                my @families;
                my @genera;
                my @species;
                #print STDERR "Observed taxa:\n";
                foreach my $t(@taxonomies){
                        #print STDERR "$t\n";
                        if($t eq "no taxid assigned"){
                                next;
                        }
                        my @levels = split(/\;/,$t);
                        if(defined($levels[0])){
                                push @roots,$levels[0];
                        }
                        if(defined($levels[1])){
                                push @domains,$levels[1];
                        }
                        if(defined($levels[2])){
                                push @phyla,$levels[2];
                        }
                        if(defined($levels[3])){
                                push @classes,$levels[3];
                        }
                        if(defined($levels[4])){
                                push @orders,$levels[4];
                        }
                        if(defined($levels[5])){
                                push @families,$levels[5];
                        }
                        if(defined($levels[6])){
                                push @genera,$levels[6];
                        }
                        if(defined($levels[7])){
                                push @species,$levels[7];
                        }
                }
                my $i = 0;
                while($conflict eq "no conflict" and $i <= 7){
                        if($i == 0){
                                if(scalar(@roots) > 0){
                                        my $current = $roots[0];
                                        foreach my $k(@roots){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax = $current;
                                        }
                                }
                        }elsif($i == 1){
                                if(scalar(@domains) > 0){
                                        my $current = $domains[0];
                                        foreach my $k(@domains){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }elsif($i == 2){
                                if(scalar(@phyla) > 0){
                                        my $current = $phyla[0];
                                        foreach my $k(@phyla){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }elsif($i == 3){
                                if(scalar(@classes) > 0){
                                        my $current = $classes[0];
                                        foreach my $k(@classes){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }elsif($i == 4){
                                if(scalar(@orders) > 0){
                                        my $current = $orders[0];
                                        foreach my $k(@orders){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }elsif($i == 5){
                                if(scalar(@families) > 0){
                                        my $current = $families[0];
                                        foreach my $k(@families){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }elsif($i == 6){
                                if(scalar(@genera) > 0){
                                        my $current = $genera[0];
                                        foreach my $k(@genera){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }elsif($i == 7){
                                if(scalar(@species) > 0){
                                        my $current = $species[0];
                                        foreach my $k(@species){
                                                if($k ne $current){
                                                        $conflict = "found conflict";
                                                }
                                        }
                                        if($conflict eq "no conflict"){
                                                $best_tax .= ";$current";
                                        }
                                }
                        }
                        $i++;
                }
                return "$best_tax";
        }
}

