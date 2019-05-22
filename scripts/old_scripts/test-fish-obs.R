pacman::p_load(tidyverse, here, clownfish, install=FALSE)


# because the myconfig db connection is still not working
source("~/Documents/clownfish-pkg/R/db_connections.R")
leyte <- read_db("Leyte")
lab <- read_db("Laboratory")

save_loc <- here::here("data", "fish-obs.Rdata")
fish_obs <- readRDS(file = save_loc)

test <- fish_obs %>% 
  filter(!is.na(gen_id)) %>% 
  distinct(fish_indiv)

norecaps <- read_genepop(here::here("data", "seq33-03_norecap.gen")) %>% 
  rename(ligation_id = names)

genepop_fish <- samp_from_lig(norecaps) %>% 
  left_join(fish_obs) 

genepop_fish %>% 
  group_by(fish_indiv) %>% 
  filter(n() > 1)



