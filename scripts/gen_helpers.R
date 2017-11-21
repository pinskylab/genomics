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
  dat <- read.table(filename, skip = 2, sep = " ", stringsAsFactors = F, colClasses = "character") 
  
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
    filter(sample_id == sample) %>% 
    select(sample_id, anem_table_id) %>% 
    collect()
  anem <- leyte %>% 
    tbl("anemones") %>% 
    filter(anem_table_id == fish$anem_table_id) %>% 
    select(anem_table_id, anem_id, dive_table_id) %>% 
    collect()
  fish <- left_join(fish, anem, by = "anem_table_id")
  rm(anem)
  dive <- leyte %>% 
    tbl("diveinfo") %>% 
    filter(dive_table_id == fish$dive_table_id) %>% 
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

