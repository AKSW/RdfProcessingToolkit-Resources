#! perl

use v5.36;
use FindBin;
use if -d "$FindBin::Bin/local", lib => "$FindBin::Bin/local/lib/perl5";
use Text::CSV qw(csv);
use List::Util qw(max sum);
require "$FindBin::Bin/steps_config.inc.pl";

my $input = $ARGV[0] || '';
my ($prefix, $rest, $suffix) = split ':', $input, 3;
die "Syntax: prefix:col1,col2[:suffix] [log]\n" unless defined $rest;

$suffix //= '';
sub has_flag ($arg, $flag) { ",@{[ $arg || '' ]}," =~ /,$flag,/ }
my $log_scale = has_flag($ARGV[1], 'log');

my @columns = split ',', $rest;
if (length $suffix) {
  $_ .= $suffix for @columns;
}

my %m;
my %data;

#my $prefix = 'heterogeneity_';
#my @columns = qw(tabular mixed files nested);

# @MAX-MEMORY@
# \addplot coordinates {
#  % (62623391744,tabular) (64850673664,mixed) (62708592640,files) (62572564480,nested)
# };

# @DURATION@
# \addplot coordinates {
# (3.3873,tabular) (3.3877,mixed) (3.3933,files) (3.2923,nested)
# };
# \addplot coordinates {
# (2.8761,tabular) (4.2066,mixed) (4.2079,files) (6.463,nested)
# };
# \addplot coordinates {
# (3.1863,tabular) (3.186,mixed) (3.1837,files) (3.1892,nested)
# };
# \addplot coordinates {
# (3.1882,tabular) (3.2819,mixed) (3.1861,files) (3.1855,nested)
# };
# \addplot [nodes near coords] coordinates {
# (79.7413,tabular) (110.9203,mixed) (112.8629,files) (113.5375,nested)
# };

# @Y-COORDS@
# tabular, mixed, files, nested

# @STEPS-LEGEND@
# fix, xml, sparql, opt., map

# @TRIPLES@
# \addplot coordinates {
# (2000000,0\%) (1500020,25\%) (1000020,50\%) (500020,75\%) (20,100\%)
# };
# \addplot coordinates {
# (-1,0\%) (-1,25\%) (-1,50\%) (-1,75\%) (-1,100\%)
# };

# @INPUT-SIZES@
# \addplot coordinates {
# (0,tabular) (56148,mixed) (57168,files) (172660,nested)
# };
# \addplot coordinates {
# (0,tabular) (880428,mixed) (880840,files) (880864,nested)
# };
# \addplot coordinates {
# (353484,tabular) (34044,mixed) (33524,files) (0,nested)
# };


## Load the plot template plot.tex.template
sub load_template_file () {
  local $/;
  my $template_file = "$FindBin::Bin/plot.tex.template";
  open my $fh, '<', $template_file or die "$template_file: $!";
  scalar <$fh>;
}

## make a nicer label from the filename/text
sub nicel ($xs, @list) {
  for (@list) {
    s/\Q$suffix\E$// if $xs;
    s/_+$//;
    s|.*eswc-kgc-challenge-\d+/||;
    s|track\d+/||;
    s/gtfs-madrid-bench/GTFS Bench/;
    s/scale/scaled/;
    s/percent/\\%/;
    s/_/ /g;
    s|/|, |g;
    s/\d\K(tm|pom)\b/\U$1/g;
    s/\b(\w+)s?,\s*\1\s?\b/$1/g;
    s/[,\s]*$//;
    s/\s+/~/g;
  }
  wantarray ? @list : $list[0]
}

sub addplot_mem_max () {
  my @r;
  for my $col (nicel(1, @columns)) {
    push @r, "($data{$col}{mem_max},$col)";
  }
  "\\addplot coordinates {
@r
};
"
}

sub addplot_triples () {
  my @r;
  for my $col (nicel(1, @columns)) {
    push @r, "($data{$col}{triples},$col)";
  }
  "\\addplot coordinates {
@r
};"
}

