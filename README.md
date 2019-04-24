ReadMe
================

\# This repository is under construction to become more organized and have a clearer workflow
---------------------------------------------------------------------------------------------

From fish to SNP, many steps are involved in obtaining and processing our data.
===============================================================================

-   Sample collection can be found in the [field](https://github.com/pinskylab/field) repository.
-   Sample processing through sequence submission can be found in the [laboratory](https://github.com/pinskylab/pinskylab_methods/tree/master/genomics/laboratory) repository.
-   Sequence processing through identity analysis (mark recapture) can be found here in the genomics repository.

    1.  [Receive and preapare sequences for SNP calling](https://github.com/pinskylab/pinskylab_methods/blob/master/genomics/analysis/00_hiseq_workflow.md)
    2.  [Call SNPs](https://github.com/pinskylab/pinskylab_methods/blob/master/genomics/analysis/01_callSNPs_template.md)
    3.  [Filter SNPs](https://github.com/pinskylab/genomics/blob/master/filtering/filtering_scheme-6-with-70-35.Rmd)
    4.  [Remove regenotyped individuals](https://github.com/pinskylab/genomics/blob/master/scripts/01_remove-regenos.Rmd)
    5.  [Identify recaptured individuals](https://github.com/pinskylab/genomics/blob/master/scripts/02_identity-protocol.Rmd)
    6.  [Update recaptured RData file](https://github.com/pinskylab/genomics/blob/master/scripts/03_recaptured-fish.Rmd)

Open this Rproject on the RStudio Server on amphiprion to use for steps 1-3 (i-iii).

Navigation
==========

Clownfish Movement
------------------

A manuscript in progress by Michelle.

Data
----

[nogenid.rds](https://github.com/pinskylab/genomics/blob/master/data/nogenid.rds) - data from Katrina flagging samples that appear in sequencing data but don't have a gen\_id.
[nogenid\_seq03-33.rds](https://github.com/pinskylab/genomics/blob/master/data/nogenid_seq03-33.rds)
[recaptured-fish.Rdata](https://github.com/pinskylab/genomics/blob/master/data/recaptured-fish.Rdata) - a table of recaptured fish including a recap\_id to connect gen\_id and tag\_id recaptured fish, generated based on data we had as of March 12, 2018.
[seq03-33\_identity](https://github.com/pinskylab/genomics/tree/master/data/seq03-33_identity) - a folder containing files used for the cervus identity analysis.

Plots
-----

[plot-clownfish-at-size-change-M-to-F.md](https://github.com/pinskylab/genomics/blob/master/plots/plot-clownfish-at-size-change-from-M-to-F.md) - graphic output version of the code to produce plots.
[plot-clownfish-at-size-change-M-to-F.Rmd](https://github.com/pinskylab/genomics/blob/master/plots/plot-clownfish-at-size-change-from-M-to-F.Rmd) - notebook to produce size distrubtion plots.
[plot-clownfish-at-size-change-M-to-F\_figures](https://github.com/pinskylab/genomics/tree/master/plots/plot-clownfish-at-size-change-from-M-to-F_files/figure-markdown_github) - folder holding png images of the size distribution plots.
[where\_caught.pdf](https://github.com/pinskylab/genomics/blob/master/plots/where_caught.pdf) - a pdf of a plot of the number of fish captured on the same anemone or different anemones from the original capture.

Scripts
-------

Tons and tons of scripts to do analysis on genomic data.
