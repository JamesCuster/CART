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
# loadDatabase <- function() {
#   input$projects <<- tbl(BDSHProjects, "projects") %>% collect()
#   input$people <<- tbl(BDSHProjects, "bdshPeople") %>% collect()
#   input$effort <<- tbl(BDSHProjects, "effort") %>% collect()
#   input$researchers <<- tbl(BDSHProjects, "researchers") %>% collect()
# }



# field (variable names) for the [add]projects and [add]time forms and tables in
# the database

addProjectFields <- 
  c("projectID",
    "projectName",
    "bdshLead",
    "bdshSecondary",
    "projectPI",
    "projectPIEmail",
    "projectSupport1",
    "projectSupport1Email",
    "projectSupport2",
    "projectSupport2Email",
    "projectSupport3",
    "projectSupport3Email",
    "projectSupport4",
    "projectSupport4Email",
    "projectDescription",
    "projectStatus",
    "projectDueDate")

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
