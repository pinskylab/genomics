# This script is written to take the filtered genepop file from dDocent and 
# 1) strip any named samples down to pure ligation number, 
# 2) identify and remove re-genotyped samples based on number of loci (SNPs), 
# 3) generate a new genepop file to be fed to cervus for identification of recaptures.

# Set up workspace ---------------------------------------------
source("scripts/gen_helpers.R")
library(dplyr) 
library(stringr)
library(readr)




# 1) Read the genepop  - double check genepop to make sure the word
# pop separates the header from the data on line 3 - no quotes

# locate the genepop file and read as data frame
genfile <- "data/seq17_for_colony.gen"
genedf <- read_gen_sp(genfile)

### WAIT ### 


# # Strip out the ligation ID
# 
# # are any of names longer than a 5 digit ligation id?
# genedf %>% filter(nchar(names) > 5) %>% count()

# create a search term to search for ligation ids within a name
ligid <- "(.+)(L\\d\\d\\d\\d)" # an L followed by 4 digits, while APCL also contains an L, it shouldn't ever be followed by 4 digits, except in 2015...hmmm
# change all of the names to be just the ligation id
# test - what does this search string find?
# test <- str_detect(genedf$names, ligid)

genedf$names <- genedf$names %>% str_replace(ligid,"\\2")

# TEST are any names still longer than 5 characters?
which(nchar(genedf$names) > 5) # should be integer(0)

# Add sample IDs ----------------------------------------------------------
samples <- samp_from_lig(genedf)
samples <- samples %>% 
  rename(names = ligation_id)

# Merge the two dataframes so that lig IDs match up -----------------------

largedf <- left_join(genedf, samples, by = "names") %>% 
  select(sample_id, names, everything()) # move the sample_id column to the beginning
rm(samples)

# # TEST - check the last 2 column names and that the number of rows hasn't changed
# p <- ncol(largedf)
# names(largedf[,(p-1):p]) # " dDocent_Contig_256998_105" "sample_id"    
# nrow(genedf) == nrow(largedf) # should be TRUE
# # look for missing names
# setdiff(genedf$names, largedf$names) # should be character(0)
rm(genedf)

# Remove samples with known issues ----------------------------------------

# to remove samples with known issues, pull the data from the known issues database
# open the laboratory database to retrieve sample info
# suppressMessages(library(dplyr))
leyte <- read_db("Leyte")

iss <- leyte %>% tbl("known_issues") %>% collect()
rm(leyte)

# remove issues from largedf
largedf <- largedf %>%
  filter(!names %in% iss$Ligation_ID)


# make sure all of the Ligation ids have sample ids
which(is.na(largedf$sample_id)) # 1972- L3118 has no sample id, is a mixture of samples
# should return integer(0), else largedf <- largedf %>% filter(!is.na(largedf$sample_id)) - 
# should be on the known issues table

# # TEST - make sure no more match the list
# j <- largedf %>%
#   filter(names %in% iss$Ligation_ID)
# nrow(j) # should return 0
# rm(j)
rm(iss)


# Remove regenotyped samples ----------------------------------------------

# convert 0000 to NA in the genepop data
largedf[largedf == "0000"] = NA

# # TEST - make sure there are no "0000" left
# which(largedf == "0000") # should return integer(0)

# count the number of loci per individual (have to use for loop)
for(i in 1:nrow(largedf)){
  largedf$numloci[i] <- sum(!is.na(largedf[i,]))
}

### WAIT ###

# # TEST - make sure all of the numloci were populated ----------------------
# which(is.na(largedf$numloci)) # should return integer(0)

# make a list of all of the sample ID's that have duplicates (some on this list occur more than once because there are 3 regenos)
# this line of code keeps any sample_id that comes up as TRUE for being duplicated
regenod <- largedf %>%
  filter(duplicated(largedf$sample_id)) %>%
  select(sample_id)

# # TEST - make sure a list was generated
k <- nrow(regenod) # keep for later



largedf$drop <- NA # place holder
#run through all of the SampleIDs that are found more than once and keep the one with the most loci
# for testing b <- 1
for(i in 1:nrow(regenod)){
  # regeno_drop is the row number from largedf that matches an ID in the regeno_match list
  regeno_drop <- which(largedf$sample_id == regenod[i,]) 
  # df is the data frame that holds all of the regenotyped versions of the sample, pulled from largedf
  df <- largedf[regeno_drop, ]  
  # convert the drop column of large df from na to KEEP
  largedf$drop[regeno_drop[which.max(df$numloci)]] <- "KEEP"
  
  # find the row numbers of largedf that need to be dropped
  # test j <- 2
  for(j in 1:length(regeno_drop)){ # for all of the rows in the tiny df of mutliple ligs for one sample_id
    if(is.na(largedf$drop[regeno_drop[j]])){ # if the drop column is na (not keep from above)
      largedf$drop[regeno_drop[j]] <- "DROP" # make that row number drop value "DROP"
    }
  }
}

