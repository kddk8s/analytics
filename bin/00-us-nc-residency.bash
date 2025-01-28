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
	if [ ! -e "$db" ]; then
		loadit "$db" "${files[@]}"
	fi
	local ncvoter="load.ncvoter_statewide_ncvoter_statewide"
	local summary="count(1) as total, sum(status_cd in ('A', 'S')) as active, sum (status_cd in ('D', 'I', 'R')) as inactive, sum(reason_cd in ('RF', 'RR') ) as felon, sum(reason_cd = 'RD') as deceased, sum(reason_cd = 'RQ') as requested"
	local residence="county_id, zip_code, state_cd, res_city_desc, res_street_address"
	Summarize "$db" "residence" "$residence" "$summary" "$ncvoter"

	local mail="mail_zipcode, mail_city, mail_addr4, mail_addr3, mail_addr2, mail_addr1"
	Summarize "$db" "mail" "$mail" "$summary" "$ncvoter"

	local demo="confidential_ind, race_code, ethnic_code, party_cd, gender_code, birth_year, birth_state, drivers_lic"
	Summarize "$db" "demo" "$demo" "$summary" "$ncvoter"

	local name="first_name, middle_name, last_name, name_suffix_lbl"
	Summarize "$db" "name" "$name" "$summary" "$ncvoter"

	local fedstate="county_id, cong_dist_abbrv, super_court_abbrv, judic_dist_abbrv, nc_senate_abbrv, nc_house_abbrv, dist_1_abbrv, dist_1_desc"
	Summarize "$db" "fedstate" "$fedstate" "$summary" "$ncvoter"

	local muni1="county_id, precinct_abbrv, precinct_desc, municipality_abbrv, municipality_desc, ward_abbrv, ward_desc, county_commiss_abbrv, county_commiss_desc, township_abbrv, township_desc, munic_dist_abbrv, munic_dist_desc"
	Summarize "$db" "muni1" "$muni1" "$summary" "$ncvoter"

	local muni2="county_id, precinct_abbrv, precinct_desc, school_dist_abbrv, school_dist_desc, fire_dist_abbrv, fire_dist_desc, water_dist_abbrv, water_dist_desc, sewer_dist_abbrv, sewer_dist_desc, rescue_dist_abbrv, rescue_dist_desc"
	Summarize "$db" "muni2" "$muni2" "$summary" "$ncvoter"

	local voter="ncid, county_id, voter_reg_num"
	Summarize "$db" "voter" "$voter" "$summary" "$ncvoter"

	exit 0
}
Summarize() {
	local db="$1" table="$2" group="$3" summary="$4" srctable="$5"
	sqlite3 "$db" "DROP TABLE IF EXISTS $table;
	CREATE TABLE $table AS
	SELECT $group, $summary FROM \"$srctable\" GROUP BY $group;"
}
Main "$@"; exit 1
