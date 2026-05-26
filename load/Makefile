DIR_BUCKET ?= ../../buckets/dl.ncsbe.gov
DIR_SNAPSHOTS ?= $(DIR_BUCKET)/data/Snapshots
INPUT_SNAPSHOTS = $(wildcard $(DIR_SNAPSHOTS)/*.zip)
TARGET_SNAPSHOTS = $(addprefix snapshots/, $(addsuffix .sqlite3, $(basename $(notdir $(INPUT_SNAPSHOTS)))))
DIR_NCV ?= $(DIR_BUCKET)/data
INPUT_NCV = $(wildcard $(DIR_NCV)/*Statewide.zip)
TARGET_NCV = $(addprefix ncv/, $(addsuffix .sqlite3, $(basename $(notdir $(INPUT_NCV)))))
DIR_CANDIDATES ?= $(DIR_BUCKET)/Elections
INPUT_CANDIDATES = $(wildcard icandidates/*.csv)
# $(wildcard $(DIR_CANDIDATES)/*/*/*.csv)
TARGET_CANDIDATES = $(addprefix candidates/, $(addsuffix .sqlite3, $(basename $(notdir $(INPUT_CANDIDATES)))))
SHELL = bash

all: .flag.ncv .flag.snapshots .flag.candidates
	echo $(DIR_BUCKET)
	echo $(DIR_NCV)
	echo $(DIR_SNAPSHOTS)
	echo $(DIR_CANDIDATES)

.flag.snapshots: $(TARGET_SNAPSHOTS)
	(echo New: $?; echo All: $^) > $@.tmp ; mv -v $@.tmp $@

.flag.ncv: $(TARGET_NCV)
	(echo New: $?: echo All: $^) > $@.tmp; mv -v $@.tmp $@

.flag.candidates: .flag.icandidates $(TARGET_CANDIDATES)
	(echo New: $?: echo All: $^) > $@.tmp; mv -v $@.tmp $@

snapshots/%.sqlite3: $(DIR_SNAPSHOTS)/%.zip
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

ncv/%.sqlite3: $(DIR_NCV)/%.zip
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

candidates/%.sqlite3: icandidates/%.csv
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

.flag.icandidates:
	rm -rf icandidates
	mkdir -p icandidates
	# Typically this is bad practice but these files are small
	set -x ; for d in $(DIR_CANDIDATES)/*/*/*.csv; do e="$${d##*/}"; cp -p "$$d" "icandidates/$${e,,}"; done

check:
	echo $(INPUT_SNAPSHOTS)
	echo $(TARGET_SNAPSHOTS)
	echo $(INPUT_NCV)
	echo $(TARGET_NCV)
	echo $(INPUT_CANDIDATES)
	echo $(TARGET_CANDIDATES)
