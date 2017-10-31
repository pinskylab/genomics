# find tags

tags <- leyte %>% 
  tbl("clownfish") %>% 
  filter(!is.na(tag_id)) %>% 
  collect() 

tags %>% 
  filter(grepl("355443"))
