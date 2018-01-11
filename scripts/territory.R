# find recaptures and if they were caught on different anemones
library(lubridate)
library(geosphere)
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
  select(anem_id, anem_obs, anem_table_id, obs_time, dive_table_id) %>% 
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

# library(ggplot2)
# ggplot(data = fish) +
#   geom_bar(mapping = aes(x = at_home, 
#     fill = at_home,
#     xlabs = NULL, 
#     ylabs = NULL))+
#   ggtitle("Number of times a fish is caught on the same or different anemone")
  
# looks like it is worth investigating territory sizes

# remove fish with unknown anemones (-9999 or ????) or fish that don't move
fish <- fish %>% 
  filter(anem_id != "-9999" & anem_id != "????" & at_home != "same anemone")

# for which fish did this leave only one observation?
one <- fish %>% 
  group_by(fish) %>% 
  summarize(obs = n()) %>% 
  filter(obs == 1)
# remove those fish from the analysis
fish <- fish %>% 
  filter(!fish %in% one$fish)

# # to use Allison's anemid_latlong data, need these 2 variables - not working
# # latlondata is the GPX table from the database
# latlondata <- leyte %>% tbl("GPX") %>% collect(n = Inf) # 264408
# 
# ati <- fish$anem_table_id
# 
# debugonce(anemid_latlong)
# anem <- anemid_latlong(ati, latlondata)

# find the date info and gps unit for this anem observation
date <- leyte %>% 
  tbl("diveinfo") %>% 
  select(dive_table_id, date, gps, site) %>% 
  collect() %>% 
  filter(dive_table_id %in% fish$dive_table_id)

#join with anem info, format obs time
fish <- left_join(fish, date, by = "dive_table_id") %>% 
  separate(obs_time, into = c("hour", "minute", "second"), sep = ":") %>% #this line and the next directly from Michelle's code
  mutate(gpx_hour = as.numeric(hour) - 8)

# find the lat long for this anem observation
lat <- leyte %>%
  tbl("GPX") %>%
  mutate(gpx_date = date(time), 
    gpx_hour = hour(time), 
    minute = minute(time), 
    second = second(time)
    ) %>%
  filter(gpx_date %in% fish$date,
    gpx_hour %in% fish$gpx_hour, 
    minute %in% fish$minute) %>% 
  collect(n=Inf)
lat <- lat %>%
  mutate(lat = as.numeric(lat), 
    lon = as.numeric(lon)) %>% 
  select(-second) #remove the seconds from the table


fish <- fish %>% 
  mutate(minute = as.numeric(minute))
# attach lat to anems - this should create 4 rows for every observation (475 *4 = 1900)
fish <- left_join(fish, lat, by = c("gps" = "unit", "date" = "gpx_date", "gpx_hour", "minute"))
fish <- distinct(fish)

# create a list of remaining fish ids
x <- unique(fish$fish)

# create an empty data frame
hold <- data.frame()
for (i in x){
  # create a table of the fish that match i
  y <- fish %>% 
    filter(fish == i)
  # remove those fish from the fish table
  fish <- anti_join(fish, y, by = "fish_table_id")
  # create a 
  
}
  
  


  


