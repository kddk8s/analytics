#!/bin/bash
set -e -u -o pipefail
set -x
zero=$(readlink -f "$0")
zerodir="${zero%/*}"
zerofile="${zero#$zerodir/}"
Main(){
	local bucketdir="${BUCKET_DIR:-${zerodir}/../../buckets}"
	local files=()
	readarray -t files < <(find "${bucketdir}/dl.ncsbe.gov/data/Snapshots" -name VR_Snapshot\*.zip | sort | head -2)
	: "${L_DB:=${zerofile%.*}.sqlite3}"
	rm -f "${L_DB}.tmp" || :
	loadit "${L_DB}.tmp" "${files[@]}"
	mv -v "${L_DB}.tmp" "${L_DB}"
	exit 0
}
Main "$@"
