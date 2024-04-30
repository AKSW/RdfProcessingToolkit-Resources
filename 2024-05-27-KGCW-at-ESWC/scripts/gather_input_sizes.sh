#!/bin/bash

set -eu
set -o pipefail

current_dir="$(pwd)"
if [[ $# -ge 1 ]]; then
    cd "$1"
fi

shopt -s globstar

for shared_dir in **/data/shared/; do
    base_folder="${shared_dir%/data/shared/}"
    if [[ "$base_folder" = "**" ]]; then
	echo No data folder found >&2
	exit 1
    fi
    for file_type in xml json csv; do
	disk_usage="$(du -c "$base_folder"/**/*."$file_type" 2>/dev/null || echo 0)"
	size="$( echo "$disk_usage" | tail -1 | sed 's,total,,' )"
	echo "$base_folder" $size "$file_type"
    done
done
