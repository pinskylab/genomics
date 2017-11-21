# make sure all seq16_03 kept sites are in seq17_03 kept sites
library(tidyr)
library(dplyr)
library(stringr)

# read lines
eight <- readLines("data/seq16_03_SNPs.txt")

eight <- data.frame(eight) %>% 
  separate(eight, c("locus", "position"), " ")%>%
  select(-position) %>%
  distinct(locus)

# comment out to get contigs for fasta, uncomment for file for filtering to make a genepop
# saveRDS(eight, "data/809snps.Rdata")



ten <- read.csv("data/533snpsformybaits.csv", stringsAsFactors = F) %>% 
  # select(-snp) %>% # comment out to get contigs for fasta, uncomment for file for filtering to make a genepop
  mutate(contig = str_replace(contig, "( )(.+)", "\\2")) %>% 
  distinct(contig) %>% 
  rename(locus = contig)
  
  # str_detect(ten$locus, "( )(.+)")

# remove the loci from ten that are in eight
ten <- anti_join(ten, eight, by = "locus")

# how many of eight are in ten?
test <- eight %>% 
  filter(locus %in% ten$locus)

# how many of 10 are in 8?
test <- ten %>% 
  filter(ten %in% eight$locus)

# create a master list of contigs
full <- rbind(eight, ten)

write.csv(full, "data/contigs_for_mybaits.txt", row.names = F, quote = F)
