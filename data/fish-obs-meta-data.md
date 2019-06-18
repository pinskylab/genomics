fish-obs-meta-data
================
Michelle Stuart
6/18/2019

The fish\_obs.Rdata file is created in the [remove-regenos](pinskylab/genomics/scripts/05_remove-regenos.Rmd) script by
1. filtering the database for any sample\_id found in the current genepop file that contains all successfully sequenced individuals (no regenotypes or recaptures have been removed from this genepop). Only the columns of sample\_id, tag\_id, and fish\_table\_id are kept. 2. The database is queried again for any fish that has a tag\_id that was not included in the table above. Again the columns of sample\_id, tag\_id and fish\_table\_id are kept.
3. These 2 tables are bound into one table of all fish that have been successfully genotyped and/or pit-tagged, saved as an RData file, \[fish-obs.RData\]((pinskylab/genomics/data/fish-obs.RData)
