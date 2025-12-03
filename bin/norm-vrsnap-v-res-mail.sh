#!/bin/bash
set -e -u -o pipefail
set -x
zero=$(readlink -f "$0")
zerodir="${zero%/*}"
zerofile="${zero#$zerodir/}"
zerobase="${zerofile%.*}"
# Limit to two files for initial testing
limit=2
: "${L_DB:=${zerobase}.sqlite3}"
Main(){
	local bucketdir="${BUCKET_DIR:-${zerodir}/../../buckets}"
	local files=() file lfiles=()
	readarray -t files < <(GetFiles "$bucketdir")
	if [ -n "$limit" ]; then
		lfiles=( "${files[@]:0:$limit}" )
	else
		lfiles=( "${files[@]}" )
	fi
	for file in "${lfiles[@]}"; do
		Process "${L_DB}" "$file"
	done
	exit 0
}

GetFiles() {
	find "$1"/dl.ncsbe.gov/data/Snapshots -name \*.zip |
		sort -r
}

Process() {
	local db="$1-load.sqlite3" file="$2"
	rm -vf "$db" || :
	loadit "$db" "$file"
}

Main "$@"
exit 1
