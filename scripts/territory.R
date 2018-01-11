# find recaptures and if they were caught on different anemones

source("scripts/gen_helpers.R")

# find recaptures
leyte <- read_db("Leyte")

# narrow down the columns involved
fish <- leyte %>%
  tbl("clownfish") %>% 
  select(fish_table_id, anem_table_id, size, color, cap_id, recap, tag_id) %>% 
  filter(!is.na(cap_id) | recap == "Y") %>% 
  collect()

# find any initial tags for the tag recaptures in caps and add them to caps
tag <- leyte %>%
  tbl("clownfish") %>%
  collect() %>% 
  select(fish_table_id, anem_table_id, size, color, cap_id, recap, tag_id) %>% 
  filter(tag_id %in% fish$tag_id & !is.na(tag_id))
fish <- rbind(fish, tag)
fish <- distinct(fish)
rm(tag)

# find a fish ####
# a fish could be tracked by a cap_id or a tagid and some fish with tags have cap_ids.  Find those with both first

# iterate through fish and assign a number
# tests:
# which(fish$cap_id == 15)
# which(fish$tag_id == 985153000403605)
# i <- 358
# create a blank column for iterating
fish$fish <- NA
fti <- fish$fish_table_id
for(i in fti){
  # find the row that contains the fti[i]
  w <- filter(fish, fish_table_id == i) 
  
  if (is.na(w$fish[1])){
    if(!is.na(w$cap_id[1])){
      x <- fish %>% 
        filter(cap_id == w$cap_id[1])
      if(sum(!is.na(x$tag_id)) > 0){
        y <- x$tag_id[!is.na(x$tag_id)]
        z <- fish %>% 
          filter(tag_id == y)
        x <- rbind(x,z)
        x <- distinct(x)
      }
      x <- x %>% 
        mutate(fish = i)
      fish <- anti_join(fish, x, by = "fish_table_id")
      fish <- rbind(fish, x)
    }else{
      x <- fish %>% 
        filter(tag_id == w$tag_id[1])
      x <- x %>% 
        mutate(fish = i)
      fish <- anti_join(fish, x, by = "fish_table_id")
      fish <- rbind(fish, x)
    } 
  }
}
rm(i, w, x, y, z)

# assign anem_id and anem_obs to fish
anem <- leyte %>% 
  tbl("anemones") %>% 
  collect() %>% 
  select(anem_id, anem_obs, anem_table_id) %>% 
  filter(anem_table_id %in% fish$anem_table_id)
fish <- left_join(fish, anem, by = "anem_table_id")
rm(anem)

# anemones weren't recorded for all of the fish in 2012, note this with a -9999 for this table only - none of them had a value in the table
fish <- fish %>%
  mutate(anem_id = ifelse(anem_table_id <= 644, -9999, anem_id))
# fish caught away from anemone/unknown anemone are ????
fish <- fish %>% 
  mutate(anem_id = ifelse(is.na(anem_id), "????", anem_id))

# create a column to categorize the data
fish <- mutate(fish, at_home = NA) 

for (i in unique(fish$fish)){
  x <- fish %>% 
    filter(fish == i)
  fish <- anti_join(fish, x, by = "fish_table_id")
  if (is.na(x$at_home[1])){
    y <- nrow(distinct(x, anem_obs))
    x <- x %>% 
      mutate(at_home = ifelse(y > 1, "different anemone", "same anemone"))
  }
  fish <- rbind(fish, x)
}



library(ggplot2)
ggplot(data = fish) +
  geom_bar(mapping = aes(x = at_home, 
    fill = at_home,
    xlabs = NULL, 
    ylabs = NULL))+
  ggtitle("Number of times a fish is caught on the same or different anemone")
  
# # change the fish numbers from their fti to a number - cant get this to work
# x <- unique(fish$fish_id)
# for (j in 1:length(x)){
#   for (i in x){
#     y <- fish$fish_id[fish$fish_id == i]
#     fish <- anti_join(fish, y, by = "fish_table_id")
#     y <- mutate(y, fish_id = j)
#     fish <- rbind(fish, y)
#    }
#   }
  


  


