# helper functions for working with this repository
library(dplyr)
# read_gene_sp ####
#' read a genepop generated for ONE population
#' @export
#' @name read_gene_sp
#' @author Michelle Stuart
#' @param x = filename
#' @examples 
#' genedf <- read_gene_sp("data/seq17_03_58loci.gen")

# only works if Genepop has loci listed in 2nd line (separated by commas), has individual names separated from genotypes by a comma, and uses spaces between loci
#also pop has to be on line 3, all lowercase
# return a data frame: col 1 is individual name, col 2 is population, cols 3 to 2n+2 are pairs of columns with locus IDs
read_gen_sp <-  function(filename){
  # get all of the data
  dat <- read.table(filename, skip = 3, sep = " ", stringsAsFactors = F, colClasses = "character") 
  
  # get the header info
  info <- readLines(filename, n = 3) 
  
  # define the loci names
  loci <- unlist(strsplit(info[2], split=','))    
  
  # rename the dat columns
  names(dat) <- c("names", loci)
  
  # dat <- select(dat, -blank)
  
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
    filter(ligation_id %in% table_name$ligation_id) %>% 
    select(ligation_id, digest_id) %>% 
    collect()
    
  # connect digest ids to extraction ids
  dig <- lab %>% 
    tbl("digest") %>% 
    filter(digest_id %in% lig$digest_id) %>% 
    select(extraction_id, digest_id) %>% 
    collect()
  
  extr <- lab %>% 
    tbl("extraction") %>% 
    filter(extraction_id %in% dig$extraction_id) %>% 
    select(extraction_id, sample_id) %>% 
    collect()
  
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
