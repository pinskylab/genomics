# successful ligations
source("scripts/gen_helpers.R")

yes <- samples %>% 
  select(sample_id, ligation_id)

# which samples have been extracted that are not on the yes list?
lab <- read_db("Laboratory")

extr <- lab %>%
  tbl("extraction") %>% 
  collect()
#4403 samples have been extracted

extr <- extr %>% 
  filter(!sample_id %in% yes$sample_id, # 2714 are not in the yes table
    grepl("APCL", sample_id)) # 1843 of those are A. clarkii

# how many of those have been digested?
dig <- lab %>% 
  tbl("digest") %>% 
  collect

digs <- dig %>% 
  filter(extraction_id %in% extr$extraction_id) 
# 1723 failed samples have been digested

no_digs <- extr %>% 
  filter(!extraction_id %in% dig$extraction_id) %>% 
  filter(extraction_id <= "E2864" | extraction_id >= "E2875") # these were contaminated


# samples that have too low conc to be digested normally, - try low level digest
low <- no_digs %>% 
  filter(quant < 100)

no_digs <- anti_join(no_digs, low, by = "extraction_id")

# samples that are still being processed
no_digs

write.csv(yes, "data/successful_ligations.csv", row.names = F)
