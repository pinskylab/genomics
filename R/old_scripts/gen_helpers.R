# helper functions for working with this repository
library(dplyr)
library(tidyr)
library(stringr)

# read_genepop ####
#' read a genepop generated for ONE population
#' @export
#' @name read_genepop
#' @author Michelle Stuart
#' @param x = filename
#' @examples 
#' genedf <- read_genepop("data/seq17_03_58loci.gen")

# only works if Genepop has loci listed in 2nd line (separated by commas), has individual names separated from genotypes by a comma, and uses spaces between loci
# return a data frame: col 1 is individual name, col 2 is population, cols 3 to 2n+2 are pairs of columns with locus IDs
read_genepop <-  function(filename){
  # get all of the data
  if(readLines(filename, n=3)[[3]] != "pop"){
  dat <- read.table(filename, skip = 2, sep = " ", stringsAsFactors = F, colClasses = "character") 
  }else{
    dat <-  read.table(filename, skip = 3, sep = " ", stringsAsFactors = F, colClasses = "character")
  }
  
  # get the header info
  info <- readLines(filename, n = 2) 
  
  # define the loci names
  loci <- unlist(strsplit(info[2], split=','))    
  
  # rename the dat columns
  names(dat) <- c("names", loci)
  
  # if there is a comma, remove it
  dat$names <- str_replace(dat$names, ",", "")
  
  return(dat)	
  
}


# samp_from_lig ####
#' find sample id from ligation id
#' @export
#' @name samp_from_lig
#' @author Michelle Stuart
#' @param x = table_name where ligation ids are located
#' @examples 
#' c5 <- samp_from_lig(genedf)


samp_from_lig <- function(table_name){
  
  lab <- read_db("Laboratory")
  
  # connect ligation ids to digest ids
  lig <- lab %>% 
    tbl("ligation") %>% 
    collect() %>% 
    filter(ligation_id %in% table_name$ligation_id) %>% 
    select(ligation_id, digest_id)
  
  # connect digest ids to extraction ids
  dig <- lab %>% 
    tbl("digest") %>% 
    collect() %>% 
    filter(digest_id %in% lig$digest_id) %>% 
    select(extraction_id, digest_id)
  
  extr <- lab %>% 
    tbl("extraction") %>% 
    collect() %>% 
    filter(extraction_id %in% dig$extraction_id) %>% 
    select(extraction_id, sample_id)
  
  mid <- left_join(lig, dig, by = "digest_id")
  samp <- left_join(extr, mid, by = "extraction_id") %>% 
    select(sample_id, ligation_id)
  
  return(samp)
}

# write_db ####
#' access db with intent to change it
#' @export
#' @name write_db
#' @author Michelle Stuart
#' @param x = which db?
#' @examples 
#' db <- write_db("Leyte")

