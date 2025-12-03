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

all: .flag.ncv .flag.snapshots .flag.candidates
	echo $(DIR_BUCKET)
	echo $(DIR_NCV)
	echo $(DIR_SNAPSHOTS)
	echo $(DIR_CANDIDATES)

.flag.snapshots: $(TARGET_SNAPSHOTS)
	(echo New: $?; echo All: $^) > $@.tmp ; mv -v $@.tmp $@

.flag.ncv: $(TARGET_NCV) ncv/party.sqlite3
	(echo New: $?: echo All: $^) > $@.tmp; mv -v $@.tmp $@

.flag.candidates: .flag.icandidates $(TARGET_CANDIDATES)
	(echo New: $?: echo All: $^) > $@.tmp; mv -v $@.tmp $@

snapshots/%.sqlite3: $(DIR_SNAPSHOTS)/%.zip
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

ncv/%.sqlite3: $(DIR_NCV)/%.zip
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

ncv/party.sqlite3: ncv/ncvoter_Statewide.sqlite3 ncv/ncvhis_Statewide.sqlite3
	party $@ $^

candidates/%.sqlite3: icandidates/%.csv
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

.flag.icandidates:
	mkdir -p icandidates
	ln --symbolic --no-dereference --force --verbose --relative --target-directory=icandidates $(DIR_CANDIDATES)/*/*/*.csv


check:
	echo $(INPUT_SNAPSHOTS)
	echo $(TARGET_SNAPSHOTS)
	echo $(INPUT_NCV)
	echo $(TARGET_NCV)
	echo $(INPUT_CANDIDATES)
	echo $(TARGET_CANDIDATES)
