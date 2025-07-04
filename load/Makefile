DIR_BUCKET ?= ../../buckets/dl.ncsbe.gov
DIR_SNAPSHOTS ?= $(DIR_BUCKET)/data/Snapshots
INPUT_SNAPSHOTS = $(wildcard $(DIR_SNAPSHOTS)/*.zip)
TARGET_SNAPSHOTS = $(addprefix snapshots/, $(addsuffix .sqlite3, $(basename $(notdir $(INPUT_SNAPSHOTS)))))
DIR_NCV ?= $(DIR_BUCKET)/data
INPUT_NCV = $(wildcard $(DIR_NCV)/*Statewide.zip)
TARGET_NCV = $(addprefix ncv/, $(addsuffix .sqlite3, $(basename $(notdir $(INPUT_NCV)))))

all: .flag.ncv .flag.snapshots
	echo $(DIR_BUCKET)
	echo $(DIR_SNAPSHOTS)

.flag.snapshots: $(TARGET_SNAPSHOTS)
	(echo New: $?; echo All: $^) > $@.tmp ; mv -v $@.tmp $@

.flag.ncv: $(TARGET_NCV)
	(echo New: $?: echo All: $^) > $@.tmp; mv -v $@.tmp $@

snapshots/%.sqlite3: $(DIR_SNAPSHOTS)/%.zip
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

ncv/%.sqlite3: $(DIR_NCV)/%.zip
	mkdir -p $(@D)
	loadit $@.tmp $< && mv $@.tmp $@

ncv/ncvpref.sqlite3	: ncv/ncvhist.sqlite3
	preferences "$@" "$<"

check:
	echo $(INPUT_SNAPSHOTS)
	echo $(TARGET_SNAPSHOTS)
	echo $(INPUT_NCV)
	echo $(TARGET_NCV)
