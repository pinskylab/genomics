# find the work history of a sample
source("scripts/gen_helpers.R")

# from ligation_id ####

# pulling ligation_ids from a pre-existing table called trouble
lab <- read_db("Laboratory")

# get digest info
lig <- lab %>%
  tbl("ligation") %>% 
  collect() %>% 
  filter(ligation_id %in% trouble$ligation_id) %>% # here could enter anything
  select(ligation_id, digest_id)

# get extract info
dig <- lab %>%
  tbl("digest") %>% 
  collect() %>% 
  filter(digest_id %in% lig$digest_id) %>% 
  select(digest_id, extraction_id)

lig <- left_join(lig, dig, by = "digest_id")
rm(dig)

# get sample info
extr <- lab %>% 
  tbl("extraction") %>% 
  collect() %>% 
  filter(extraction_id %in% lig$extraction_id) %>% 
  select(extraction_id, sample_id)

lig <- left_join(lig, extr, by = "extraction_id")
rm(extr)  
