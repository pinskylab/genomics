# helper functions for working with this repository

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
  names(dat) <- c("names", "blank", loci)
  
  dat <- select(dat, -blank)
  
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
  dig <- lab %>% 
    tbl("ligation") %>% 
    filter(ligation_id %in% table_name$names) %>% 
    select(ligation_id, digest_id) %>% 
    collect()
  
  # connect digest ids to extraction ids
  extr <- lab %>% tbl("digest") %>% 
    filter(digest_id %in% dig$digest_id) %>% 
    select(digest_id, extraction_id) %>% 
    collect()
  extr_id <- left_join(dig, extr, by = "digest_id")
  # connect extraction ids to sample ids
  samp <- lab %>% 
    tbl("extraction") %>% 
    filter(extraction_id %in% extr_id$extraction_id) %>% 
    select(extraction_id, sample_id) %>% 
    collect() 
  samp_id <- left_join(extr_id, samp, by = "extraction_id")
  # remove unnecessary columns
  samp_id <- samp_id[ , c("ligation_id", "sample_id")]
  return(samp_id)
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
