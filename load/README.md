# Tools For Zip -> SQLite3 Database Loads

Loads are expensive.  Most loads need to only be performed when the input file changes.
We also have corner cases of additional ones left by data requests.

## Ideas

* One sqlite database per load
* Use existing loadit for this
* Use a Makefile