write_db <- function(db_name){
  library(RMySQL)
  db <- dbConnect(MySQL(), dbname = db_name, default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
  return(db)
}

# read_db ####
#' views all of the fish recaptured at a given site
#' @export
#' @name read_db
#' @author Michelle Stuart
#' @param x = which db?
#' @examples 
#' db <- read_Db("Leyte")

read_db <- function(db_name){
  
  db <- src_mysql(dbname = db_name, default.file = path.expand("~/myconfig.cnf"), port = 3306, create = F, host = NULL, user = NULL, password = NULL)
  return(db)
}

# lig_from_samp ####
#' views all of the fish recaptured at a given site
#' @export
#' @name lig_from_samp
#' @author Michelle Stuart
#' @param x = list of sample_ids
#' @examples 
#' fish <- lig_from_samp(c("APCL13_516", "APCL13_517"))

lig_from_samp <- function(sample_ids){
  
  lab <- read_db("Laboratory")
  
  extr <- lab %>% 
    tbl("extraction") %>% 
    filter(sample_id %in% sample_ids) %>% 
    select(sample_id, extraction_id) %>% 
    collect()
  
  dig <- lab %>% 
    tbl("digest") %>% 
    filter(extraction_id %in% extr$extraction_id) %>%
    select(extraction_id, digest_id) %>% 
    collect()
  
  lig <- lab %>% 
    tbl("ligation") %>% 
    filter(digest_id %in% dig$digest_id) %>%
    select(ligation_id, digest_id) %>% 
    collect()
  
  mid <- left_join(extr, dig, by = "extraction_id")
  lig <- left_join(mid, lig, by = "digest_id") 
  
  return(lig)
}


# samp_to_site ####
#' find site for a sample 
#' @export
#' @name samp_to_site
#' @author Michelle Stuart
#' @param x = sample_id
#' @examples 
#' new <- samp_to_site(sample)

samp_to_site <- function(sample) {
  leyte <- read_db("Leyte")
  fish <- leyte %>% 
    tbl("clownfish") %>% 
    filter(sample_id %in% sample) %>% 
    select(sample_id, anem_table_id) %>% 
    collect()
  anem <- leyte %>% 
    tbl("anemones") %>% 
    filter(anem_table_id %in% fish$anem_table_id) %>% 
    select(anem_table_id, anem_id, dive_table_id) %>% 
    collect()
  fish <- left_join(fish, anem, by = "anem_table_id")
  rm(anem)
  dive <- leyte %>% 
    tbl("diveinfo") %>% 
    filter(dive_table_id %in% fish$dive_table_id) %>% 
    select(dive_num, dive_table_id, site) %>% 
    collect()
  fish <- left_join(fish, dive, by = "dive_table_id")
  rm(dive)
  return(fish)
  
}

# lig_from_samp ####
#' views all of the fish recaptured at a given site
#' @export
#' @name lig_from_samp
#' @author Michelle Stuart
#' @param x = list of sample_ids
#' @examples 
#' fish <- lig_from_samp(c("APCL13_516", "APCL13_517"))

lig_from_samp <- function(sample_ids){
  
  lab <- read_db("Laboratory")
  
  extr <- lab %>% 
    tbl("extraction") %>% 
    filter(sample_id %in% sample_ids) %>% 
    select(sample_id, extraction_id) %>% 
    collect()
  
  dig <- lab %>% 
    tbl("digest") %>% 
    filter(extraction_id %in% extr$extraction_id) %>%
    select(extraction_id, digest_id) %>% 
    collect()
  
  lig <- lab %>% 
    tbl("ligation") %>% 
    filter(digest_id %in% dig$digest_id) %>%
    select(ligation_id, digest_id) %>% 
    collect()
  
  mid <- left_join(extr, dig, by = "extraction_id")
  lig <- left_join(mid, lig, by = "digest_id") 
  
  return(lig)
}

# anemid_latlong ####
#' #anem.table.id is one anem_table_id value, latlondata is table of GPX data
#from database (rather than making the function call it each time); will need
#to think a bit more clearly about how to handle different locations read for
#different visits to the same anem_id (or different with same anem_obs); for
#now, just letting every row in anem.Info get a lat-long
#' @export
#' @name anemid_latlong
#' @author Michelle Stuart
#' @param x = anem.table.id
#' @param y = latlondata
#' @examples 
#' temp <- anemid_latlong(anem.table.id, latlondata)

anemid_latlong <- function(anem.table.id, latlondata) { 
 
  
  #find the dive info and time for this anem observation
  dive <- leyte %>%
    tbl("anemones") %>%
    select(anem_table_id, obs_time, dive_table_id, anem_id) %>%
    collect() %>%
    filter(anem_table_id %in% anem.table.id)
  
  # find the date info and gps unit for this anem observation
  date <- leyte %>% 
    tbl("diveinfo") %>% 
    select(dive_table_id, date, gps, site) %>% 
    collect() %>% 
    filter(dive_table_id %in% dive$dive_table_id)
  
  #join with anem info, format obs time
  anem <- left_join(dive, date, by = "dive_table_id") %>% 
    separate(obs_time, into = c("hour", "minute", "second"), sep = ":") %>% #this line and the next directly from Michelle's code
    mutate(gpx_hour = as.numeric(hour) - 8)
  
  # find the lat long for this anem observation
  latloninfo <- latlondata %>%
    filter(date %in% anem$date) %>% 
    separate(time, into = c("hour", "minute", "second"), sep = ":") %>% 
    filter(as.numeric(hour) == anem$gpx_hour & as.numeric(minute) == anem$minute) 
  
  latloninfo$lat <- as.numeric(latloninfo$lat)
  latloninfo$lon <- as.numeric(latloninfo$lon)
  
  #often get multiple records for each anem_table_id (like if sit there for a while) - so multiple GPS points for same visit to an anemone, not differences across visits
  dups_lat <- which(duplicated(latloninfo$lat)) #vector of positions of duplicate values
  dups_lon <- which(duplicated(latloninfo$lon))
  
  #either take the mean of the lat/lon readings or the duplicated values, depending if there are duplicate points
  if(length(dups_lat) == 0) { #if all latitude points are different
    anem$lat <- round(mean(latloninfo$lat), digits = 5) #take the mean of the latitude values (digits = 5 b/c that is what Michelle had)
    anem$lon <- round(mean(latloninfo$lon), digits = 5) #take the mean of the longitude values
    #lat <- round(mean(latloninfo$lat), digits = 5) 
    #lon <- round(mean(latloninfo$lon), digits = 5)
  }else{
    anem$lat <- latloninfo$lat[dups_lat[1]] #if are duplicates, take the value of the first duplicated point
    anem$lon <- latloninfo$lon[dups_lon[1]]
    #lat <- latloninfo$lat[dups_lat[1]] #if are duplicates, take the value of the first duplicated point
    #lon <- latloninfo$lon[dups_lon[1]]
  }
  
  return(anem)
  
}

# full_meta ####
#' add field data for a sample 
#' @export
#' @name full_meta
#' @author Michelle Stuart
#' @param x = a table that contains a column called sample_ids
#' @examples 
#' new <- samp_to_field_meta(lost$sample_id)

full_meta <- function(sample_ids, db){
  samps <- db %>% 
    tbl("clownfish") %>% 
    filter(sample_id %in% sample_ids) %>% 
    select(fish_table_id, anem_table_id, size, sample_id, color, gen_id, recap, tag_id, fish_obs_time, collector, fish_notes) %>% 
    collect() %>% 
    rename(fish_collector = collector)
  
  anem <- db %>% 
    tbl("anemones") %>% 
    filter(anem_table_id %in% samps$anem_table_id) %>% 
    select(anem_table_id, dive_table_id, anem_obs_time, anem_id, anem_obs, collector, anem_notes) %>% 
    collect() %>% 
    rename(anem_collector = collector)
  
  samps <- left_join(samps, anem, by = "anem_table_id")
  rm(anem)
  dive <- db %>% 
    tbl("diveinfo") %>% 
    filter(dive_table_id %in% samps$dive_table_id) %>% 
    select(dive_table_id, dive_num, date, site, gps, divers) %>% 
    collect()
  
  samps <- left_join(samps, dive, by = "dive_table_id")
  rm(dive)
  return(samps)
}

# check_id_match ####
#' compare individuals that appear to be genetic mark recaptures
#' @export
#' @name check_id_match
#' @author Michelle Stuart
#' @param x = table_name
#' @examples 
#' temp <- check_id_match(row_number, table_of_matches)

check_id_match <- function(row_number, table_of_matches){
  x <- table_of_matches %>% 
    filter(first_id == table_of_matches$first_id[row_number])
  first <- x %>% 
    select(contains("first"))
  second <- x %>% 
    select(contains("second"))
  names(first) <- substr(names(first), 7, 20)
  names(second) <- substr(names(second), 8, 25)
  y <- rbind(first, second) %>% 
    distinct() %>% 
    mutate(year = substr(sample_id, 5,6), 
           size = as.numeric(size)) %>% 
    arrange(year)
  return(y)
}

# create_genid ####
#' add a gen_id to a sample
#' @export
#' @name create_genid
#' @author Michelle Stuart
#' @param x = table_name
#' @examples 
#' updated_table <- create_genid(table_of_candidates)

create_genid <- function(table_of_candidates){
  leyte <- write_db("Leyte")
  fish <- leyte %>% 
    tbl("clownfish") %>% 
    collect()
  dbDisconnect(leyte)
  
  max_gen <- fish %>% 
  summarise(max = max(gen_id, na.rm = T)) %>% 
  collect()

table_of_candidates <- table_of_candidates %>% 
  mutate(gen_id = ifelse(sample_id %in% table_of_candidates$sample_id, max_gen$max + 1, gen_id))

return(table_of_candidates)
  }



# change_db_gen_id ####
#' change the gen_id field in the database for all samples in a table
#' @export
#' @name change_db_gen_id
#' @author Michelle Stuart
#' @param x = table_of_candidates
#' @examples 
#' change_db_gen_id(table_of_candidates)

change_db_gen_id <- function(table_of_candidates){
  # backup db
  ley <- write_db("Leyte")
  fish <- ley %>% 
    tbl("clownfish") %>% 
    collect()
  write_csv(fish, path = paste0("../db_backups/", Sys.time(), "_clownfish_db.csv"))
  
  # make change
  fish <- fish %>%
    mutate(gen_id = ifelse(sample_id %in% table_of_candidates$sample_id, table_of_candidates$gen_id, gen_id))
  
  # write change
  dbWriteTable(ley, "clownfish", fish, row.names = F, overwrite = T)
  dbDisconnect(ley)
}

# meta_site_a ####
#' gets all of the field data for one site when fish identity is in question
#' @export
#' @name meta_site_a
#' @author Michelle Stuart
#' @param x = sitea
#' @param y = yeara
#' @param z = sizea
#' @examples 
#' nona <- meta_site_a(sitea, yeara, sizea)


meta_site_a <- function(sitea, yeara, sizea){
  # get dives
  sitea <- leyte %>% 
    tbl("diveinfo") %>% 
    filter(site == sitea, 
           year(date) == paste0("20", yeara)) %>% 
    collect() %>% 
    select(dive_table_id, site, date, gps)
  
  # get anems
  temp <- leyte %>% 
    tbl("anemones") %>% 
    filter(dive_table_id %in% sitea$dive_table_id) %>% 
    collect() %>% 
    select(dive_table_id, anem_table_id, anem_id, obs_time, anem_obs)
  
  sitea <- left_join(temp, sitea, by = "dive_table_id")
  
  # get fish
  temp <- leyte %>% 
    tbl("clownfish") %>% 
    filter(anem_table_id %in% sitea$anem_table_id, 
           !is.na(sample_id)) %>% 
    collect()
  
  sitea <- left_join(temp, sitea, by = "anem_table_id")
  rm(temp)
  
  # get lat lon
  
  temp <- sitea %>% 
    mutate(obs_time = force_tz(ymd_hms(str_c(date, obs_time, sep = " ")), tzone = "Asia/Manila")) %>% 
    mutate(obs_time = with_tz(obs_time, tzone = "UTC")) %>% 
    mutate(hour = hour(obs_time), 
           minute = minute(obs_time))
  
  lat <- leyte %>%
    tbl("GPX")  %>% 
    mutate(gpx_date = date(time)) %>%
    filter(gpx_date %in% sitea$date) %>% 
    mutate(gpx_hour = hour(time)) %>%
    mutate(minute = minute(time)) %>%
    mutate(second = second(time)) %>%
    select(-time, -second)%>%
    collect() 
  
  # attach the lat lons
  temp <- left_join(temp, lat, by = c("date" = "gpx_date", "hour" = "gpx_hour", "minute" = "minute", "gps" = "unit"))
  
  # summarize the lat lons
  temp <- temp %>% 
    group_by(sample_id) %>% 
    summarise(lat = mean(as.numeric(lat)), 
              lon = mean(as.numeric(lon)))
  
  sitea <- left_join(sitea, temp, by = "sample_id")
  rm(temp, lat)
  
  # calculate the distances
  alldists <- fields::rdist.earth(as.matrix(sitea[,c("lon", "lat")]), as.matrix(investigate[i,c("second_lon", "second_lat")]), miles=FALSE, R=6371) 
  
  sitea <- sitea %>% 
    mutate(distkm = alldists) 
  
  sitea_small <- sitea %>% 
    filter(as.numeric(size) < sizea)
  
  # how many of sitea that are small enough to match our fish are ungenotyped? 
  nona <- sitea_small %>%
    filter(is.na(gen_id)) %>% 
    select(sample_id, size, color, lat, lon, gen_id, distkm)
  
return(nona)
}


# lab_site_a ####
#' this function gets all of the lab data for potential mixup fish when fish identity is in question
#' @export
#' @name lab_site_a
#' @author Michelle Stuart
#' @param x = nona
#' @examples 
#' temp <- lab_site_a(nona)

lab_site_a <- function(nona){
  sitea_work <- work_history(nona, "sample_id")
  
  y_work <<- work_history(y, "sample_id")
  
  same_ext <<- sitea_work %>% 
    filter(plate.x %in% y_work$plate.x)
  
  same_dig <<- sitea_work %>% 
    filter(plate.y %in% y_work$plate.y)
  # same_dig <- rbind(same_dig, y_work) %>% arrange(plate.y)
  
  
  same_lig <<- sitea_work %>% 
    filter(plate %in% y_work$plate, 
           !is.na(plate))
  
  same_barcode <<- sitea_work %>% 
    filter(barcode_num %in% y_work$barcode_num, 
           !is.na(barcode_num))
  
  same_pool <<- sitea_work %>% 
    filter(pool %in% y_work$pool, 
           !is.na(pool)) 
  
}

# meta_site_b ####
#' gets all of the field data for one site when fish identity is in question
#' @export
#' @name meta_site_b
#' @author Michelle Stuart
#' @param x = siteb
#' @param y = yearb
#' @param z = sizeb
#' @examples 
#' nonb <- meta_site_b(siteb, yearb, sizeb)

meta_site_b <- function(siteb, yearb, sizeb){
  # get dives
  siteb <- leyte %>% 
    tbl("diveinfo") %>% 
    filter(site == siteb, 
           year(date) == paste0("20",yearb)) %>% 
    collect() %>% 
    select(dive_table_id, site, date, gps)
  
  # get anems
  temp <- leyte %>% 
    tbl("anemones") %>% 
    filter(dive_table_id %in% siteb$dive_table_id) %>% 
    collect() %>% 
    select(dive_table_id, anem_table_id, anem_id, obs_time, anem_obs)
  
  siteb <- left_join(temp, siteb, by = "dive_table_id")
  
  # get fish
  temp <- leyte %>% 
    tbl("clownfish") %>% 
    filter(anem_table_id %in% siteb$anem_table_id, 
           !is.na(sample_id)) %>% 
    collect()
  
  siteb <- left_join(temp, siteb, by = "anem_table_id")
  rm(temp)
  
  # get lat lon
  
  temp <- siteb %>% 
    mutate(obs_time = force_tz(ymd_hms(str_c(date, obs_time, sep = " ")), tzone = "Asia/Manila")) %>% 
    mutate(obs_time = with_tz(obs_time, tzone = "UTC")) %>% 
    mutate(hour = hour(obs_time), 
           minute = minute(obs_time))
  
  lat <- leyte %>%
    tbl("GPX")  %>% 
    mutate(gpx_date = date(time)) %>%
    filter(gpx_date %in% siteb$date) %>% 
    mutate(gpx_hour = hour(time)) %>%
    mutate(minute = minute(time)) %>%
    mutate(second = second(time)) %>%
    select(-time, -second)%>%
    collect() 
  
  # attach the lat lons
  temp <- left_join(temp, lat, by = c("date" = "gpx_date", "hour" = "gpx_hour", "minute" = "minute", "gps" = "unit"))
  
  # summarize the lat lons
  temp <- temp %>% 
    group_by(sample_id) %>% 
    summarise(lat = mean(as.numeric(lat)), 
              lon = mean(as.numeric(lon)))
  
  siteb <- left_join(siteb, temp, by = "sample_id")
  rm(temp, lat)
  
  # calculate the distances
  alldists <- fields::rdist.earth(as.matrix(siteb[,c("lon", "lat")]), as.matrix(investigate[i,c("second_lon", "second_lat")]), miles=FALSE, R=6371) 
  
  siteb <- siteb %>% 
    mutate(distkm = alldists) 
  
  siteb_small <- siteb %>% 
    filter(as.numeric(size) < sizeb)
  
  # how many of siteb that are small enough to match our fish are ungenotyped? 
  nonb <- siteb_small %>%
    filter(is.na(gen_id)) %>% 
    select(sample_id, size, color, lat, lon, gen_id, distkm)
  
  return(nonb)
  
}


# lab_site_b ####
#' this function gets all of the lab data for potential mixup fish when fish identity is in question
#' @export
#' @name lab_site_b
#' @author Michelle Stuart
#' @param x = nonb
#' @examples 
#' temp <- lab_site_a(nonb)

lab_site_b <- function(nonb){
  siteb_work <- work_history(nonb, "sample_id")
  
  y_work <<- work_history(y, "sample_id")
  
  same_ext <<- siteb_work %>% 
    filter(plate.x %in% y_work$plate.x)
  
  same_dig <<- siteb_work %>% 
    filter(plate.y %in% y_work$plate.y)
  # same_dig <- rbind(same_dig, y_work) %>% 
  # arrange(plate.y)
  # this catches all of the future "sames"
  
  same_lig <<- siteb_work %>% 
    filter(plate %in% y_work$plate, 
           !is.na(plate))
  
  same_barcode <<- siteb_work %>% 
    filter(barcode_num %in% y_work$barcode_num, 
           !is.na(barcode_num))
  
  same_pool <<- siteb_work %>% 
    filter(pool %in% y_work$pool, 
           !is.na(pool))
}

# work_history ####
#' get the work history for samples
#' @export
#' @name work_history
#' @author Michelle Stuart
#' @param x = table_where_ids_are
#' @param y = column_of_ids - must be sample_id, extraction_id, digest_id, or ligation_id
#' @examples 
#' history <- work_history(table,column)

# check the work history of those sample_ids
work_history <- function(table, column){
  if(column == "sample_id"){
    hist <- lab %>% 
      tbl("extraction") %>% 
      filter(sample_id %in% table$sample_id) %>% 
      select(sample_id, extraction_id, plate) %>% 
      collect()
    
    dig <- lab %>% 
      tbl("digest") %>% 
      filter(extraction_id %in% hist$extraction_id) %>% 
      select(extraction_id, digest_id, plate) %>% 
      collect()
    hist <- left_join(hist, dig, by = "extraction_id")
    rm(dig)
    
    lig <- lab %>% 
      tbl("ligation") %>% 
      filter(digest_id %in% hist$digest_id) %>% 
      select(ligation_id, barcode_num,digest_id, pool, plate) %>% 
      collect()
    hist <- left_join(hist, lig, by = "digest_id")
    rm(lig)
    return(hist)
  }
  if(column == "extraction_id"){
    hist <- lab %>% 
      tbl("extraction") %>% 
      filter(extraction_id %in% table$extraction_id) %>% 
      select(sample_id, extraction_id, plate) %>% 
      collect()
    
    dig <- lab %>% 
      tbl("digest") %>% 
      filter(extraction_id %in% hist$extraction_id) %>% 
      select(extraction_id, digest_id, plate) %>% 
      collect()
    hist <- left_join(hist, dig, by = "extraction_id")
    rm(dig)
    
    lig <- lab %>% 
      tbl("ligation") %>% 
      filter(digest_id %in% hist$digest_id) %>% 
      select(ligation_id, barcode_num,digest_id, pool, plate) %>% 
      collect()
    hist <- left_join(hist, lig, by = "digest_id")
    rm(lig)
    return(hist)
  }
  
  
  if(column == "ligation_id"){
    hist <- lig <- lab %>% 
      tbl("ligation") %>% 
      filter(ligation_id %in% table$ligation_id) %>% 
      select(ligation_id, barcode_num,digest_id, pool, plate) %>% 
      collect()
    
    dig <- lab %>% 
      tbl("digest") %>% 
      filter(digest_id %in% hist$digest_id) %>% 
      select(extraction_id, digest_id, plate) %>% 
      collect()
    hist <- left_join(hist, dig, by = "digest_id")
    rm(dig)
    
    extr <- lab %>% 
      tbl("extraction") %>% 
      filter(extraction_id %in% hist$extraction_id) %>% 
      select(extraction_id, sample_id, plate) %>% 
      collect()
    hist <- left_join(hist, extr, by = "extraction_id")
    rm(extr)
    return(hist)
  }  
}



