Find individual fish in the database
================

This notebook finds fish that were tag recaptured and genetically
recaptured and connects all of the observations of those fish, assigning
them an individual id (fish\_indiv) so all rows involving one fish can
be found.

Find all fish that have been genetically or tag recaptured

``` r
# load the table of all fish with genids and tag ids
fish_obs <- read_csv("https://github.com/pinskylab/genomics/raw/master/data/fish-obs.csv", col_types = cols(
  fish_table_id = col_double(),
  sample_id = col_character(),
  tag_id = col_character(), # because numeric uses scientific notation and loses the end numbers
  gen_id = col_double(),
  fish_indiv = col_character() # because numeric uses scientific notation and loses the end numbers
))

# assign a fish_indiv to each fish
fish_inds <- fish_obs %>% 
  # if a row has a gen_id but not a tag_id
  mutate(fish_indiv = ifelse(is.na(tag_id), gen_id, NA)) %>% 
  # if a row has a tag_id but not a gen_id
  mutate(fish_indiv = ifelse(is.na(gen_id), tag_id, fish_indiv)) %>% 
# for fish that have both a tag_id and gen_id, use gen_id
  mutate(fish_indiv = ifelse(!is.na(gen_id) & !is.na(tag_id), gen_id, fish_indiv))

# loop to make sure all recaptures of a fish get the same fish_indiv 
for_processing <- fish_inds
new_fish_indv <- tibble()
while(nrow(for_processing) >= 1){
  # all rows that belong to this fish_table_id
  fti <- for_processing %>% 
    filter(!is.na(fish_table_id), 
      fish_table_id == for_processing$fish_table_id[1])
  
 # all rows that belong to the fish_indiv in the above table (and then join the above table)
  f_indiv <- for_processing %>% 
    filter(!is.na(fish_indiv), 
      fish_indiv == fti$fish_indiv) %>% 
    rbind(fti) %>% 
    distinct
  
  # all rows that contain these tag ids in the above table (and then join the above table)
  ti <- for_processing %>% 
    filter(!is.na(tag_id),
      tag_id %in% f_indiv$tag_id) %>% 
    rbind(f_indiv) %>% 
    distinct
  
  # all rows that contain these gen_ids in the above table (and then join the above table)
  gi <- for_processing %>% 
    filter(!is.na(gen_id), 
      gen_id %in% ti$gen_id) %>% 
    rbind(ti) %>% 
    distinct
  
  # what is the lowest indiv id in the table?
  min_indv <- min(gi$fish_indiv)
  
  # make all indv ids the same (the lowest)
  one_indiv <- gi %>% 
    mutate(fish_indiv = min_indv)
  
  # remove these rows from the for_processing table
  for_processing <- anti_join(for_processing, one_indiv, by = "fish_table_id")
  
  new_fish_indv <- rbind(new_fish_indv, one_indiv) %>% 
    distinct()

}

# test - are there repeat fish_table_ids - should return 0 rows
test <- new_fish_indv %>% 
  group_by(fish_table_id) %>% 
  filter(n()> 1)
rm(test)

save_loc <- here::here("data", "fish-obs.rds")
saveRDS(new_fish_indv, file = save_loc)

# save Rdata files as csv for easy reading from github
# new_fish_indv <- readRDS(save_loc)
write_csv(new_fish_indv, here("data", "fish-obs.csv"))

new_fish_indv
```
