SNP FILTERING
================

  - [Filtering to yield more loci than
    FS6](#filtering-to-yield-more-loci-than-fs6)
      - [Step 1: Filter LQ loci](#step-1-filter-lq-loci)
      - [Step 2: Missing data
        indvidiuals/loci](#step-2-missing-data-indvidiualsloci)
          - [2a: Retain loci with genotype call rate \> 50% and flag
            individuals with missing
            data.](#a-retain-loci-with-genotype-call-rate-50-and-flag-individuals-with-missing-data.)
          - [2b: Identify individuals with \> 90% missing
            data.](#b-identify-individuals-with-90-missing-data.)
      - [Step 3: Info flag filtering](#step-3-info-flag-filtering)
          - [Allele balance](#allele-balance)
          - [replot to make sure the changes were
            effective](#replot-to-make-sure-the-changes-were-effective)
          - [Quality/depth ratio](#qualitydepth-ratio)
          - [ratio mapping quality](#ratio-mapping-quality)
  - [`{r eval=FALSE} # # temp <- read.table(here("data",
    "filtering_step3ABQDPTH.MQM"), col.names = "MQM") # # mapqual <-
    read.table(here("data", "filtering_step3ABQDPTH.MQMR"), col.names =
    "MQMR") # # mapqual <- bind_cols(mapqual, temp) %>% # mutate(ratio =
    MQM/MQMR) # # filter <- mapqual %>% # filter(ratio < 0.25 | ratio
    > 1.75) # # ggplot(mapqual, aes(x = MQM, y = MQMR)) + #
    geom_point(shape = 1) + # geom_abline(intercept = 0, slope = 1, size
    = 1, color = "red", linetype = "dashed") + # geom_abline(intercept
    = 0, slope = 4, size = 1, color = "darkblue", linetype = "dashed") +
    # geom_abline(intercept = 0, slope = 0.571, size = 1, color =
    "darkblue", linetype = "dashed") + # geom_point(data = filter, aes(x
    = MQM, y = MQMR), shape = 1, color = "red") + #
    scale_x_continuous(limits = c(0, 65)) + # scale_y_continuous(limits
    = c(0, 65)) + # labs(x = "mean mapping quality alt allele ", y =
    "mean mapping quality ref allele ") + # theme_standard #
    #`](#r-evalfalse-temp---read.tableheredata-filtering_step3abqdpth.mqm-col.names-mqm-mapqual---read.tableheredata-filtering_step3abqdpth.mqmr-col.names-mqmr-mapqual---bind_colsmapqual-temp-mutateratio-mqmmqmr-filter---mapqual-filterratio-0.25-ratio-1.75-ggplotmapqual-aesx-mqm-y-mqmr-geom_pointshape-1-geom_ablineintercept-0-slope-1-size-1-color-red-linetype-dashed-geom_ablineintercept-0-slope-4-size-1-color-darkblue-linetype-dashed-geom_ablineintercept-0-slope-0.571-size-1-color-darkblue-linetype-dashed-geom_pointdata-filter-aesx-mqm-y-mqmr-shape-1-color-red-scale_x_continuouslimits-c0-65-scale_y_continuouslimits-c0-65-labsx-mean-mapping-quality-alt-allele-y-mean-mapping-quality-ref-allele-theme_standard)
      - [Maximum depth & Quality](#maximum-depth-quality)
      - [Plot stats after FIL\_6
        filters](#plot-stats-after-fil_6-filters)
      - [Step 4: Filter Missing data
        loci/indv](#step-4-filter-missing-data-lociindv)
      - [Step 5](#step-5)
          - [Plot stats for filtered data
            set](#plot-stats-for-filtered-data-set)
      - [Run SNP counting script](#run-snp-counting-script)

This filtering scheme follows the FS6 scheme of
[SJO’Leary](https://github.com/sjoleary/SNPFILT) modified to include
any genotypes called in 70% of the population and any individuals with
no more than 35% missing data and to include a maf filter of 0.2 at the
end.

``` r
knitr::opts_chunk$set(
    eval = FALSE,
    message = FALSE,
    warning = FALSE, 
    cache = TRUE
)
# library(ggplot2)
# library(readr)
# library(dplyr)
# library(here)
# source(here("filtering", "ggplot.R"))
# source(here("filtering", "VCFfilterstats.R"))
# source(here("filtering", "xtrafunctions.R"))
```

## Filtering to yield more loci than FS6

### Step 1: Filter LQ loci

Remove SNPs with quality score \< 20, minimum depth per genotype \< 5,
minimum mean depth \< 15.  
This chunk can take some time because it is filtering out the full data
set. Adding maf 0.2 here ../data in \~1000 SNPs, trying to add it later.

### Step 2: Missing data indvidiuals/loci

The max-missing option excludes sites based on the proportion of missing
data where 0 is completely missing and 1 is not missing at all.

#### 2a: Retain loci with genotype call rate \> 50% and flag individuals with missing data.

#### 2b: Identify individuals with \> 90% missing data.

Everything to the right of the blue line will be eliminated.

``` r
imiss <- read_delim(here("data", "indv_miss_1.imiss"), delim = "\t")

ggplot(imiss, aes(x = F_MISS)) +
  geom_histogram(binwidth = 0.05, color = "black", fill = "grey75") +
  geom_vline(xintercept = 0.9, color = "darkblue", linetype = "dashed") +
  scale_x_continuous(limits = c(0, 1)) +
  theme_standard

LQ_indv <- imiss %>%
  filter(F_MISS > 0.9) %>%
  select(INDV)

write.table(LQ_indv, here("data", "LQ_Ind_it1a"),
            col.names = FALSE, row.names = FALSE, quote = FALSE)
```

Remove flagged individuals, adding maf 0.2 here ../data in 0 SNPs,
trying later.

### Step 3: Info flag filtering

#### Allele balance

AB: Allele balance at heterozygous sites: a number between 0 and 1
representing the ratio of reads showing the reference allele to all
reads, considering only reads from individuals called as heterozygous

Allele balance is the ratio of reads for reference allele to all reads,
considering only reads from individuals called as heterozygous. Values
range from 0 - 1; allele balance (for real loci) should be approx. 0.5.
Filter contigs SNPs for which the with allele balance \< 0.25 and \>
0.75.

``` r
read.table(here("data", "filtering_step3.AB"),
           col.names = "AB", stringsAsFactors = FALSE) %>%
  ggplot(aes(x = AB)) +
  geom_histogram(binwidth = 0.01, color = "black", fill = "grey95") +
  geom_vline(xintercept = 0.5, color = "red", linetype = "dashed") +
  geom_vline(xintercept = 0.2, color = "darkblue", linetype = "dashed") +
  geom_vline(xintercept = 0.8, color = "darkblue", linetype = "dashed") +
  labs(x = "Allele balance ") +
  theme_standard
```

Filter contigs with SNP calls with AB \> 0.2, AB \> 0.8; retain loci
very close to 0 (retain loci that are fixed variants). Remove genotypes
if the quality sum of the reference or alternate allele was 0.

#### replot to make sure the changes were effective

``` r
read.table(here("data", "filtering_step3AB.AB"),
           col.names = "AB", stringsAsFactors = FALSE) %>%
  ggplot(aes(x = AB)) +
  geom_histogram(binwidth = 0.01, color = "black", fill = "grey95") +
  geom_vline(xintercept = 0.5, color = "red", linetype = "dashed") +
  geom_vline(xintercept = 0.2, color = "darkblue", linetype = "dashed") +
  geom_vline(xintercept = 0.8, color = "darkblue", linetype = "dashed") +
  labs(x = "Allele balance ") +
  theme_standard
```

#### Quality/depth ratio

Compare quality/depth.

``` r
# depth
depth <- read.table(here("data", "filtering_step3.DEPTH"),
                    col.names = "depth")

# quality score
qual <- read.table(here("data", "filtering_step3.QUAL"),
                   col.names = c("locus", "pos", "qual"))

df <- bind_cols(qual, depth) %>%
  mutate(ratio = qual/depth)

ggplot(df, aes(x = ratio)) + 
  geom_histogram(binwidth = 0.1, color = "black", fill = "grey95") +
  geom_vline(xintercept = 0.2, color = "darkred", linetype = "dashed") +
  geom_vline(xintercept = 0.5, color = "darkred", linetype = "dashed") +
  labs(x = "ratio depth/quality ", y = "no. of loci") +
  theme_standard
```

Remove loci with quality/depth ratio \< 0.2

``` r
# depth
depth <- read.table(here("data", "filtering_step3ABQDPTH.DEPTH"),
                    col.names = "depth")

# quality score
qual <- read.table(here("data", "filtering_step3ABQDPTH.QUAL"),
                   col.names = c("locus", "pos", "qual"))

df <- bind_cols(qual, depth) %>%
  mutate(ratio = qual/depth)

ggplot(df, aes(x = ratio)) + 
  geom_histogram(binwidth = 0.1, color = "black", fill = "grey95") +
  geom_vline(xintercept = 0.2, color = "darkred", linetype = "dashed") +
  geom_vline(xintercept = 0.5, color = "darkred", linetype = "dashed") +
  labs(x = "ratio depth/quality ", y = "no. of loci") +
  theme_standard
```

Based on the above graph, I was going to re-do the cutoff at 0.5 but the
y-axis shows that the peak went down from 3000 to 150 so even though
there is still a peak, it is clearly very zoomed in.

#### ratio mapping quality

Remove loci based on ratio of mapping quality for reference and
alternate allele, i.e. sites that have a high discrepancy between the
mapping qualities of two alleles. Skipping this step because vcf tools
takes more than the red circles.

``` r
temp <- read.table(here("data", "filtering_step3.MQM"), col.names = "MQM")

mapqual <- read.table(here("data", "filtering_step3.MQMR"), col.names = "MQMR")

mapqual <- bind_cols(mapqual, temp) %>%
  mutate(ratio = MQM/MQMR)

filter <- mapqual %>%
  filter(ratio < 0.25 | ratio > 1.75)

ggplot(mapqual, aes(x = MQM, y = MQMR)) +
  geom_point(shape = 1) + 
  geom_abline(intercept = 0, slope = 1, size = 1, color = "red", linetype = "dashed") +
  geom_abline(intercept = 0, slope = 4, size = 1, color = "darkblue", linetype = "dashed") +
  geom_abline(intercept = 0, slope = 0.571, size = 1, color = "darkblue", linetype = "dashed") +
  geom_point(data = filter, aes(x = MQM, y = MQMR), shape = 1, color = "red") +
  scale_x_continuous(limits = c(0, 65)) + 
  scale_y_continuous(limits = c(0, 65)) +
  labs(x = "mean mapping quality alt allele ", y = "mean mapping quality ref allele ") +
  theme_standard
```

Filter loci with mapping quality ratio \< 0.25 and \> 1.75.

<!-- ```{bash eval=FALSE, include=FALSE} -->

<!--  -->

<!-- vcffilter -s -f "MQM / MQMR > 0.25 & MQM / MQMR < 1.75" ../data/filtering_step3ABQDPTH.recode.vcf > ../data/filtering_step3ABQDPTHMQM.recode.vcf -->

<!-- mawk '!/#/' ../data/filtering_step3ABQDPTHMQM.recode.vcf | wc -l -->

<!-- echo $? -->

<!-- # mapping quality -->

<!-- cut -f8 ../data/filtering_step3ABQDPTH.recode.vcf | grep -oe "MQM=[0-9]*" | sed -s 's/MQM=//g' > ../data/filtering_step3ABQDPTH.MQM -->

<!-- cut -f8 ../data/filtering_step3ABQDPTH.recode.vcf | grep -oe "MQMR=[0-9]*" | sed -s 's/MQMR=//g' > ../data/filtering_step3ABQDPTH.MQMR -->

<!-- ``` -->

# `{r eval=FALSE} #  # temp <- read.table(here("data", "filtering_step3ABQDPTH.MQM"), col.names = "MQM") #  # mapqual <- read.table(here("data", "filtering_step3ABQDPTH.MQMR"), col.names = "MQMR") #  # mapqual <- bind_cols(mapqual, temp) %>% #   mutate(ratio = MQM/MQMR) #  # filter <- mapqual %>% #   filter(ratio < 0.25 | ratio > 1.75) #  # ggplot(mapqual, aes(x = MQM, y = MQMR)) + #   geom_point(shape = 1) +  #   geom_abline(intercept = 0, slope = 1, size = 1, color = "red", linetype = "dashed") + #   geom_abline(intercept = 0, slope = 4, size = 1, color = "darkblue", linetype = "dashed") + #   geom_abline(intercept = 0, slope = 0.571, size = 1, color = "darkblue", linetype = "dashed") + #   geom_point(data = filter, aes(x = MQM, y = MQMR), shape = 1, color = "red") + #   scale_x_continuous(limits = c(0, 65)) +  #   scale_y_continuous(limits = c(0, 65)) + #   labs(x = "mean mapping quality alt allele ", y = "mean mapping quality ref allele ") + #   theme_standard #  #`

It seems like this is cutting out a lot more loci than the red ones in
the first graph. I’m not sure the vcffilter is doing what it thinks it
is. Undo the cut of loci.

#### Maximum depth & Quality

Identify distribution of depth (based on original data set) to identify
loci with excess coverage.

(INFO flags in filtered data set are are based on original number of
individuals in data set).

Calculate average depth and standard deviation:

``` r
# depth
depth <- read.table(here("data", "filtering_step3.DEPTH"),
                    col.names = "depth")

# quality score
qual <- read.table(here("data", "filtering_step3.QUAL"),
                   col.names = c("locus", "pos", "qual"))

# mean depth
mean_depth <- mean(depth$depth)

# standard deviation
std <- sd(depth$depth)

# mode
mode <- Mode(depth$depth)

cutoff <- sum(mean_depth + (2*std))

# identify SNP sites with depth > mean depth + 1 standard deviation and quality score < 2x the depth at that site
temp <- bind_cols(qual, depth) %>%
  filter(depth > cutoff) %>%
  filter(qual < 2*depth) %>%
  select(locus)

write.table(temp, here("data", "DEPTH.lowQloci"), col.names = FALSE, row.names = FALSE, quote = FALSE)

df <- bind_cols(qual, depth) %>%
  mutate(qualcutoff = 2*depth)

removeloc <- df %>%
  filter(depth > cutoff) %>%
  filter(qual < 2*depth)

ggplot(df, aes(x = depth, y = qual)) +
  geom_point(shape = 1) +
  geom_point(data = removeloc, aes(x = depth, y = qual), shape = 1, color = "red") +
  geom_line(data = df, aes(x = depth, y = qualcutoff), color = "blue",  linetype = "dashed", size = 1) +
  geom_vline(xintercept = cutoff, color = "blue", linetype = "dashed", size = 1) +
  labs(x = "") +
  theme_standard
```

Compare the distribution of mean depth per site averaged across
individuals to determine cut-off value of sites with excessively high
depth indicative of paralogs/multicopy loci.

``` r
# calculate mean depth per site (177 individuals)
depth <- read.table(here("data", "filtering_step3ABQDPTHQUAL.ldepth.mean"),header = TRUE, stringsAsFactors = FALSE)
  
# mean mean depth
mean <- mean(depth$MEAN_DEPTH)

# standard deviation
std <- sd(depth$MEAN_DEPTH)

# mode
mode <- Mode(depth$MEAN_DEPTH)

cutoff <- sum(mean + (2*std))

ggplot(depth, aes(x = MEAN_DEPTH)) +
  geom_histogram(binwidth = 5, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = mode),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = cutoff),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per site") +
  theme_standard
```

#### Plot stats after FIL\_6 filters

``` r
# load stats files ----
ind_stats_FIL_6 <- read.ind.stats(dir = "../data", vcf = "FIL_6")

loc_stats_FIL_6 <- read.loc.stats(dir = "../data", vcf = "FIL_6")

# plot missing data per indv ----
p1 <- ggplot(ind_stats_FIL_6, aes(x = F_MISS)) +
  geom_histogram(binwidth = .01, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0.5),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "missing data per indv") +
  theme_standard

# plot Fis per indv ----
p2 <- ggplot(ind_stats_FIL_6, aes(x = F)) +
  geom_histogram(binwidth = .01, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(F, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "Fis per indv") +
  theme_standard

# plot read depth per indv ----
p3 <- ggplot(ind_stats_FIL_6, aes(x = MEAN_DEPTH)) +
  geom_histogram(binwidth = 10, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean read depth per indv") +
  theme_standard

# plot depth vs missing ----
p4 <- ggplot(ind_stats_FIL_6, aes(x = MEAN_DEPTH, y = F_MISS)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 0.5),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per indv", y = "% missing data") +
  theme_standard

# plot Fis vs missing data per indv ----
p5 <- ggplot(ind_stats_FIL_6, aes(x = F, y = F_MISS)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(F, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 0.5),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "Fis per indv", y = "% missing data") +
  theme_standard

# plot Fis vs mean depth per indv ----
p6 <- ggplot(ind_stats_FIL_6, aes(x = F, y = MEAN_DEPTH)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(F, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "Fis per indv", y = "mean depth per indv") +
  theme_standard

# plot distribution missing data per locus ----
p7 <- ggplot(loc_stats_FIL_6, aes(x = F_MISS)) +
  geom_histogram(binwidth = 0.01, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0.1),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "% missing data per locus") +
  theme_standard

# plot distribution mean read depth ----
p8 <- ggplot(loc_stats_FIL_6, aes(x = MEAN_DEPTH)) +
  geom_histogram(binwidth = 5, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean read depth per locus") +
  theme_standard

# plot read depth vs missing data ----
p9 <- ggplot(loc_stats_FIL_6, aes(x = MEAN_DEPTH, y = F_MISS)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 0.1),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per locus", y = "% missing data") +
  theme_standard

# plot no of SNPs per locus ----
p10 <- loc_stats_FIL_6 %>%
  count(CHROM) %>%
  ggplot(aes(x = n)) +
  geom_histogram(binwidth = 1, color = "black", fill = "grey95") + 
  labs(x = "number of SNPs per locus") +
  theme_standard

temp <- loc_stats_FIL_6 %>%
  count(CHROM)

# plot number of SNPs per contig vs. mean depth ----
p11 <- left_join(temp, loc_stats_FIL_6) %>%
  ggplot() +
  geom_point(aes(x = n, y = MEAN_DEPTH)) +
  labs(x = "number of SNPs per contig", y = "mean depth") +
  theme_standard

# plot depth vs SNP quality ----
site_qual <- read.table(here("data", "FIL_6.lqual"), header = TRUE, stringsAsFactors = FALSE) %>%
  mutate(PROB = 10^(-QUAL/10))

temp <- tibble(depth = loc_stats_FIL_6$MEAN_DEPTH, qual = site_qual$QUAL) 

p12 <- ggplot(temp, aes(x = depth, y = qual)) +
  geom_point(size = 1) +
  geom_vline(aes(xintercept = mean(depth, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(qual, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per locus", y = "SNP quality") +
  theme_standard

m6 <- multiplot(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, cols=2)
```

### Step 4: Filter Missing data loci/indv

Remove loci with genotype call rate \< 60%.

Identify individuals with \> 80% missing data

``` r
imiss <- read.table(here("data", "filtering_step4a.imiss"), 
                    header = TRUE, stringsAsFactors = FALSE)

ggplot(imiss, aes(x = F_MISS)) +
  geom_histogram(binwidth = 0.05, color = "black", fill = "grey75") +
  geom_vline(xintercept = .8, color = "darkred", linetype = "dashed") +
  scale_x_continuous(limits = c(0, 1)) +
  theme_standard

LQ_indv <- imiss %>%
  filter(F_MISS > 0.8) %>%
  select(INDV)

write.table(LQ_indv, here("data", "LQ_Ind_FIL_6a"),
            col.names = FALSE, row.names = FALSE, quote = FALSE)
```

Remove flagged individuals

## Step 5

Remove loci with genotype call rate \< 70%.

Identify individuals with \> 35% missing data

``` r
imiss <- read.table(here("data", "filtering_step5a.imiss"), 
                    header = TRUE, stringsAsFactors = FALSE)

ggplot(imiss, aes(x = F_MISS)) +
  geom_histogram(binwidth = 0.05, color = "black", fill = "grey75") +
  geom_vline(xintercept = .35, color = "darkred", linetype = "dashed") +
  scale_x_continuous(limits = c(0, 1)) +
  theme_standard

LQ_indv <- imiss %>%
  filter(F_MISS > 0.35) %>%
  select(INDV)

write.table(LQ_indv, here("data", "LQ_Ind_FIL_6b"),
            col.names = FALSE, row.names = FALSE, quote = FALSE)
```

Remove flagged individuals

Final FIL\_6 filtering step, remove indels and apply maf of 0.2

### Plot stats for filtered data set

``` r
# load stats files ----
ind_stats_FIL_6 <- read.ind.stats(dir = "../data", vcf = "FIL_6")

loc_stats_FIL_6 <- read.loc.stats(dir = "../data", vcf = "FIL_6")

# plot missing data per indv ----
p1 <- ggplot(ind_stats_FIL_6, aes(x = F_MISS)) +
  geom_histogram(binwidth = .01, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0.5),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "missing data per indv") +
  theme_standard

# plot Fis per indv ----
p2 <- ggplot(ind_stats_FIL_6, aes(x = F)) +
  geom_histogram(binwidth = .01, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(F, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "Fis per indv") +
  theme_standard

# plot read depth per indv ----
p3 <- ggplot(ind_stats_FIL_6, aes(x = MEAN_DEPTH)) +
  geom_histogram(binwidth = 10, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean read depth per indv") +
  theme_standard

# plot depth vs missing ----
p4 <- ggplot(ind_stats_FIL_6, aes(x = MEAN_DEPTH, y = F_MISS)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 0.5),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per indv", y = "% missing data") +
  theme_standard

# plot Fis vs missing data per indv ----
p5 <- ggplot(ind_stats_FIL_6, aes(x = F, y = F_MISS)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(F, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 0.5),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "Fis per indv", y = "% missing data") +
  theme_standard

# plot Fis vs mean depth per indv ----
p6 <- ggplot(ind_stats_FIL_6, aes(x = F, y = MEAN_DEPTH)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(F, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "Fis per indv", y = "mean depth per indv") +
  theme_standard

# plot distribution missing data per locus ----
p7 <- ggplot(loc_stats_FIL_6, aes(x = F_MISS)) +
  geom_histogram(binwidth = 0.01, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 0.1),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "% missing data per locus") +
  theme_standard

# plot distribution mean read depth ----
p8 <- ggplot(loc_stats_FIL_6, aes(x = MEAN_DEPTH)) +
  geom_histogram(binwidth = 5, color = "black", fill = "grey95") +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean read depth per locus") +
  theme_standard

# plot read depth vs missing data ----
p9 <- ggplot(loc_stats_FIL_6, aes(x = MEAN_DEPTH, y = F_MISS)) +
  geom_point() +
  geom_vline(aes(xintercept = mean(MEAN_DEPTH, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(F_MISS, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 0.1),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per locus", y = "% missing data") +
  theme_standard

# plot no of SNPs per locus ----
p10 <- loc_stats_FIL_6 %>%
  count(CHROM) %>%
  ggplot(aes(x = n)) +
  geom_histogram(binwidth = 1, color = "black", fill = "grey95") + 
  labs(x = "number of SNPs per locus") +
  theme_standard

temp <- loc_stats_FIL_6 %>%
  count(CHROM)

# plot number of SNPs per contig vs. mean depth ----
p11 <- left_join(temp, loc_stats_FIL_6) %>%
  ggplot() +
  geom_point(aes(x = n, y = MEAN_DEPTH)) +
  labs(x = "number of SNPs per contig", y = "mean depth") +
  theme_standard

# plot depth vs SNP quality ----
site_qual <- read.table(here("data", "FIL_6.lqual"), header = TRUE, stringsAsFactors = FALSE) %>%
  mutate(PROB = 10^(-QUAL/10))

temp <- tibble(depth = loc_stats_FIL_6$MEAN_DEPTH, qual = site_qual$QUAL) 

p12 <- ggplot(temp, aes(x = depth, y = qual)) +
  geom_point(size = 1) +
  geom_vline(aes(xintercept = mean(depth, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_vline(aes(xintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = mean(qual, na.rm = TRUE)),
                 color = "red", linetype = "dashed", size = 1) +
  geom_hline(aes(yintercept = 20),
                 color = "darkblue", linetype = "dashed", size = 1) +
  labs(x = "mean depth per locus", y = "SNP quality") +
  theme_standard

m7 <- multiplot(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, cols=2)
```

## Run SNP counting script

Compare SNPs/contigs/indv at each filtering step and between filtering
schemes.

``` r
count <- read_table(here("filtering","Filter.count"))
knitr::kable(count)
```

Convert the vcf to a genepop

Next step is to remove regenotypes from the genepop.