sub addplot_input_sizes () {
  my @rr;
  for my $type (qw(xml json csv)) {
    my @r;
    my $skip = 1;
    for my $col (nicel(1, @columns)) {
      my $size = $data{$col}{input_size}{$type};
      $skip = 0 if $size;
      push @r, "($size,$col)";
    }
    push @rr, "\\addplot coordinates {
@r
};"
      unless $skip;
  }
  "@rr"
}

sub input_types () {
  my @rr;
  for my $type (qw(xml json csv)) {
    my $skip = 1;
    for my $col (nicel(1, @columns)) {
      my $size = $data{$col}{input_size}{$type};
      $skip = 0 if $size;
    }
    push @rr, $type
      unless $skip;
  }
  join ', ', @rr
}

sub input_colors () {
  my %c = (
	   xml => '{red,fill=red!30!white,mark=none},',
	   json => '{olive,fill=olive!30!white,mark=none},',
	   csv => '{black,fill=black!30!white,mark=none},',
	  );
  my @rr;
  for my $type (qw(xml json csv)) {
    my $skip = 1;
    for my $col (nicel(1, @columns)) {
      my $size = $data{$col}{input_size}{$type};
      $skip = 0 if $size;
    }
    push @rr, $c{$type}
      unless $skip;
  }
  join '', @rr
}

sub cpu_scale () {
  my @r;
  for my $col (nicel(1, @columns)) {
    my $total_dur = sum $data{$col}{duration}->@*;
    my $total_cpu = sum $data{$col}{cpu_user_system_diff}->@*;
    my $scale = $total_cpu / $total_dur;
    my $nice = sprintf($scale < 10 ? "%.1f" : "%d", $scale);
    $nice =~ s/0+$// if $nice =~ /\./;
    $nice =~ s/\.$//;
    push @r, "\$\\times\$$nice";
  }
  join ', ', @r
}

sub triples_per_cent () {
  my $max = max map { $_->{triples} } @data{(nicel(1, @columns))};
  my $half = $log_scale ? int($max * .1) : int($max * .5);
  "$half, $max"
}

sub addplot_duration () {
  my @rr;
  my %sum;
  for (my $i = 0;; $i++) {
    my @r;
    my $defined = 0;
    for my $col (nicel(1, @columns)) {
      $sum{$col} //= 0;
      my $duration = $data{$col}{duration}[$i];
      if (defined $duration) {
	$defined = 1;
	$sum{$col} += $duration;
      }
      else { $duration = 'NaN'; }
      #push @r, "($duration,$col) [$sum{$col}]";
      push @r, "($duration,$col) [" . (int($sum{$col}/60) . ':' . sprintf("%02d", $sum{$col}%60)) . "]";
    }
    last unless $defined;
    push @rr, "\\addplot coordinates {
@r
};";
  }
#  $rr[-1] =~ s/\\addplot coordinates/\\addplot +[nodes near coords,point meta=explicit] coordinates/
  $rr[-1] =~ s/\\addplot coordinates/\\addplot +[nodes near coords,point meta=explicit symbolic,nodes near coords align={right}] coordinates/
    if @rr;
  "@rr"
}

my $template = load_template_file();
$m{y_coords} = join ', ', nicel(1, @columns);

my $label = nicel(0, "${prefix} ${suffix}");

my @steps = steps("${prefix} ${suffix}");
my $cycle_list;
my %cycle_map = cycle_map();
$cycle_list = join "\n", "%", @cycle_map{@steps};

$m{steps_cycle_list} = $cycle_list;

if ($label =~ /heterogeneity/i) {
  $m{hack_1} = '$\hspace{5em}$';
} else {
  $m{hack_1} = '';
}

my @memlegend = qw(mem);
if (0) {
  $m{mem_legend} = '';
  $m{steps_legend} = '';
} else {
  $m{mem_legend} = join ', ', @memlegend;
  $m{steps_legend} = join ', ', @steps;
}

