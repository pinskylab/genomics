Remove regenotyped samples
================

This script is written to take the filtered genepop file from dDocent
and 1) read the genepop file into R as a data frame 2) strip any named
samples down to pure ligation number, 3) identify and remove
re-genotyped samples based on number of loci (SNPs), 4) generate a new
genepop file to be fed to cervus for identification of recaptures.

# Set up workspace ———————————————

``` r
knitr::opts_chunk$set(eval = FALSE)

# pacman::p_load(tidyr, dplyr, stringr, readr, clownfish, here, install = FALSE)
# # library(dplyr) 
# # library(stringr)
# # library(readr)
# # library(clownfish)
# # library(here)
# 
# # while db connection using helper file isn't working 
# source("~/Documents/clownfish-pkg/R/db_connections.R")
# leyte <- read_db("Leyte")
# lab <- read_db("Laboratory")
```

``` r
# load data
genedf_raw <- read_genepop(here("data", "seq33_03_baits_only_SNPs.gen"))

# pull in the known issues table
iss <- lab %>% tbl("known_issues") %>% collect()
```

# 1\) Read the genepop - double check genepop to make sure the word pop separates the header from the data on line 3 - no quotes

``` r
# locate the genepop file and read as data frame
genedf <- genedf_raw %>% 
  rename(ligation_id = names) %>% 
  # 2) strip any named samples down to pure ligation number ---- 
  mutate(ligation_id = str_extract(ligation_id, "L\\d+"))
```

# 3\) Remove samples with known issues ————————————-

``` r
# remove issues from largedf
genedf <- genedf %>%
  filter(!ligation_id %in% iss$ligation_id)
```

# Add sample IDs and fish\_table\_ids

``` r
samples <- samp_from_lig(genedf)

# Merge the two dataframes so that lig IDs match up -----------------------
largedf <- left_join(genedf, samples, by = "ligation_id") %>% 
  select(sample_id, ligation_id, everything()) # move the sample_id column to the beginning

# tests ------------------------------------------------------------------
# # make sure all of the Ligation ids have sample ids
# filter(largedf, is.na(sample_id))
# # returns 0 rows
# nrow(genedf) == nrow(largedf) # should be TRUE
# # # look for missing names
# setdiff(genedf$ligation_id, largedf$ligation_id) # should be character(0)

# should return integer(0)
# else trouble <- largedf %>% filter(is.na(largedf$sample_id)) - 
# should be on the known issues table

# TEST - make sure no more match the list
# j <- largedf %>%
#   filter(ligation_id %in% iss$ligation_id)
# nrow(j) # should return 0
# rm(j)
# rm(genedf, samples, iss)
```

# Create the fish-obs table

``` r
# create
fish_gens <- get_fish() %>% 
  filter(sample_id %in% largedf$sample_id) %>% 
  select(fish_table_id, sample_id, tag_id) %>% 
  mutate(gen_id = 1:nrow(.))

fish_tags <- get_fish() %>% 
  # keep any fish that have been tagged 
  filter(!is.na(tag_id) & 
           # but not fish rows that are in the above table
           !fish_table_id %in% fish_gens$fish_table_id) %>% 
  select(fish_table_id, sample_id, tag_id) %>% 
  # assign a gen_id to every sample_id in the genepop which has been successfully genotyped
  mutate(gen_id = NA)

fish_obs <- rbind(fish_gens, fish_tags)

# test - are there duplicate rows of fish_table_ids
fish_obs %>% 
  group_by(fish_table_id) %>% 
  filter(n() > 1)

saveRDS(fish_obs, here("data", "fish-obs.RData"))
```

# Remove regenotyped samples ———————————————-

# convert 0000 to NA in the genepop data

``` r
largedf <- largedf %>% 
  na_if(., "0000")
```

# \# TEST - make sure there are no “0000” left

# which(largedf == “0000”) \# should return integer(0)

# count the number of loci per individual (have to use for loop)

``` r
# create an object that is the total number of cells that are not NA for each row in the largedf
numloci <- largedf %>% 
  is.na %>% 
  `!` %>% 
  rowSums

# add numloci as a column
largedf <- cbind(largedf, numloci)


# # TEST - make sure all of the numloci were populated ----------------------
# which(is.na(largedf$numloci)) # should return integer(0)
```

``` r
#run through all of the SampleIDs that are found more than once and keep the one with the most loci

# create a data frame of sample ids to keep or drop based on the number of loci present
regeno_drop <- largedf %>% 
  # select only the columns to identify which to keep
  select(sample_id, ligation_id, numloci) %>%
  group_by(sample_id) %>% 
  # create a maxloci column that holds the most loci each sample id carries
  mutate(maxloci = max(numloci), 
   # create a drop column that holds the decision to keep or drop that row
         drop = ifelse(numloci == maxloci, "KEEP", "DROP")) %>% 
  # keep only the columns that hold the maxloci and say "KEEP"
  filter(drop == "KEEP") %>% 
  ungroup() %>% 
  # keep only the columns needed to identify these "keeper rows"
  select(ligation_id)

# keep only the version of the sample id that has the most loci
noregeno1 <- largedf %>% 
  filter(ligation_id %in% regeno_drop$ligation_id)
```

# Some samples were not dropped because both regenotypes have the same number of loci.

``` r
regenod <- noregeno1 %>%
  filter(duplicated(noregeno1$sample_id)) %>%
  select(sample_id, ligation_id) %>% 
  distinct()

# drop the ligation_ids for these duplicated samples
noregeno <- noregeno1 %>% 
  filter(!ligation_id %in% regenod$ligation_id)

# make sure there is still a version in the data
test <- noregeno %>% 
  select(sample_id) %>% 
  filter(sample_id %in% regenod$sample_id)
# should be same number of rows as regenod
```

Prep for writing genepop

``` r
# convert all the NA genotypes to 0000
noregeno[is.na(noregeno)] = "0000"
# TEST - make sure there are no NA's left
which(is.na(noregeno)) # should return integer(0)

# # remove genotyped recaptures - only do this if you are ablsolutely sure you do not want to find new recapture events with this data
# leyte <- read_db("Leyte")
# recap <- leyte %>% tbl("clownfish") %>% 
#   filter(!is.na(cap_id)) %>% 
#   select(sample_id, cap_id) %>% 
#   collect()

# ########################################################################
# # # TEST - make sure a list was generated
# k <- nrow(recap)
# k # 277
```

# 4\) Output genepop file ————————————————–

``` r
# Build the genepop components
msg <- c("This genepop file was generated using a script called process_genepop.Rmd written by Michelle Stuart ")
write_lines(msg, path = str_c(here("data", "seq33-03_noregeno.gen"), sep = ""), append = F)

# find all of the column names that contain contig and collapse them into a comma separated string
loci <-  str_c(names(select(noregeno, contains("contig"))), collapse = ",")
write_lines(loci, path = str_c(here("data", "seq33-03_noregeno.gen"), sep = ""), append = T)

pop <- "pop"
write_lines(pop, path = str_c(here("data", "seq33-03_noregeno.gen"), sep = ""), append = T)

gene <- vector()
sample <- vector()
for (i in 1:nrow(noregeno)){
  gene[i] <- str_c(select(noregeno[i,], contains("contig")), collapse = " ")
  sample[i] <- str_c(noregeno$ligation_id[i], gene[i], sep = ", ")
  write_lines(sample[i], path = str_c(here("data", "seq33-03_noregeno.gen"), sep = ""), append = T)
}
```
