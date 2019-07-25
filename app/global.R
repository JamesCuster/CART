# connect to DB here
library(shiny)
library(dplyr)
library(RSQLite)


# Database related functions ----------------------------------------------

BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")

# function that loads all tables from database
loadDatabase <- function() {
  projects <<- tbl(BDSHProjects, "projects") %>% 
    collect() %>% 
    as.data.frame(stringsAsFactors = FALSE)
  people <<- tbl(BDSHProjects, "employees") %>% 
    collect() %>% 
    as.data.frame(stringsAsFactors = FALSE)
  effort <<- tbl(BDSHProjects, "effort") %>% 
    collect() %>% 
    as.data.frame(stringsAsFactors = FALSE)
  researchers <<- tbl(BDSHProjects, "researchers") %>% 
    collect() %>% 
    as.data.frame(stringsAsFactors = FALSE)
}

loadDatabase()


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
    "projectDueDate",
    "lastModified")

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

# Inputs fr the add time form
addTimeFields <- 
  c("effortID",
    "timeProjectID",
    "workBy",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")

# Inputs for the add researcher form
addResearcherFields <- 
  c("researcherUteid",
    "researcherName",
    "researcherEmail",
    "primaryDept",
    "secondaryDept"
  )

# Inputs for the add BDSH employee form
addEmployeeFields <- 
  c("employeeUteid",
    "employeeName",
    "employeeEmail",
    "degree",
    "role"
    )


# Function that allows for two text inputs to be in a row
textInputRow <- function(inputId, label, value = "") {
  div(style="display:inline-block",
      tags$label(label, `for` = inputId), 
      tags$input(id = inputId, type = "text", value = value,class="input-small"))
}
