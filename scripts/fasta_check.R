# check the N's in the fasta file to determine if they are SNPs and if they are SNPs, find the major allele and replace the N with allele
source("scripts/gen_helpers.R")
library(stringr)
library(tidyr)

# locate data
genfile <- "data/seq17_03g95maf2q30dp15.gen"
fst <- "data/reference.fasta"

# read in data
genepop <- read_genepop(genfile)
fasta <- readLines(fst)

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



  

# count the number of SNPs per contig - can do this on the genepop
count_snps <- list_of_snps %>% 
  group_by(contig) %>% 
  summarise(num_snps = n())

mean_snps <- count_snps %>% 
  summarise(mean = mean(num_snps))

