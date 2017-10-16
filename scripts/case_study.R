# find anemones that have a pair of fish and see if those fish had babies
source("scripts/gen_helpers.R")

# get fish and anemone info
leyte <- read_db("Leyte")

# all anemone observations
anem <- leyte %>% 
  tbl("anemones") %>% 
  select(-contains("depth"), -anem_dia, -anem_sample_id, -notes, -contains("corr")) %>% 
  collect()

# all APCL observations even if they weren't sampled
fish <- leyte %>% 
  tbl("clownfish") %>% 
  filter(fish_spp == "APCL") %>% 
  select(-contains("corr"), -notes, -fin_id, -fish_spp) %>% 
  collect()

# merge these tables # number of rows increases
big <- left_join(anem, fish, by = c("anem_table_id", "collector"))

# remove any fish smaller than 7cm and any unknown anem_ids
big <- big %>% 
  filter(size >= 7) %>% 
  filter(!is.na(anem_id))

# find anemones that have had more than one fish observation > 7cm
multi <- big %>% 
  group_by(anem_id) %>% 
  summarise(
    count = n()
  ) %>% 
  filter(count > 1)
  
# use the above list to narrow down the big list
big <- big %>% 
  filter(anem_id %in% multi$anem_id)


# first individual case
# anem_id 289, 2 large fish were observed in 2013 - APCL13_516 and APCL13_517.
# find out if these fish have had labwork done
fish <- lig_from_samp(c("APCL13_520", "APCL13_523"))

# take a look and see if they were genotyped

# this couple were not both genotyped.