# remove fish from genepop

# I want to remove any fish from  years prior to the one that has my parent candidates
source("scripts/gen_helpers.R")

# genepop that has regenotypes removed
genfile <- "data/2017-10-16noregeno.gen"

# read in the genepop
gendf <- read_gen_sp(genfile)

# remove commas from the ligation_ids
gendf <- gendf %>% 
  mutate(names = stringr::str_replace(names, ",", "")) %>% 
  rename(ligation_id = names)

# attach sample_ids
temp <- samp_from_lig(gendf)

gendf <- left_join(gendf, temp, by = "ligation_id") 

gendf <- gendf %>% 
  filter(!grepl("APCL12", gendf$sample_id)) %>%  # remove any samples from 2012
  select(-sample_id)



# 4) Output genepop file --------------------------------------------------

# # Build the genepop components
# msg <- c("This genepop file was generated using a script called remove_fish_from_gen.R written by Michelle Stuart")
# readr::write_lines(msg, path = str_c("data/", Sys.Date(), "no12.gen", sep = ""), append = F)
# 
# # find all of the column names that contain contig and collapse them into a comma separated string
# loci <-  str_c(names(select(gendf, contains("contig"))), collapse = ",")
# readr::write_lines(loci, path = str_c("data/", Sys.Date(), "no12.gen", sep = ""), append = T)
# 
# pop <- "pop"
# readr::write_lines(pop, path = str_c("data/", Sys.Date(), "no12.gen", sep = ""), append = T)
# 
# gene <- vector()
# sample <- vector()
# for (i in 1:nrow(gendf)){
#   gene[i] <- str_c(select(gendf[i,], contains("contig")), collapse = " ")
#   sample[i] <- str_c(gendf$ligation_id[i], gene[i], sep = " ") 
#   readr::write_lines(sample[i], path = str_c("data/", Sys.Date(), "no12.gen", sep = ""), append = T)
# }

# output as cervus style csv ####

# add a pop column
gendf <- gendf %>% 
  mutate(Population = "Pop1") %>% 
  rename(ID = ligation_id) %>% 
  select(Population, ID, everything())

# separating out the loci looks like a real pain
loci <- names(gendf)
for(i in 3:length(loci)){
  ????? # need to separate each column into A and B and remove the zeros
}


# test if github will work after transfer of ownership???

# testing again
