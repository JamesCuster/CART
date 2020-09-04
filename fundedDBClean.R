library(dplyr)
library(RSQLite)

# read in funded CSV
funded <- read.csv("C:/Users/jmc6538/Documents/BDSHProjects/CART/FundedProjects.csv", 
                   stringsAsFactors = FALSE)
funded <- na.omit(funded)

# Database path
dirPath <- ifelse(exists("dirPath"), dirPath, "C:/Users/jmc6538/Documents/BDSHProjects/CART")

# Connect to database
BDSHProjects <- dbConnect(dbDriver("SQLite"), paste0(dirPath, "/BDSHProjects.sqlite"))

# read in researcher table
projects <- tbl(BDSHProjects, "projects") %>% 
  collect() %>% 
  as.data.frame(stringsAsFactors = FALSE)

names(projects)
table(projects$projectFunded, useNA = "ifany")

p <- ifelse(projects$projectID %in% funded$ProjectID, "Funded", "Unfunded")

table(projects$projectFunded, p, useNA = "ifany")


projects$projectFunded <- p

dbWriteTable(BDSHProjects, "projects", value = projects, append = FALSE, overwrite = TRUE)
