Genomics in the Pinsky Lab
================

## From fish to SNPs, many steps are involved in obtaining and processing our data.

  - Sample collection can be found in the
    [field](https://github.com/pinskylab/field) repository.  

  - Sample processing through sequence submission can be found in the
    [laboratory](https://github.com/pinskylab/pinskylab_methods/tree/master/genomics/laboratory)
    repository.  

  - Sequence processing through identity analysis (mark recapture) can
    be found here in the genomics repository.
    
    1.  [Receive and prepare sequences for SNP
        calling](Rmd/01_hiseq_workflow.md)
    2.  [Call SNPs](Rmd/01_hiseq_workflow.md)
    3.  [Plot the raw SNPs to visualize the
        data](Rmd/03_raw_data_figures_template.md)
    4.  [Filter SNPs](Rmd/04_filtering_scheme-6-with-70-35.md)
    5.  [Remove regenotyped individuals](Rmd/05_remove-regenos.md)
    6.  [Identify recaptured individuals](Rmd/06_identity-protocol.md)
    7.  [Update recaptured RData file](Rmd/07_recaptured-fish.md)

Open this Rproject on the RStudio Server on amphiprion to use for steps
1-4 (i-iv).  
Our reference.fasta file was assembled by Jon Puritz using dDocent and
300 individuals from our APCL sample set.

### Navigation

#### Protocols 
Step by step guides to processing sequencing data.  Make a copy of these files and update that copy with the specifics you encountered during your analysis to serve as a lab notebook.  The protocols listed in the steps above. If vieiwng on github, the .md files are the easiest way to view these files. If you want to run the scripts, open the .Rmd files through RStudio or render them with regular R by typing into the R command line:

``` r
rmarkdown::render("file_name.Rmd")
```

#### R
Old scripts that are no longer used but may be helpful for problem solving.

#### data

Data files required to run the scripts. 

#### filtering

Scripts for filtering vcf files.

#### lab-notebooks

Records of how sample runs were processed. A copy of the protocol step was saved into this folder and renamed to represent the samples that were being worked on. These are best viewed as html files.

#### manuals

Manufacturer manuals and guides.

## plots

[plot-clownfish-at-size-change-M-to-F.md](https://github.com/pinskylab/genomics/blob/master/plots/plot-clownfish-at-size-change-from-M-to-F.md)
- graphic output version of the code to produce plots.  
[plot-clownfish-at-size-change-M-to-F.Rmd](https://github.com/pinskylab/genomics/blob/master/plots/plot-clownfish-at-size-change-from-M-to-F.Rmd)
- notebook to produce size distrubtion plots.  
[plot-clownfish-at-size-change-M-to-F\_figures](https://github.com/pinskylab/genomics/tree/master/plots/plot-clownfish-at-size-change-from-M-to-F_files/figure-markdown_github)
- folder holding png images of the size distribution plots.  
[where\_caught.pdf](https://github.com/pinskylab/genomics/blob/master/plots/where_caught.pdf)
- a pdf of a plot of the number of fish captured on the same anemone or
different anemones from the original capture.


