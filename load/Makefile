DIR_BUCKET ?= ../../buckets/dl.ncsbe.gov
DIR_SNAPSHOTS ?= $(DIR_BUCKET)/data/Snapshots
INPUT_SNAPSHOTS ?= $(wildcard $(DIR_SNAPSHOTS)/*.zip)
TARGET_SNAPSHOTS ?= $(addprefix snapshots/, $(addsuffix .sqlite3,$(basename $(notdir $(INPUT_SNAPSHOTS)))))
# DIR_NCV ?= $(DIR_BUCKET)

all: .flag.snapshots
	echo $(DIR_BUCKET)
	echo $(DIR_SNAPSHOTS)

.flag.snapshots: $(TARGET_SNAPSHOTS)
	(echo New: $?; echo All: $^) > $@.tmp ; mv -v $@.tmp $@

snapshots/%.sqlite3: $(DIR_SNAPSHOTS)/%.zip snapshots
	loadit $@.tmp $< && mv $@.tmp $@

snapshots:
	mkdir -p $@

check:
	echo $(INPUT_SNAPSHOTS)
	echo $(TARGET_SNPASHOTS)
