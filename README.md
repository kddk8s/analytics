# Various analytics

Various analytics for dirty CSV data

This README is currently geared towards folks that know how to use

* The Linux Command Line
* Sqlite3 flavored SQL
* git

## load/Makefile

A GNUMakefile for turning an S3 mirror of dl.ncsbe.gov into sqlite3 databases

### Usage

**MUST BE RUN FROM 'load' directory**

```
make
```

*OR*

```
DIR_BUCKET=/path/to/bucket/mirror make
```

This will create a set of sqlite3 files in subdirectories of load

### Dependencies

* Have a local mirror of s3:dl.ncsbe.gov/data
  * Preferred location is '../../buckets/dl.ncsbe.gov' relative to the load directory
  * Use 'awscli s3 sync' if not tracking change history
  * Use [s3-archive](https://github.com/k8e811/s3-archive) if tracking change history
* Have [k8e-dirty](https://github.com/k8e811/k8e-dirty) cloned and in your path
* Linux Package Dependencies
  * bash
  * sqlite3
  * GNU Make
  * awk
  * iconv
  * coreutils
  * unzip
  * awscli version 2

### Using 'awscli' to manually mirror

Assuming 'BUCKET\_DIR' is set

```
mkdir -p $BUCKET_DIR
aws s3 sync --no=-sign-request --only-show-errors --no-progress --delete --exact-timestamps dl.ncsbe.gov $BUCKET_DIR 2>&1 sync.log
```

