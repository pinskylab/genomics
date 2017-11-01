# This code is intended to be used immediately after the dDocent pipeline generates the genepop file in order to correct for any naming issues due to lab error.

# for every line in the genepop file, need to find the sample ID in the rosetta stone file and, if the reason field is not blank, amend the sample ID to include the updated sample ID.
# 4/29/2016 MRS changing the code so that the output is in Pinsky Lab format (APCL15_203), not dDocent format (APCL_15203L658)

# set the working directory

# Mr. Whitmore
setwd('/Users/michelle/Google Drive/Pinsky Lab/Cervus/Michelle\'s R codes/Genetics/rosetta stone genepop')
source('/Users/michelle/Google Drive/Pinsky Lab/Cervus/Michelle\'s R codes/Genetics/code/readGenepop_space.R')

# # Lightning
# # setwd('/Users/macair/Documents/Philippines/Genetics/rosetta stone genepop')
# setwd('/Users/macair/Google Drive/Pinsky Lab/Cervus/Michelle\'s R codes/Genetics/rosetta stone genepop')
# source('/Users/macair/Google Drive/Pinsky Lab/Cervus/Michelle\'s R codes/Genetics/code/readGenepop_space.R')
# source('/Users/macair/Documents/Philippines/Genetics/code/readGenepop_space.R')
# source('/Users/macair/Documents/Philippines/Genetics/code/writeGenepop.R')

library(RCurl)

# locate the genepop file and read as data frame
# genfile <- 'DP10g95-2.genepop'
genfile <- 'DP10g95maf2.genepop' #SEQ03-09 - reduced # of SNPS to 1012
# genfile <- '2016_03_21_DP10g95c9maf05.genepop' #SEQ03-13
genedf <- readGenepop(genfile)
genedf[,1] <- NULL # remove the pop column from the data file

# Change the names of the samples from dDocent format to Pinsky Lab format - substr allows to select specific characters to pull out of names string to reconstruct Sample ID
for(a in 1:nrow(genedf)){
  genedf$names[a] <- paste('APCL', substr(genedf$names[a],6,7), "_", substr(genedf$names[a],8,15), sep="")
}

# open the rosetta stone
library(googlesheets)
# gs_auth(new_user = TRUE) # run this if having authorization problems
mykey <- '1yhMEwka68eIAMbFKG4-KFWbmNb0JqzlML91mlX8mWj4' # for Rosetta Stone file
stone <-gs_key(mykey)
rosetta <-gs_read(stone, ws='Rosetta')

# merge the two dataframes so that sample IDs match up
largedf <- merge(genedf, rosetta[,c('names', 'SampleID', 'Reason')], all.x = TRUE)

# look for missing names
setdiff(genedf$names, largedf$names)


# # original for loop that is more easily done with the index line below
# for(i in 1:nrow(largedf)){
# if !is.na(largedf$Reason){
# largedf$names[i] <- paste (largedf$names[i], largedf$Sample.ID[i], sep='_')
# }
# }

# Append mislabeled samples with the correct sample ID
# create an index of rows where the reason is not na and for the names in that index [inds], paste the sample id on with a _ in between
inds <- !is.na(largedf$Reason)
largedf$names[inds] <- paste(largedf$names[inds], largedf$SampleID[inds], sep='_')

# Build the genepop components
msg <- c("This genepop file was generated using a script called rosetta_genepop.R written by Michelle Stuart with help from Malin Pinsky")

# create a list of loci names, separated by commas

# loci <- toString(names(largedf[,2:2621])) # creates a space before the of the locus names - not good

loci <- paste(names(largedf[,2:(ncol(largedf)-2)]), collapse =",") # sep is not comma separating, makes many lines instead of one line, collapse= ", " makes too many spaces between values, collapse="," is one space


gene <- vector()
sample <- vector()
for (i in 1:nrow(largedf)){
  # geno[i] <- toString(largedf[i,1:2621], sep = "\t")
  gene[i] <- paste(largedf[i,2:(ncol(largedf)-2)], collapse = " ")
  sample[i] <- paste(largedf[i,1], gene[i], sep = ", ")
}

out <- c(msg, loci, 'pop', sample)

write.table(out, file = paste(Sys.Date(), 'renamed.genepop', sep = '_'), row.names=FALSE, quote=FALSE, col.names=FALSE) # won't let me use header=FALSE - should be using col.names


