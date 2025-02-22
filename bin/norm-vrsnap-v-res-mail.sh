#!/bin/bash
set -e -u -o pipefail
set -x
zero=$(readlink -f "$0")
zerodir="${zero%/*}"
zerofile="${zero#"$zerodir"/}"
zerobase="${zerofile%.*}"
# Limit to two files for initial testing
limit=''
: "${L_DB:=${zerobase}.sqlite3}"
#export DMC_RECORDS=10000
Main(){
	local bucketdir="${BUCKET_DIR:-${zerodir}/../../buckets}"
	local files=() file lfiles=()
	readarray -t files < <(GetFiles "$bucketdir")
	if [ -n "$limit" ]; then
		lfiles=( "${files[@]:0:$limit}" )
	else
		lfiles=( "${files[@]}" )
	fi
	rm -f "${L_DB}.dump"
	for file in "${lfiles[@]}"; do
		Process "${L_DB}" "$file"
	done
	exit 0
}

GetFiles() {
	find "$1"/dl.ncsbe.gov/data/Snapshots -name \*.zip |
		sort
}

Process() {
	local db="$1-load.sqlite3" file="$2"
	rm -vf "$db" || :
	loadit "$db" "$file"
	if [ -r "$db.dump" ]; then
		sqlite3 "$db" ".read '$db.dump'"
	fi
	Norm "$db" "l_vrsnap%"
	sqlite3 "$db" ".dump --preserve-rowids f_% vn_% n_%" > "$db.dump"
}

Norm() {
	local db="$1" table_pat="$2" src
	src=$(sqlite3 "$db" ".tables $table_pat")
	# f_* for what become foreign keys
	GetDistinct "$db" "$src" "f_1snapshot" "snapshot_dt"
	GetDistinct "$db" "$src" "f_0vid" "ncid, county_id, voter_reg_num"
	# Skips status_cd, voter_status_desc, reason_cd, voter_status_reason_desc
	GetDistinct "$db" "$src" "f_name" "last_name, first_name, midl_name, name_sufx_cd"
	# Just in case a residence changes counties
	GetDistinct "$db" "$src" "f_res" "county_id, house_num, half_code, street_dir, street_name, street_type_cd, street_sufx_cd, unit_num, res_city_desc, state_cd, zip_code"
	GetDistinct "$db" "$src" "f_mail" "mail_addr1, mail_addr2, mail_addr3, mail_addr4, mail_city, mail_state, mail_zipcode"
	# Misses everything starting at area_cd
	NormJoin "$db" n_vr_id_res_mail "$src" "vn_"
}

GetDistinct() {
	local db="$1" src="$2" dst="$3" columns="$4"
	# Just keep adding unique stuff
	sqlite3 "$db" "CREATE TABLE IF NOT EXISTS $dst ($columns, PRIMARY KEY ($columns) ON CONFLICT IGNORE);"
	# This is an ugly hack that keeps us from juggling an extra index column and lots of AS statements
	sqlite3 "$db" "CREATE VIEW IF NOT EXISTS vn_$dst AS select rowid AS id_$dst, * FROM $dst;"
	sqlite3 "$db" "INSERT INTO $dst SELECT DISTINCT $columns FROM $src;"
}

NormJoin() {
	local db="$1" table="$2" src="$3" pattern="$4" tables=() columns=()
	read -r -a tables < <(sqlite3 "$db" ".tables ${pattern}%")
	readarray -t columns < <(Part2Column "$pattern" "${tables[@]}")
	select_cols=$(Join ", " "${columns[@]}")
	sqljoin=$(Join " NATURAL JOIN " "$src" "${tables[@]}")
	sqlite3 "$db" "CREATE TABLE IF NOT EXISTS "$table" ($select_cols, PRIMARY KEY ($select_cols) ON CONFLICT IGNORE);"
	sqlite3 "$db" "INSERT INTO $table SELECT ${select_cols} FROM ${sqljoin};"
}

Part2Column() {
	local pat="$1" part
	shift
	for part in "${@}"; do
		echo "id_${part#"${pat}"}"
	done
}

Join() {
	local con="$1"; shift
	local joined="$1" part; shift
	for part in "$@"; do
		joined="${joined}${con}${part}"
	done
	echo "$joined"
}

# Check if sourced https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
if ! (return 0 2>/dev/null); then
	Main "$@"
	# NormJoin "$@"
	# shellcheck disable=SC2317
	exit 1
fi
