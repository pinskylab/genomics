# a script to turn a genepop into a csv
library(tidyr)
source("scripts/gen_helpers.R")

genepop_to_csv <- function() {
  # genepop that has regenotypes removed
  genfile <- "data/2017-10-16no12.gen"
  
  # read in the genepop
  gendf <- read_gen_sp(genfile)
  
  # cervus changes a genepop from one column containing 0202 format to 2 columns named A & B containing 2 and 2, comma separated.
  
  # remove names col
  gen_noname <- gendf[ , 2:ncol(gendf)]
  gen_name <- gendf[ , 1]
  
  # make a list of column names
  col_list <- names(gen_noname)
  
  new <- data.frame(gen_name) #start with the names
  for (i in 1:ncol(gen_noname)){
    x <- paste(col_list[i], "A", sep = "")
    y <- paste(col_list[i], "B", sep = "")
    temp <- gen_noname %>% 
      select(i)
    temp <- temp %>% 
      separate(1, into = c(x, y), sep = 2) # separate after 2 characters
    new <- cbind(new, temp)
  }
}

write.csv(new, file = "genepop_as.csv", row.names = F, quote = F)
