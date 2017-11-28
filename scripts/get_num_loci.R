# Find the number of loci genotyped for each individual

# Set up workspace ---------------------------------------------
source("scripts/gen_helpers.R")
library(dplyr) 
library(stringr)
library(readr)

# 1) Read the genepop  - double check genepop to make sure the word
# pop separates the header from the data on line 3 - no quotes

# locate the genepop file and read as data frame
genfile <- "data/seq17_03g95maf2q30dp15.gen"
genedf <- read_genepop(genfile)


# 2) strip any named samples down to pure ligation number ---- 

# create a search term to search for ligation ids within a name
ligid <- "(.+)(L\\d\\d\\d\\d)" 

# an L followed by 4 digits, while APCL also contains an L, it shouldn't ever be followed by 4 digits, except in 2015...apparently the sample_id numbers were truncated in 2015 samples for dDocent which is why we can only go by ligation_id to identify these samples.

# TEST - what does this search string find?
# test <- str_detect(genedf$names, ligid)
# summary(test) # should be no FALSE

# change all of the names to ligation id only
genedf$names <- genedf$names %>% str_replace(ligid,"\\2")

# TEST are any names still longer than 5 characters?
which(nchar(genedf$names) > 5) # should be integer(0)

genedf <- rename(genedf, ligation_id=names)

# Add sample IDs ----------------------------------------------------------
samples <- samp_from_lig(genedf)

# Merge the two dataframes so that lig IDs match up -----------------------
largedf <- left_join(genedf, samples, by = "ligation_id") %>% 
  select(sample_id, ligation_id, everything()) # move the sample_id column to the beginning
rm(samples)

# TEST - check the last 2 column names and that the number of rows hasn't changed
# p <- ncol(largedf)
# names(largedf[,(p-1):p]) 
# # "dDocent_Contig_245445_140" "dDocent_Contig_256998_105"
# nrow(genedf) == nrow(largedf) # should be TRUE
# # look for missing names
# setdiff(genedf$ligation_id, largedf$ligation_id) # should be character(0)
rm(genedf, ligid, genfile)

# convert 0000 to NA in the genepop data
largedf[largedf == "0000"] = NA

# # TEST - make sure there are no "0000" left
# which(largedf == "0000") # should return integer(0)

# count the number of loci per individual (have to use for loop)
for(i in 1:nrow(largedf)){
  largedf$numloci[i] <- sum(!is.na(largedf[i,]))
}

# # TEST - make sure all of the numloci were populated ----------------------
# which(is.na(largedf$numloci)) # should return integer(0)

# save this data to be used by the laboratory project
largedf <- largedf %>% 
  select(sample_id, ligation_id, numloci)
saveRDS(largedf, "../laboratory/data/num_loci.Rdata")
