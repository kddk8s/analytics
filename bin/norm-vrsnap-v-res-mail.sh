#!/bin/bash
set -e -u -o pipefail
set -x
zero=$(readlink -f "$0")
zerodir="${zero%/*}"
zerofile="${zero#"$zerodir"/}"
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
	if [ -r "$db.dump" ]; then
		sqlite3 "$db" ".read '$db.dump'"
	fi
	Norm "$db" "l_vrsnap%"
	sqlite3 "$db" ".dump --preserve-rowids f_% fv_% n_%" > "$db.dump"
}

Norm() {
	local db="$1" table_pat="$2" table
	table=$(sqlite3 "$db" ".tables $table_pat")
	# f_* for what become foreign keys
	GetDistinct "$db" "$table" "f_snapshot" "snapshot_dt"
	GetDistinct "$db" "$table" "f_vid" "ncid, county_id, voter_reg_num"
	# Skips status_cd, voter_status_desc, reason_cd, voter_status_reason_desc
	GetDistinct "$db" "$table" "f_name" "last_name, first_name, midl_name, name_sufx_cd"
	# Just in case a residence changes counties
	GetDistinct "$db" "$table" "f_res" "county_id, house_num, half_code, street_dir, street_name, street_type_cd, street_sufx_cd, unit_num, res_city_desc, state_cd, zip_code"
	GetDistinct "$db" "$table" "f_mail" "mail_addr1, mail_addr2, mail_addr3, mail_addr4, mail_city, mail_state, mail_zipcode"
	# Misses everything starting at area_cd

}

GetDistinct() {
	local db="$1" src="$2" dst="$3" columns="$4"
	# Just keep adding unique stuff
	sqlite3 "$db" "CREATE TABLE IF NOT EXISTS $dst ($columns, PRIMARY KEY ($columns) ON CONFLICT IGNORE);"
	sqlite3 "$db" "INSERT INTO $dst SELECT DISTINCT $columns FROM $src;"
	# THis may be a good point to create the view
}

Main "$@"
# shellcheck disable=SC2317
exit 1