$m{label} = $label;
if ($log_scale) {
  $m{log_scale} = "
xmode=log,";
  $m{log_scale_info} = ' (log-scale)';
  $m{log_calc} = '\pgfmathsetmacro\value{exp(\tick)}';
  $m{triples_log} = '(log)';
  $m{triples_per_cent_label} = '10\%, 100\%';
  $m{io_size_label_pos} = 'xticklabel cs:0.7';
  $m{xmin_duration} = 0.95;
  $m{xmin_size} = 1;
} else {
  $m{log_scale} = '';
  $m{log_scale_info} = '';
  $m{log_calc} = '\pgfmathsetmacro\value{\tick}';
  $m{triples_log} = '';
  $m{triples_per_cent_label} = '50\%, 100\%';
  $m{io_size_label_pos} = 'xticklabel cs:0.58,-.3\baselineskip';
  $m{xmin_duration} = 0;
  $m{xmin_size} = 0;
}

my $sh_fn = 'input_sizes.txt';
open my $sh, '<', $sh_fn or die "$sh_fn: $!";
my %sizes;
while (my $line = <$sh>) {
  chomp $line;
  next unless $line;
  my ($dir, $size, $type) = split ' ', $line;
  $sizes{$dir}{$type} = $size;
}

my $os_fn = 'triples_count.txt';
open my $os, '<', $os_fn or die "$os_fn: $!";
my %triples;
while (my $line = <$os>) {
  chomp $line;
  next unless $line;
  my ($tc, $dir) = split ' ', $line;
  $dir =~ s{/[^/]*[.]nt$}{};
  $triples{$dir} = $tc;
}

for my $xcol (@columns) {
  my $aoh = csv(in => "${prefix}${xcol}/results/summary.csv",
		headers => 'auto');
  my $col = nicel(1, $xcol);
  my $mem_max = max map { $_->{memory_ram_max} } $aoh->@*;
  my $duration = [ map { $_->{duration} } $aoh->@* ];
  my $cpu_user_system_diff = [ map { $_->{cpu_user_system_diff} } $aoh->@* ];
  $data{$col}{mem_max} = $mem_max;
  $data{$col}{duration} = $duration;
  $data{$col}{cpu_user_system_diff} = $cpu_user_system_diff;
  $data{$col}{triples} = $triples{"${prefix}${xcol}"} // warn "Missing output triples: ${prefix}${xcol}\n";
  $data{$col}{input_size} = $sizes{"${prefix}${xcol}"};
}

$m{max_memory} = addplot_mem_max();
$m{duration} = addplot_duration();
$m{triples} = addplot_triples();
$m{triples_per_cent} = triples_per_cent();
$m{input_sizes} = addplot_input_sizes();
$m{input_types} = input_types();
$m{input_colors} = input_colors();
$m{cpu_scale} = cpu_scale();
my $height_cm = @columns >= 4 ? (1.34286 + 0.635714 * @columns + 0.00714286 * @columns ** 2) : 4;
$m{height} = sprintf("%.1fcm", $height_cm);

# legend y mem
# 4 -0.2
# 4.7 -0.15
# 10 -0.07
$m{legend_y_mem} = sprintf("%.4f", 0.13066 * log(0.0597873 * $height_cm));

# legend y triples
# 4 -0.3525
# 4.7 -0.275
# 10 -0.13
$m{legend_y_triples} = sprintf("%.4f", 0.22697 * log(0.0573857 * $height_cm));

# enlarge y limits
# 4 0.2
# 10 0.065
$m{enlarge_y} = sprintf("%.2f", - $height_cm * 0.0225 + 0.29);

my $ms_fn = "$FindBin::Bin/mem_scale.inc";
open my $mc, '<', $ms_fn || die "$ms_fn: $!";
for my $line (<$mc>) {
  chomp $line;
  if ($line =~ /^xtick=/) { $m{mem_ticks} = "$line\n"; }
  elsif ($line =~ /^x(min|max)=/) { $m{mem_scale} = "$line\n"; }
  elsif ($line =~ /^enlarge x limits=/) { $m{mem_enlarge} = "$line\n"; }
}

print $template =~ s{ \@ ([0-9a-zA-Z-]*) \@ \n? }{
  my $key = lc $1;
  $key =~ y/-/_/;
  if (exists $m{$key}) { $m{$key} }
  else { warn "Unreplaced template parameter $&\n"; $& }
}gexr;
