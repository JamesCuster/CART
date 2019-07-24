# connect to DB here
library(shiny)
library(dplyr)
# library(DBI)
library(RSQLite)

# Connect to database
BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")

# pulls table into R
projects <- tbl(BDSHProjects, "projects") %>% collect()
people <- tbl(BDSHProjects, "bdshPeople") %>% collect()
effort <- tbl(BDSHProjects, "effort") %>% collect()
researchers <- tbl(BDSHProjects, "researchers") %>% collect()

#function that reloads database after data has been added
loadDatabase <- function() {
  projects <<- tbl(BDSHProjects, "projects") %>% collect()
  people <<- tbl(BDSHProjects, "bdshPeople") %>% collect()
  effort <<- tbl(BDSHProjects, "effort") %>% collect()
  researchers <<- tbl(BDSHProjects, "researchers") %>% collect()
}




# Variables, Functions, and List needed for addProjects -------------------

# addProject form inputs
addProjectFields <- 
  c("projectID",
    "projectName",
    "bdshLead",
    "bdshSecondary",
    "projectPI",
    "projectSupport1",
    "projectSupport2",
    "projectSupport3",
    "projectSupport4",
    "projectDescription",
    "projectStatus",
    "projectDueDate")

# addProject inputs that need to get values from other tables
addProjectFieldsBDSH <- 
  c("bdshLead",
    "bdshSecondary"
    )

addProjectFieldsResearchers <- 
  c("projectPI",
    "projectPIEmail",
    "projectSupport1",
    "projectSupport2",
    "projectSupport3",
    "projectSupport4")


addTimeFields <- 
  c("projectID",
    "workBy",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workDescription")

# Function that allows for two text inputs to be in a row
textInputRow <- function(inputId, label, value = "") {
  div(style="display:inline-block",
      tags$label(label, `for` = inputId), 
      tags$input(id = inputId, type = "text", value = value,class="input-small"))
}