# TEST - make sure all of the regenos were dropped ----------------------------
a <- length(which(largedf$drop == "KEEP")) # num keeps
b <- length(which(duplicated(regenod) == TRUE)) # num samples that were seq'd more than twice
a  + b == nrow(regenod) # should return TRUE 
length(which(largedf$drop == "DROP")) == nrow(regenod) # should be TRUE


# convert all of the KEEPs to NAs 
largedf$drop[largedf$drop == "KEEP"] <- NA

# create a new data frame with none of the "DROP" rows
noregeno <- largedf[is.na(largedf$drop),]

# TEST - make sure no drop rows made it
which(noregeno$drop == "DROP") # should return integer(0)
# TEST - check to see if there are any regenos that were missed
noregeno$sample_id[duplicated(noregeno$sample_id)] # should return character(0)  
# If it doesn't, look deeper: noregeno[which(noregeno$SampleID == "APCL15_403"),], largedf[which(largedf$sample_ID == "APCL15_403"),]

# remove the extra columns from noregeno
noregeno <- noregeno %>% 
  select(-numloci, -drop)

# convert all the NA genotypes to 0000
noregeno[is.na(noregeno)] = "0000"
# TEST - make sure there are no NA's left
which(is.na(noregeno)) # should return integer(0)

# TEST - compare the length of noregeno to the length of largedf
nrow(noregeno) == nrow(largedf) - k # 1569/1531 - should return TRUE


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


noregeno$drop <- NA # place holder
#run through all of the SampleIDs that are found more than once and keep the one with the most loci
# for testing b <- 1
# for(i in 1:max(recap$cap_id)){
#   # recap_drop is the line number from noregeno that matches an ID in the regeno_match list
#   X <- recap$sample_id[recap$cap_id == recap$cap_id[i]]
#   recap_drop <- which(noregeno$sample_id %in% X)
#   # df is the data frame that holds all of the regenotyped versions of the sample, pulled from noregeno
#   df <- noregeno[recap_drop, ]  
#   # the row number of df with the largest number of loci (p-1 indicates the column)
#   keep <- which.max(df$numloci) 
#   # convert the df number to the row number of large df
#   c <- recap_drop[keep]
#   # convert the drop column of the row to keep to not na
#   df$drop[keep] <- "KEEP"
#   # convert the drop column of large df to not na
#   noregeno$drop[c] <- "KEEP"
#   
#   # find the row numbers of noregeno that need to be dropped
#   # test e <- 2
#   for(e in 1:nrow(df)){
#     if(is.na(df$drop[e])){
#       f <-recap_drop[e]
#       noregeno$drop[f] <- "DROP"
#     }
#   }
# }

# convert all of the KEEPs to NAs 
for(g in 1:nrow(noregeno)){
  if(!is.na(noregeno$drop[g]) && noregeno$drop[g]=="KEEP"){
    noregeno$drop[g] <- NA
  }
}

# create a new data frame with none of the "DROP" rows
noregeno <- noregeno[is.na(noregeno$drop),]
# TEST - make sure no drop rows made it
which(noregeno$drop == "DROP") # should return integer(0)
# TEST - check to see if there are any regenos that were missed
noregeno_match <- noregeno$sample_id[duplicated(noregeno$sample_id)]
noregeno_match # should return character(0)  
# If it doesn't, look deeper: noregeno[which(noregeno$SampleID == "APCL15_403"),], largedf[which(largedf$sample_ID == "APCL15_403"),]

# remove the extra columns from noregeno
noregeno [,c("extraction_ID")] <- NULL
noregeno [,c("digest_ID")] <- NULL
noregeno [,c("numloci")] <- NULL
noregeno [,c("drop")] <- NULL

# convert all the NA genotypes to 0000
noregeno[is.na(noregeno)] = "0000"
# TEST - make sure there are no NA's left
which(is.na(noregeno)) # should return integer(0)

# TEST - compare the length of noregeno to the length of largedf
nrow(noregeno) == nrow(largedf) - k # 1569/1531 - should return TRUE



# 4) Output genepop file --------------------------------------------------

# Build the genepop components
msg <- c("This genepop file was generated using a script called process_genepop.R written by Michelle Stuart with help from Malin Pinsky")
write_lines(msg, path = str_c("data/", Sys.Date(), "noregeno.gen", sep = ""), append = F)

# find all of the column names that contain contig and collapse them into a comma separated string
loci <-  str_c(names(select(noregeno, contains("contig"))), collapse = ",")
write_lines(loci, path = str_c("data/", Sys.Date(), "noregeno.gen", sep = ""), append = T)

pop <- "pop"
write_lines(pop, path = str_c("data/", Sys.Date(), "noregeno.gen", sep = ""), append = T)

gene <- vector()
sample <- vector()
for (i in 1:nrow(noregeno)){
  gene[i] <- str_c(select(noregeno[i,], contains("contig")), collapse = " ")
  sample[i] <- str_c(noregeno$names[i], gene[i], sep = ", ")
  write_lines(sample[i], path = str_c("data/", Sys.Date(), "noregeno.gen", sep = ""), append = T)
}
