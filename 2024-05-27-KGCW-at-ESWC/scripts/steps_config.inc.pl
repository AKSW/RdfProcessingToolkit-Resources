#! perl
use v5.36;


## Define the steps that your tool uses, possibly based on the current
## file name (task)
sub steps ($task) {
  if ($task =~ /gtfs/i) {
    qw( fix xml  sparql opt. map~step )

  } elsif ($task =~ /empty/i) {

    qw( fix null sparql opt. map~step )

  } else {

    qw( fix      sparql opt. map~step)

  }
}


## Define the map between step name and TikZ area config
sub cycle_map {
  "fix"	     => '{blue,fill=blue!30!white,mark=none},',
  "null"     => '{magenta,fill=magenta!30!white,mark=none},',
  "xml"	     => '{red,fill=red!30!white,mark=none},',
  "sparql"   => '{brown!60!black,fill=brown!30!white,mark=none},',
  "opt."     => '{black,fill=gray!30!white,mark=none},',
  "map~step" => '{black,fill=white,mark=none},',
}


## End of file marker for Perl
1;
