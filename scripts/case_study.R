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
  filter(anem_id %in% multi$anem_id) %>% 
  select(anem_id, anem_obs, size, color, sample_id, cap_id, recap, everything())

# define male/female
big <- big %>% 
  mutate(gender = ifelse(grepl("O", color), "male", "female")) %>%  # assign gender
  filter(!is.na(sample_id)) %>%  # remove any missing sample_ids
  mutate(year = substr(sample_id, 5,6)) # add a year column

  # make a list of anemones
  anems <- big %>% 
    select(anem_id) %>% 
    distinct()
  
# get a list of sample_ids of the fish present
samps <- big %>% select(sample_id)

# get ligation_ids for those fish
ligs <- lig_from_samp(samps$sample_id)

# attach lab record to fish - some fish have more than one ligation_id so the list grows
big <- left_join(big, ligs, by = "sample_id")

# which fish do not have ligation_ids
need_work <- big %>% 
  filter(is.na(ligation_id)) %>% 
  select(sample_id) %>% 
  distinct
# write.csv(need_work, file = "data/fish_need_work.csv")

# remove those fish from the list
big <- anti_join(big, need_work, by = "sample_id")

# rank the fish and get the biggest male and biggest female for each anemone
# males
males <- data_frame()
for (i in 1:nrow(anems)){
  temp <- big %>% 
    filter(anem_id == anems$anem_id[i], gender == "male")
  j <- min_rank(desc(temp$size))
  males <- rbind(males, temp[j, ])
}

# females
females <- data_frame()
for (i in 1:nrow(anems)){
  temp <- big %>% 
    filter(anem_id == anems$anem_id[i], gender == "female")
  j <- min_rank(desc(temp$size))
  females <- rbind(females, temp[j, ])
}

# # separate into years so that each year parent list includes that year and all previous years
# yr <- c("2012", "2013", "2014", "2015", "2016", "2017")
# 
# for (i in length(yr)){
#   
#   
# }



# first individual case
# anem_id 289, 2 large fish were observed in 2013 - APCL13_516 and APCL13_517.
# find out if these fish have had labwork done
fish <- lig_from_samp(c("APCL13_520", "APCL13_523"))

# take a look and see if they were genotyped

# this couple were not both genotyped.