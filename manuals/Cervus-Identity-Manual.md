Cervus Identity Manual
================

-   [Identity analysis - overview](#identity-analysis---overview)
-   [How to run an identity analysis](#how-to-run-an-identity-analysis)
-   [Identity analysis output](#identity-analysis-output)
-   [Identity analysis data file](#identity-analysis-data-file)
-   [Individual probability of identity](#individual-probability-of-identity)
-   [Average non-exclusion probabilities](#average-non-exclusion-probabilities)

#### Identity analysis - overview

Purpose

Identity analysis is used to find matching genotypes in a genotype file. This analysis is particularly useful in parentage studies where individuals can be inadvertently resampled (for example where DNA is extracted from shed tissue).

Identity analysis is also useful independent of parentage analysis when identification of previously sampled individuals is of interest. For example identity analysis can be used at the individual level to investigate poaching from a sampled population, or at the population level to estimate population size from the proportion of individuals previously sampled.

Overview

The identity check analysis reads genotypes from a text file and compares each row of genotype data against every other row in the file. Cervus records any IDs that occur more than once in the file, and separately records any genotypes that occur more than once. Cervus offers a fuzzy matching function, so you can look for genotypes that match at all except one locus, for example, as well as perfect matches. Cervus can also restrict the search to individuals of the same sex.

For exact matches Cervus calculates the individual probabilities of identity and sib identity. To do these calculations Cervus needs allele frequencies, so unless you have your own allele frequency file it is necessary to run a Cervus allele frequency analysis before running an identity analysis.

#### How to run an identity analysis

1.  Choose Identity Analysis... from the Analysis menu.

2.  Select a genotype file by clicking on the Select... button below the Genotype file box (by default a preview of the file will be shown in its own window) and tell Cervus whether the first line of the genotype file is a Header row.

3.  Select which column in the genotype file contains IDs by changing the value in the ID in column box and which column contains the first allele of the first locus by changing the value in the First allele in column box.
4.  If you know the sex of individuals tick the Test sexes separately box, then select which column in the genotype file contains sex data by changing the value in the Sex in column box. You may also specify an Unknown sex label. Individuals of unknown sex are tested against themselves and all other individuals.
5.  Select an allele frequency file by clicking on the Select... button below the Allele frequency data box. This can be either the output of the Cervus allele frequency module (with the extension .alf), or a text file of allele frequencies you create yourself (with extension .csv or .txt). If you choose a user-defined allele frequency file you also need to tick the box if the file includes a Header row.
6.  Choose a name for the text output file by clicking on the Save As... button below the Summary output file box. You don't need to type the file extension (.txt). By default Cervus will save the data from the identity analysis in a file with the same name as the Summary output file but with the extension .csv. If you want to choose another name for the identity data file, click on the Save As... button below the Identity data file box and type a new name. If you type the extension .csv the file will be delimited with commas or if you type the extension .txt or any other extension the file will be delimited with tabs. Note that the Save as type box in the file dialog in fact selects the files that are displayed, not the type of the file you are saving.
7.  Choose the minimum number of loci required for a match to be declared using the Minimum number of matching loci box. The default value is half the total number of loci used in the last allele frequency analysis or simulation, rounded up if necessary.
8.  If you want to allow inexact matches, tick the Allow fuzzy matching check box. Use the box below to choose the maximum number of mismatching loci.
9.  If you want to see excluded pairs in the data file, tick Show all comparisons. The data file may become large and exceed the maximum of 65536 lines that older versions of Excel can display.
10. Click the OK button.

An identity analysis typically takes only a few seconds. When it is complete a summary of the results appear in the results window.

#### Identity analysis output

The results of identity analysis are displayed in text form in a results window and saved in a text file. The file contains the following information:

**A set of summary statistics**: the number of individuals compared, tne number of pairwise comparisons, the number of matching IDs found and the number of matching genotypes found. A list of the files used in the analysis, a list of loci read from the allele frequency file and a list of parameters specified in the Identity Check dialog box. If sexes were tested separately, a list of the labels found in the sex column of the genotype file including the number of individuals of each sex. If one or more matching IDs were found, a list of matching IDs. The actual identity data is stored in a separate text file, the identity analysis data file.

#### Identity analysis data file

By default Cervus adds one line of data to the identity analysis data file for each matching genotype pair including fuzzy matches if this option was selected. If Show all comparisons is selected one line is written to the file for every pairwise combination. The file may then exceed the maximum of 65536 lines that older versions of Excel can display. Each line of data contains the following information:

-   First ID. Name of the first individual.
-   Sex. Sex of the first individual.
-   Loci typed. Number of loci typed in the first individual.
-   Second ID. Name of the second individual.
-   Sex. Sex of the second individual.
-   Loci typed. Number of loci typed in the second individual.
-   Matching loci. Number of loci typed in both individuals that have identical genotypes.
-   Mismatching loci. Number of loci typed in both individuals that have non-identical genotypes.
-   pID. If the two genotypes match exactly, this column contains the probability that a single unrelated individual has this genotype.
-   pIDsib. If the two genotypes match exactly, this column contains the probability that a single full sibling has this genotype.
-   Status. This column describes the pair of genotypes. If the minimum number of matching loci is X and the maximum number of mismatching loci is Y, Exact match is shown if the number of matching loci is X or greater and there are no mismatching loci; Fuzzy match if the number of matching loci X or greater and the number of mismatching loci is between 1 and Y (only applicable if Fuzzy matching is selected); Not enough loci if the number of matching loci is less than X and the number of mismatching loci is between 0 and Y; and Excluded if the number of mismatching loci is greater than Y (only applicable if Show all comparisons is selected).

#### Individual probability of identity

The individual probability of identity is the probability given the genotype of one individual that a second individual will have the same genotype, assuming no typing errors occur. It is calculated in two forms, one assuming that the two individuals are unrelated and a second, more conservative form assuming the two individuals are full sibs.

In identity analysis Cervus calculates these statistics whenever an exact genotype match is found. No correction is made for the number of pairwise comparisons.

As well as the individual probability of identity it is also possible to calculate average probabilities of identity. These are calculated by Cervus during allele frequency analysis.

#### Average non-exclusion probabilities

In parentage analysis, the average non-exclusion probability is the probability of not excluding a single unrelated candidate parent or parent pair from parentage of a given offspring at one locus. Separate probabilities are calculated for non-exclusion of a single candidate parent with and without the genotype of a known parent of the opposite sex (Jamieson & Taylor 1997, Marshall et al. 1998).

In identity analysis, the average non-exclusion probability is the probability that the genotypes at a single locus do not differ between two randomly-chosen individuals. This probability may be calculated in two forms. The basic formula assumes that the two individuals are unrelated while a more conservative formula assumes the two individuals are full sibs (Waits et al. 2001).

During allele frequency analysis Cervus calculates these non-exclusion probabilities for each locus and also the combined non-exclusion probabilities across all loci: these represent the average probability of not excluding a single randomly-chosen unrelated individual from parentage at one or more loci. Combined non-exclusion probabilities assume all individuals are completely typed. The true probability of non-exclusion may be substantially higher if there are missing genotypes.

All these calculations assumes loci are in Hardy-Weinberg equilibrium.

As well as the average probability of non-exclusion, it is also possible to calculate the individual probability of non-exclusion for a particular offspring genotype (or offspring-known parent genotype pair). The average non-exclusion probability is calculated by summing these individual non-exclusion probabilities across all combinations of genotypes, weighted by genotype frequencies (assuming Hardy-Weinberg equilibrium).

Parentage non-exclusion probabilities do not have much bearing on the likelihood-based approach of Cervus, particularly when the error rate is greater than zero, but may be useful for comparison with previous analyses or with published work.

Additional references Jamieson, A & Taylor, StCS (1997) Comparisons of three probability formulae for parentage exclusion. Animal Genetics 28: 397-400. <http://dx.doi.org/10.1111/j.1365-2052.1997.00186.x>

Waits, LP, Luikart, G & Taberlet, P (2001) Estimating the probability of identity among genotypes in natural populations: cautions and guidelines. Molecular Ecology 10: 249-256. <http://dx.doi.org/10.1046/j.1365-294X.2001.01185.x>
