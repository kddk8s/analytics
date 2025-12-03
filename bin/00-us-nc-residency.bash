#!/bin/bash
set -e -u -o pipefail
set -x
Main() {
	local bucketdir="$1" files=() snapshots=() db
	db="${0##*/}"
	db="${db%.*}.sqlite3"
	snapshots=("$bucketdir/data/Snapshots"/*.zip)
	files+=(
	"$bucketdir/data"/*Statewide.zip
	"${snapshots[-1]}"
	)
	loadit "$db" "${files[@]}"
	exit 0
}
Main "$@"; exit 1
