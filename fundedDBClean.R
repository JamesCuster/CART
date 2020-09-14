library(dplyr)
library(RSQLite)


# Impute funded in Projects -----------------------------------------------

# read in funded CSV
funded <- read.csv("Z:/CART/FundedProjects.csv", 
                   stringsAsFactors = FALSE)
funded <- na.omit(funded)

# Database path
dirPath <- ifelse(exists("dirPath"), dirPath, "Z:/CART")

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



# There are 2 time entries that don't have date. Manually add them
time[343, "dateOfWork"] <- time[344, "dateOfWork"]
time[393, "dateOfWork"] <- time[394, "dateOfWork"]


# Nazan entered time in project 1010 that was for the THC project and thus was
# funded work. manually change timeFunded for these entries
time[c(391, 412), "timeFunded"] <- "Funded"


dbWriteTable(BDSHProjects, "time", value = time, append = FALSE, 
             overwrite = TRUE)


# Remove projectFunded column from projects table. -----------------------------
projects <- projects[, -which(names(projects) == "projectFunded")]


dbWriteTable(BDSHProjects, "projects", value = projects, append = FALSE, 
             overwrite = TRUE)
