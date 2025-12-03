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
	# Ideally we want all general elections on or before last
	# date in ncvhis.  This works for now.
	"${snapshots[-1]}"
	)
	if [ ! -e "$db" ]; then
		loadit "$db" "${files[@]}"
	fi
	# Reused patterns should go to a library...
	# That would suggest a rewrite in python
	local table="elections"
	sqlite3 "$db" "
	DROP TABLE IF EXISTS $table
	;
	CREATE TABLE $table AS
	SELECT
	  1 * substr(election_lbl, 7, 4) as year
	, 1 * substr(election_lbl, 1, 2) as month
	, 1 * substr(election_lbl, 4, 2) as day
	, election_lbl
	, election_desc
	, count(1) as voted
	FROM \"load.ncvhis_statewide_ncvhis_statewide\"
	GROUP BY election_lbl, election_desc
	;
	SELECT '$table', count(1) FROM $table
	;
	"
	table="pres_voters_1"
	sqlite3 "$db" "
	DROP TABLE IF EXISTS $table
	;
	CREATE TABLE $table AS
	SELECT
	  election_desc
	, ncid
	, county_id
	, voter_reg_num
	, count(1) as votes
	, 1 * substr(election_lbl, 7, 4) AS year
	FROM \"load.ncvhis_statewide_ncvhis_statewide\"
	WHERE election_desc IN (SELECT election_desc FROM elections WHERE (year % 4 = 0) AND election_desc LIKE '%GENERAL%')
	GROUP BY
	  election_desc
	, ncid
	, county_id
	, voter_reg_num
	;
	SELECT '$table', count(1) FROM $table
	;
	"
	table="pres_voters_2"
	sqlite3 "$db" "
	DROP TABLE IF EXISTS $table
	;
	CREATE TABLE $table AS
	SELECT
	  election_desc
	, ncid
	, sum(votes) as votes
	, year
	FROM pres_voters_1
	GROUP BY
	  election_desc
	, ncid
	;
	SELECT '$table', count(1) FROM $table
	;
	"
	table="voted_general_2024"
	sqlite3 "$db" "
	DROP TABLE IF EXISTS $table
	;
	CREATE TABLE $table AS
	SELECT
	  *
	FROM \"load.ncvoter_statewide_ncvoter_statewide\"
	WHERE ncid IN (SELECT DISTINCT ncid FROM pres_voters_2 WHERE year = 2024)
	;
	SELECT '$table', count(1) FROM $table
	;
	"
	table="voted_general_2024_not_2020"
	sqlite3 "$db" "
	DROP TABLE IF EXISTS $table
	;
	CREATE TABLE $table AS
	SELECT
	  *
	FROM voted_general_2024
	WHERE ncid NOT IN (SELECT DISTINCT ncid FROM pres_voters_2 WHERE year = 2020)
	;
	SELECT '$table', count(1) FROM $table
	;
	"
	
	exit 0
}
Main "$@"; exit 1
