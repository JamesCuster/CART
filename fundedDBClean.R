library(dplyr)
library(RSQLite)


# Impute funded in Projects -----------------------------------------------

# read in funded CSV
funded <- read.csv("C:/Users/jmc6538/Documents/BDSHProjects/CART/FundedProjects.csv", 
                   stringsAsFactors = FALSE)
funded <- na.omit(funded)

# Database path
dirPath <- ifelse(exists("dirPath"), dirPath, "C:/Users/jmc6538/Documents/BDSHProjects/CART")

# Connect to database
BDSHProjects <- dbConnect(dbDriver("SQLite"), paste0(dirPath, "/BDSHProjects.sqlite"))

# read in projects table
projects <- tbl(BDSHProjects, "projects") %>% 
  collect() %>% 
  as.data.frame(stringsAsFactors = FALSE)

names(projects)
table(projects$projectFunded, useNA = "ifany")

p <- ifelse(projects$projectID %in% funded$ProjectID, "Funded", "Unfunded")

table(projects$projectFunded, p, useNA = "ifany")


projects$projectFunded <- p






# Add funded to time ------------------------------------------------------

# read in time table
time <- tbl(BDSHProjects, "time") %>% 
  collect() %>% 
  as.data.frame(stringsAsFactors = FALSE)

head(time)

time$timeFunded <- ifelse(time$timeProjectID %in% funded$ProjectID, "Funded", "Unfunded")
table(p, useNA = "always")

# Reorder variables
time <- time[, c("timeID", "timeProjectID", "workBy", "dateOfWork", "dateOfEntry",
         "timeFunded", "workTime", "workTimeCategory", "workCategory", 
         "workDescription")]


dbWriteTable(BDSHProjects, "time", value = time, append = FALSE, 
             overwrite = TRUE)
