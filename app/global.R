library(shiny)
library(dplyr)
library(RSQLite)
library(DT)


# Database related functions ----------------------------------------------

BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")

loadDatabase <- function(tables = c("projects", "employees", "effort", "researchers", "modified")) {
  if ("projects" %in% tables) {
    projects <<- tbl(BDSHProjects, "projects") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  if ("employees" %in% tables) {
    employees <<- tbl(BDSHProjects, "employees") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  if ("effort" %in% tables) {
    effort <<- tbl(BDSHProjects, "effort") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  if ("researchers" %in% tables) {
    researchers <<- tbl(BDSHProjects, "researchers") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
    
  }
  if ("modified" %in% tables) {
    modified <<- tbl(BDSHProjects, "modified") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
}

loadDatabase()


# Reactives used to trigger updates to select(ize)Input when data is reloaded
refresh <- 
  reactiveValues(
    effort = FALSE,
    employees = FALSE,
    projects = FALSE,
    researchers = FALSE
  )

# List of database field names used to clean form data --------------------

# addProject form inputs
addProjectFields <- 
  c("projectID",
    "projectName",
    "bdshLeadName",
    "bdshLead",
    "bdshSecondaryName",
    "bdshSecondary",
    "projectPIName",
    "projectPI",
    "projectSupport1Name",
    "projectSupport1",
    "projectSupport2Name",
    "projectSupport2",
    "projectSupport3Name",
    "projectSupport3",
    "projectSupport4Name",
    "projectSupport4",
    "projectDescription",
    "projectStatus",
    "projectDueDate")

# addProject inputs that need to get values from employees tables
addProjectFieldsBDSH <- 
  c("bdshLead",
    "bdshSecondary"
    )

# addProject inputs that need to get values from researchers tables
addProjectFieldsResearchers <- 
  c("projectPI",
    "projectPIEmail",
    "projectSupport1",
    "projectSupport2",
    "projectSupport3",
    "projectSupport4")

# This inputs are used to display the names of people entered on the addProjects
# form, but are not saved to the database. This is used just so that the person
# inputing the data sees the persons name for clarity sake
addProjectPeopleNames <- 
  c("bdshLeadName",
    "bdshSecondaryName",
    "projectPIName",
    "projectSupport1Name",
    "projectSupport2Name",
    "projectSupport3Name",
    "projectSupport4Name")


# addTime form inputs
addTimeFields <- 
  c("effortID",
    "timeProjectID",
    "workByName",
    "workBy",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")


# addResearcher form inputs
addResearcherFields <- 
  c("researcherID",
    "researcherUteid",
    "researcherName",
    "researcherEmail",
    "primaryDept",
    "secondaryDept"
  )

# addEmployee form inputs
addEmployeeFields <- 
  c("bdshID",
    "employeeUteid",
    "employeeName",
    "employeeEmail",
    "degree",
    "role"
    )


# Functions to save and load add____ form data ---------------------------

# addProject form functions 
saveProjectFormData <- function(formResponse) {
  formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
  if (exists("projectFormData")) {
    projectFormData <<- rbind(projectFormData, formResponse)
  } else {
    projectFormData <<- formResponse
  }
}

loadProjectFormData <- function() {
  if (exists("projectFormData")) {
    projectFormData[-1]
  }
}


# addTime form functions 
saveTimeFormData <- function(formResponse) {
  formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
  if (exists("timeFormData")) {
    timeFormData <<- rbind(timeFormData, formResponse)
  } else {
    timeFormData <<- formResponse
  }
}

loadTimeFormData <- function() {
  if (exists("timeFormData")) {
    timeFormData[-1]
  } 
}


# addResearcher form functions
saveResearcherFormData <- function(formResponse) {
  formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
  if (exists("researcherFormData")) {
    researcherFormData <<- rbind(researcherFormData, formResponse)
  } else {
    researcherFormData <<- formResponse
  }
}

loadResearcherFromData <- function() {
  if (exists("researcherFormData")) {
    researcherFormData[-1]
  }
}


# addEmployee form functions
saveEmployeeFormData <- function(formResponse) {
  formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
  if (exists("employeeFormData")) {
    employeeFormData <- rbind(employeeFormData, formResponse)
    row.names(employeeFormData) <- NULL
    employeeFormData <<- employeeFormData
  } else {
    employeeFormData <- formResponse
    row.names(employeeFormData) <- NULL
    employeeFormData <<- employeeFormData
  }
}

loadEmployeeFormData <- function(formResponse) {
  if (exists("employeeFormData")) {
    addDeleteEditLink(employeeFormData[-1], "employeeForm")
  }
}


# Functions and helpers to create/manipulate delete/edit buttons ----------

# function that adds the delete button to data.frames
addDeleteEditLink <- function(df, idPrefix) {
  # function to make delete link to be used with lapply
  deleteLink <- function(rowID) {
    as.character(
      actionLink(
        inputId = paste(idPrefix, "delete", rowID, sep = "\\."),
        label = "Delete",
        onclick = 'Shiny.setInputValue(\"deletePressed\", this.id, {priority: "event"})'
      )
    )
  }
  
  # function to make edit link to be used with lapply
  editLink <- function(rowID) {
    as.character(
      actionLink(
        inputId = paste(idPrefix, "edit", rowID, sep = "\\."),
        label = "Edit",
        onclick = 'Shiny.setInputValue(\"editPressed\", this.id, {priority: "event"})'
      )
    )
  }
  
  # create datatable with given data.frame and the two functions above
  datatable(
    cbind(
      Delete = sapply(row.names(df), deleteLink),
      Edit = sapply(row.names(df), editLink),
      df
    ),
    escape = FALSE,
  )
}


# Function that grabs the rowID for the row to be edited or deleted
parseDeleteEvent <- function(idstr) {
  res <- as.integer(sub(".*\\.([0-9]+)", "\\1", idstr))
  if (!is.na(res)) res
}