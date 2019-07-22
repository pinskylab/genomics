Genomics in the Pinsky Lab
================

From fish to SNPs, many steps are involved in obtaining and processing our data.
--------------------------------------------------------------------------------




-   Sample collection can be found in the [field](https://github.com/pinskylab/field) repository.
-   Sample processing through sequence submission can be found in the [laboratory](https://github.com/pinskylab/pinskylab_methods/tree/master/genomics/laboratory) repository.
-   Sequence processing through identity analysis (mark recapture) can be found here in the genomics repository.

    1.  [Receive and preapare sequences for SNP calling](https://github.com/pinskylab/genomics/blob/master/scripts/01_hiseq_workflow.md)
    2.  [Call SNPs](https://github.com/pinskylab/genomics/blob/master/scripts/02_callSNPs_template.md)
    3.  [Plot the raw SNPs to visualize the data](https://github.com/pinskylab/genomics/blob/master/scripts/03_raw_data_figures_template.md)
    4.  [Filter SNPs](https://github.com/pinskylab/genomics/blob/master/scripts/03_filtering_scheme-6-with-70-35.md)
    5.  [Remove regenotyped individuals](https://github.com/pinskylab/genomics/blob/master/scripts/04_remove-regenos.Rmd)
    6.  [Identify recaptured individuals](https://github.com/pinskylab/genomics/blob/master/scripts/05_identity-protocol.Rmd)
    7.  [Update recaptured RData file](https://github.com/pinskylab/genomics/blob/master/scripts/06_recaptured-fish.Rmd)

Open this Rproject on the RStudio Server on amphiprion to use for steps 1-4 (i-iv).

### Navigation

#### Pubs

A manuscript in progress by Michelle.

#### Data

Data files required to run the scripts.

Plots
-----

[plot-clownfish-at-size-change-M-to-F.md](https://github.com/pinskylab/genomics/blob/master/plots/plot-clownfish-at-size-change-from-M-to-F.md) - graphic output version of the code to produce plots.
[plot-clownfish-at-size-change-M-to-F.Rmd](https://github.com/pinskylab/genomics/blob/master/plots/plot-clownfish-at-size-change-from-M-to-F.Rmd) - notebook to produce size distribution plots.
[plot-clownfish-at-size-change-M-to-F\_figures](https://github.com/pinskylab/genomics/tree/master/plots/plot-clownfish-at-size-change-from-M-to-F_files/figure-markdown_github) - folder holding png images of the size distribution plots.
[where\_caught.pdf](https://github.com/pinskylab/genomics/blob/master/plots/where_caught.pdf) - a pdf of a plot of the number of fish captured on the same anemone or different anemones from the original capture.

Scripts
-------

The scripts listed in the steps above plus more specialized scripts in the [old scripts](https://github.com/pinskylab/genomics/tree/master/scripts/old_scripts) folder.
