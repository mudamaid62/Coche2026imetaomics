#!/usr/bin/perl
use warnings;
use strict;
use Chart::Gnuplot;

my $similarity_table = shift(@ARGV);
my $structural_table = shift(@ARGV);
my $threshold = shift(@ARGV);
my $plot = shift(@ARGV);

my %list;
my %score;
my @similarities;

open(TABLE,"$similarity_table");
while(my $x = <TABLE>){
	chomp($x);
	my ($i,$j,$similarity) = split(/\t/,$x);
	if(!exists($list{$i})){
		$list{$i} = "added";
	}
	if(!exists($list{$j})){
                $list{$j} = "added";
        }
	my $name = "$i~$j";
	my $same = "$j~$i";
	$score{$name} = $similarity;
	$score{$same} = $similarity;
	push @similarities, $similarity;
}
close TABLE;
my @sorted_similarities = sort{$a<=>$b}(@similarities);
my $sorted = join "\t",@sorted_similarities;
my $q25 = get_percentile(25,$sorted);
my $q75 = get_percentile(75,$sorted);
my $bin_width = (2*($q75 - $q25))/((scalar(@sorted_similarities))**(1/3));
my $min = $sorted_similarities[0];
my $max_index = (scalar(@sorted_similarities)) - 1;
my $max = $sorted_similarities[$max_index];
my $i = $min;
my $total = scalar(@sorted_similarities);
print STDERR "Min: $min, Max: $max, Total: $total, Q25: $q25, Q75: $q75, width: $bin_width\n";
my @frequencies;
my @x_values;
my $min_freq = 0;
my $used_values = 0;
my $max_f = 0;
until($i >= $max){
	my $f = 0;
	my $low = $i;
	my $high = $i + $bin_width;
	my $xi = ($low + $high)/2;
	push @x_values,$xi;
	foreach my $s(@sorted_similarities){
		if($s > $low and $s <= $high){
			$f++;
			$used_values++;
		}
	}
	if($f > $max_f){
		$max_f = $f;
	}
	push @frequencies,$f;
	$i += $bin_width;
}	
foreach my $t(@sorted_similarities){
	if($t == $min){
		$min_freq++;
		$used_values++;
	}
}
my $first_freq = shift(@frequencies);
my $updated_first = $first_freq + $min_freq;
if($updated_first > $max_f){
	$max_f = $updated_first;
}
unshift @frequencies,$updated_first;
my $index = (scalar(@frequencies)) - 1;
print STDERR "Used values $used_values/$total\n";
my $chart = Chart::Gnuplot->new(
        terminal => 'pdf',
        output => "$plot",
        xlabel => "Functional Similarity (cosine)",
        ylabel => "Frequency",
        xrange => [0,1],
        yrange => [0,$max_f],
);
$chart->line(
    from     => "$threshold,0",
    to       => "$threshold,$max_f",
    linetype => 'dash',
    width    => 5,
    color    => "#008b0000",
);
my $dataset = Chart::Gnuplot::DataSet->new(
        xdata => \@x_values,
        ydata => \@frequencies,
        style => 'lines',
        color => '#0000008b',
        width => '5',
);
$chart->plot2d($dataset);

my %structure;
open(STRUCTURE,"$structural_table");
while(my $y = <STRUCTURE>){
	chomp($y);
	my($protein,$cluster) = split(/\t/,$y);
	$structure{$protein} = $cluster;
}
close STRUCTURE;	
print "Protein\tStructural_cluster\tFunctional_cluster\n";
my @clusters_list;
my %cluster_defined;
my $id = 1;

foreach my $v(keys %list){
	#print STDERR "Checking $v\n";
	if(exists($cluster_defined{$v})){
		next;
	}
	my %cluster;
	foreach my $w(keys %list){
		if(exists($cluster_defined{$w})){
                	next;
        	}
		my $pair = "$v~$w";
		if($score{$pair} >= $threshold){
			$cluster{$w} = "added";
		}
	}	
	foreach my $h(keys %cluster){
		foreach my $k(keys %cluster){
			my $h_pair = "$h~$k";
			if($score{$h_pair} < $threshold){
				$cluster{$h} = "removed";
			}
		}
	}
	my $name = "cluster\_$id";
	my $n = 0;
	foreach my $m(keys %cluster){
		if($cluster{$m} eq "added"){
			$cluster_defined{$m} = "$name";
			$n++;
		}
	}														
	if($n > 0){
		push @clusters_list,$name;
		$id++;
	}
}
foreach my $q(sort keys %list){
	if(exists($structure{$q})){
		print "$q\t$structure{$q}\t$cluster_defined{$q}\n";
	}else{
		print "$q\tUndefined\t$cluster_defined{$q}\n";
	}
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
