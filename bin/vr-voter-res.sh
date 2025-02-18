#!/bin/bash
set -e -u -o pipefail
set -x
zero=$(readlink -f "$0")
zerodir="${zero%/*}"
zerofile="${zero#$zerodir/}"
base_db="load-vr-snap-2"
Main(){
	if [ ! -r "$base_db.sqlite3" ]; then
		"$base_db.sh"
	fi
	: "${L_DB:=${zerofile%.*}.sqlite3}"
	export L_DB
	# cp -pv "$base_db.sqlite3" "$L_DB.tmp"
	local tables=() table
	readarray -t tables < <(sqlite3 "$L_DB.tmp" "select name FROM sqlite_master WHERE type='table';")

	for table in "${tables[@]}"; do
		GetDistinct "$table" voter "ncid, county_id, voter_reg_num"
	done
	exit 0
}
GetDistinct() {
	local src="$1"; shift
	local dest="$1"; shift
	local columns="$1"; shift
#	local columns_def="$1"; shift

	sqlite3 "$L_DB.tmp" "CREATE TABLE IF NOT EXISTS $dest ($columns, PRIMARY KEY ($columns) ON CONFLICT IGNORE);"
	sqlite3 "$L_DB.tmp" "INSERT INTO ${dest} SELECT DISTINCT $columns FROM $src;"

}
Main "$@"
