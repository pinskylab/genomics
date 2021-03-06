# check the N's in the fasta file to determine if they are SNPs and if they are SNPs, find the major allele and replace the N with allele
source("scripts/gen_helpers.R")
library(stringr)
library(tidyr)

# locate data
# genfile <- "data/seq17_03g95maf2q30dp15.gen"
# genfile <- "data/seq17dp15maf10.gen"
# genfile <- "data/seq17dp15maf5.gen"
genfile <- "data/seq17mybaits.gen"
# fst <- "data/reference.fasta"

# read in data
genepop <- read_genepop(genfile)
# fasta <- readLines(fst)

# format data

# pull contig names from genepop 
contig <- names(genepop)
# convert to data frame & remove the "names" name
list_of_snps <- data_frame(contig) %>% 
  filter(contig != "names")
# separate the names into contig and snp &  rejoin the names
list_of_snps <- list_of_snps %>%
  separate(contig, c("contig", "and1", "and2","snp"), sep = "_")%>%
  unite(contig, c(contig, and1, and2))

# write.csv(list_of_snps, "data/533snpsformybaits.csv", row.names = F, quote = F)  


# count the number of SNPs per contig - can do this on the genepop
count_snps <- list_of_snps %>% 
  group_by(contig) %>% 
  summarise(num_snps = n())

mean_snps <- count_snps %>% 
  summarise(mean = mean(num_snps))

#211 base pairs

test <- count_snps %>% 
  mutate(percent = num_snps/211) %>% 
  filter(percent < 0.05)

# to make a list of snps to select in vcftools, combine list_of_snps from this run and the 809 snps
saveRDS(list_of_snps, "data/533snps_list.Rdata")

first <- readRDS("data/809snps.Rdata") %>% 
  rename(contig = locus, 
    snp = position)
second <- readRDS("data/533snps_list.Rdata")

full <- rbind(first, second)

# get rid of white space before some names
str_detect(contig, "( )(dDocent.+)")  

full <- full %>% 
  mutate(contig = str_replace(contig, "( )(dDocent.+)", "\\2"))

full <- full %>% 
  arrange(contig)
  

write.csv(full, "data/full_snps_list.csv", row.names = F, quote = F)


