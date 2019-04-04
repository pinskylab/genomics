## ------------------------------------------------------------------------- ##
# --------------------  read VCFtools ind stats files ----------------------- #

read.ind.stats <- function(dir, vcf) {
  # read depth stats
  filename <- paste(vcf, ".idepth", sep = "")
  path <- file.path(dir, filename)
  idepth <- read_delim(path, delim ="\t")

  
  # read missing stats
  filename <- paste(vcf, ".imiss", sep = "")
  path <- file.path(dir, filename)
  imiss <- read_delim(path, delim ="\t")
  
  # join stats
  temp <- left_join(imiss, idepth, by = "INDV")
  
  # read missing stats
  filename <- paste(vcf, ".het", sep = "")
  path <- file.path(dir, filename)
  het <- read_delim(path, delim ="\t")
  
  # join stats
  final <- left_join(temp, het, by = "INDV")
}

## ------------------------------------------------------------------------- ##



## ------------------------------------------------------------------------- ##
# --------------------  read VCFtools locus stats files ----------------------- #


read.loc.stats <- function(dir, vcf) {
  # read depth stats
  filename <- paste(vcf, ".ldepth.mean", sep = "")
  path <- file.path(dir, filename)
  ldepth <- read_delim(path, delim ="\t")
  
  # read missing stats
  filename <- paste(vcf, ".lmiss", sep = "")
  path <- file.path(dir, filename)
  lmiss <- read_delim(path, delim ="\t") %>% 
    rename(CHROM = CHR)
  # join stats
  temp <- left_join(lmiss, ldepth, by = c("CHROM", "POS"))
  
  # read site quality
  filename <- paste(vcf, ".lqual", sep = "")
  path <- file.path(dir, filename)
  lqual <- read_delim(path, delim = "\t")
  # join stats
  final <- left_join(temp, lqual, by = c("CHROM", "POS"))
}

## ------------------------------------------------------------------------- ##
