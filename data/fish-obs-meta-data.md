fish-obs-meta-data
================
Michelle Stuart
6/18/2019

Creation
========

The fish\_obs.Rdata file is created in the [remove-regenos](pinskylab/genomics/scripts/05_remove-regenos.Rmd) script by
1. filtering the database for any sample\_id found in the current genepop file that contains all successfully sequenced individuals (no regenotypes or recaptures have been removed from this genepop). Only the columns of sample\_id, tag\_id, and fish\_table\_id are kept. 2. The database is queried again for any fish that has a tag\_id that was not included in the table above. Again the columns of sample\_id, tag\_id and fish\_table\_id are kept.
3. These 2 tables are bound into one table of all fish that have been successfully genotyped and/or pit-tagged, saved as an RData file, [fish-obs.RData](pinskylab/genomics/data/fish-obs.RData)

Account for recaptures
======================

During the [identity-protocol](pinskylab/genomics/scripts/06_identity-protocol.Rmd), the fish-obs.RData file is read in and gen\_ids are compared to determine if a pair of fish was previously determined to be a recapture. The gen\_id is changed so that recaptured fish share the same gen\_id. No fish are removed during this process.

Connect all observations of a fish
==================================

The [recaptured-fish](pinskylab/genomics/scripts/07_recaptured-fish.Rmd) script finds all capture events for all fish and assigns a fish\_indiv\_id to each fish. For example, if a fish were captured for tissue samples 3 times and had 2 different pit tags, all of those rows would have the same fish\_indiv number to connect them. No fish are removed during this process.

Columns found in the table
==========================

-   **fish\_table\_id** - *numeric* - the unique identifier of a fish observation event from the clownfish table of the Leyte database.
-   **sample\_id** - *character* - the unique identifier of the tissue sample collected from the fish. Format is species year underscore fin\_id, for example "APCL17\_494" where the species is APCL, the year collected was 2017, and the fin\_id was 494.
-   **tag\_id** - *character* - the pit tag assigned to this fish. This must remain a character in order to prevent R from converting it to scientific notiation and losing the end digits.
-   **gen\_id** - *numeric* - an identifier assigned when a fish has been genotyped successfully. Fish lacking a gen\_id may have a tissue sample but that tissue sample has not been successfully genotyped. Fish that have the same gen\_id are a genetic recapture, tissue samples have the same genotype.
-   **fish\_indiv** - *numeric* - an identifier assigned to a fish that has been observed. Repeat observations of the same fish will carry the same fish\_indiv number, whether they are genetic or pit tag observations.
