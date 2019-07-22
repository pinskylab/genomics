Find out why fish are in seq17 but not seq33
================

There were 157 ligation/gen\_ids that were in seq 17 but not in seq 33. We think that these samples were dropped during the population level filtering of seq33 data.

Are any of these 157 ligation ids in both genepops?

157 in the seq17 genepop
11 in the seq33 genepop

Fish that were in one genepop but not the next might have been dropped based on the shifting structure of the population genotypes with the addition of more individuals.

Double check that the 11 that are in 33 have gen\_ids.

    ## Warning in kableExtra::kable_styling(.): Please specify format in kable.
    ## kableExtra can customize either HTML or LaTeX outputs. See https://
    ## haozhu233.github.io/kableExtra/ for details.

| ligation\_id | sample\_id     |  gen\_id| fish\_notes    | fish\_correction |
|:-------------|:---------------|--------:|:---------------|:-----------------|
| L2539        | APCL14\_427    |     1093| NA             | NA               |
| L0785        | APCL14\_190    |      890| NA             | NA               |
| L0752        | APCL14\_133    |      840| NA             | NA               |
| L0803        | APCL14\_417    |     1083| LARGEST HIDDEN | NA               |
| L2399        | APCL14\_332    |     1019| NA             | NA               |
| L1730        | APCL14\_399    |     1065| NA             | NA               |
| L0687        | APCL14\_009    |      748| NA             | NA               |
| L2441        | APCL14\_252    |      945| NA             | NA               |
| L0874        | APCL13\_572    |      654| NA             | NA               |
| L2453        | APCL14\_405    |     1071| NA             | NA               |
| L2338        | APCL15\_403075 |     1534| NA             | NA               |

It looks like out of these fish in question, some did not pass genotype filters applied either during SNP calling by freebayes or during the filtering process. The remaining 11 are in both genepops and have gen\_ids.
