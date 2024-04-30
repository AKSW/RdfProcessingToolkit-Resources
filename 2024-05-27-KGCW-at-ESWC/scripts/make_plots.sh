#!/bin/bash

## Script to create plots from the output of the "ESWC KGC Challenge 2024"

set -eu

script_root="$(dirname "$(readlink -f "$0")")"
plot() {
    perl "$script_root/plot_scenario.pl" "$@"
}
O="$script_root"

cd "$O/../data"

plot track2/gtfs-madrid-bench/heterogeneity_:tabular,mixed,files,nested \
     sl > "$O"/gtfs-heterogeneity.tex

plot track2/gtfs-madrid-bench/scale_:1,10,100,1000 \
     log > "$O"/gtfs-scale.tex

plot track2/gtfs-madrid-bench/scale_:1,10,100,1000 \
     > "$O"/gtfs-scale-no-log.tex

plot track2/empty-values/:0percent,25percent,50percent,75percent,100percent \
     > "$O"/empty-values.tex

plot track2/duplicated-values/:0percent,25percent,50percent,75percent,100percent \
     sl > "$O"/duplicated-values.tex

plot track2/records/:10K_rows,100K_rows,1M_rows,10M_rows:_20_columns \
     log,sl > "$O"/records.tex

plot track2/records/:10K_rows,100K_rows,1M_rows,10M_rows:_20_columns \
     sl > "$O"/records-no-log.tex

plot track2/properties/1M_rows_:1_columns,10_columns,20_columns,30_columns \
     > "$O"/properties.tex

plot track2/mappings/mapping_:1tm_15pom,3tm_5pom,5tm_3pom,15tm_1pom \
     sl > "$O"/mappings.tex

plot track2/joins/join_1-1/join_1-1_:0percent,25percent,50percent,75percent,100percent \
     sl > "$O"/joins-1-1.tex

plot track2/joins/join_1-N/join_:1-5_50percent,1-10_50percent,1-15_50percent,1-20_50percent \
     > "$O"/joins-1-N-50.tex

plot track2/joins/join_1-N/join_1-10_:0percent,25percent,50percent,75percent,100percent \
     sl > "$O"/joins-1-10.tex

plot track2/joins/join_N-1/join_:5-1_50percent,10-1_50percent,15-1_50percent,20-1_50percent \
     sl > "$O"/joins-N-1-50.tex

plot track2/joins/join_N-1/join_10-1_:0percent,25percent,50percent,75percent,100percent \
     > "$O"/joins-10-1.tex

plot track2/joins/join_N-M/join_:5-5_25percent,5-5_50percent,5-5_75percent,5-5_100percent,5-10_25percent,5-10_50percent,5-10_75percent,5-10_100percent,10-5_25percent,10-5_50percent,10-5_75percent,10-5_100percent \
     > "$O"/join-N-M.tex

plot track2/joins/join_N-M/join_5-5_:25percent,50percent,75percent,100percent \
     > "$O"/join-5-5.tex
