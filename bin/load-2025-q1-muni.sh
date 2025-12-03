#!/bin/bash
set -e -u -o pipefail
set -x
zero=$(readlink -f "$0")
zerodir="${zero%/*}"
zerofile="${zero#$zerodir/}"
Main(){
	local bucketdir="${BUCKET_DIR:-${zerodir}/../../buckets}"
	local files=(
	# Want current voters
	"${bucketdir}/dl.ncsbe.gov/data/ncvoter_Statewide.zip"
	# Want voter history
	"${bucketdir}/dl.ncsbe.gov/data/ncvhis_Statewide.zip"
	# Want the last presidential (Which is also congressional)
	"${bucketdir}/dl.ncsbe.gov/data/Snapshots/VR_Snapshot_20241105.zip"
	# Want part of the vipVeed from same (For streets)
	"${bucketdir}/dl.ncsbe.gov/data/vipFeed/vipFeed-37-2024-11-05.zip"
	"${bucketdir}/dl.ncsbe.gov/Elections"/*/"Candidate Filing"/*.csv
	)
	: "${MUNI_DB:=${zerofile%.*}.sqlite3}"
	rm -f "${MUNI_DB}.tmp" || :
	loadit "${MUNI_DB}.tmp" "${files[@]}"
	mv -v "${MUNI_DB}.tmp" "${MUNI_DB}"
	exit 0
}
Main "$@"
