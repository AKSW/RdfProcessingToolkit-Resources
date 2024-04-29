#! perl

use v5.36;
use FindBin;
use if -d "$FindBin::Bin/local", lib => "$FindBin::Bin/local/lib/perl5";
use Text::CSV qw(csv);
use List::Util qw(min max);
use File::Find;
use POSIX qw(floor ceil);

my $dir = shift // die "Syntax: $0 /path/to/data_root\n";

my @mem;

find(sub {
       if ($_ eq 'summary.csv') {
	 my $aoh = csv(in => "summary.csv",
		       headers => 'auto');
	 my $mem_max = max map { $_->{memory_ram_max} } $aoh->@*;
	 push @mem, $mem_max;
       }
     }, $dir);
my $max = max(@mem);
my $min = min(@mem);

print "Max mem (raw): $max\n";
print "Min mem (raw): $min\n\n";

$max = 1+ int($max/(1024**3));
$min =    int($min/(1024**3));

$max = 2**ceil(log($max)/log(2));
$min = 2**floor(log(1+$min)/log(2))-1;

my $comment = "$min..$max";

my $max_margin = $max + int(log($max)/log(2)/2);
my $min_margin = max(floor($min - log(1+$min)/log(2)/2), 0);


my $step_size = int(($max - $min) / 9);
$step_size++ unless $step_size;
$max *= 1024**3;
$min *= 1024**3;
$max_margin *= 1024**3;
$min_margin *= 1024**3;
$step_size  *= 1024**3;
my $step1 = $min + $step_size;

print "Try this config:
xtick={$min,$step1,...,$max},% $comment
xmin=$min_margin,xmax=$max_margin,
";

if ($min) {
  print "enlarge x limits=0.1,
"; } else {
  print "enlarge x limits={rel=0.1,upper},
";
}
