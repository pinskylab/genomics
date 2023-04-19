read_db <- function(db_name){
  con <- DBI::dbConnect(RMySQL::MySQL(), 
                        dbname=db_name,
                        host = "amphiprion.deenr.rutgers.edu",
                        username = "michelles",
                        password = "grade9&flats")
  return(con)
}