library(shiny)
library(dplyr)
library(RSQLite)
library(DT)


# Database related functions ----------------------------------------------

# Connect to database
BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")


# Define the reactiveData
reactiveData <- reactiveValues()

# function that loads specified tables from database
loadDatabase <- function(tables = c("projects", "employees", "effort", "researchers", "modified")) {
  if ("projects" %in% tables) {
    projects <<- tbl(BDSHProjects, "projects") %>% 
      collect() %>% 
      mutate(
        value = projectID,
        label = projectName
      ) %>% 
      as.data.frame(stringsAsFactors = FALSE)
    reactiveData$projects <- projects
  }
  if ("employees" %in% tables) {
    employees <<- tbl(BDSHProjects, "employees") %>% 
      collect()  %>% 
      mutate(
        value = bdshID,
        label = paste0(employeeName, " (", employeeUteid, ")")
      )%>% 
      as.data.frame(stringsAsFactors = FALSE)
    reactiveData$employees <- employees
  }
  if ("effort" %in% tables) {
    effort <<- tbl(BDSHProjects, "effort") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
    reactiveData$effort <- effort
  }
  if ("researchers" %in% tables) {
    researchers <<- tbl(BDSHProjects, "researchers") %>% 
      collect() %>% 
      mutate(
        value = researcherID,
        label = paste0(researcherName, " (", researcherEmail, ")")
      ) %>% 
      as.data.frame(stringsAsFactors = FALSE)
    reactiveData$researchers <- researchers
  }
  if ("modified" %in% tables) {
    modified <<- tbl(BDSHProjects, "modified") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
}

loadDatabase()

# List of database field names used to clean form data --------------------

# addProject form inputs
addProjectFields <- 
  c("projectID",
    "projectName",
    "bdshLead",
    "bdshLeadName",
    "bdshSecondary",
    "bdshSecondaryName",
    "projectPI",
    "projectPIName",
    "projectSupport1",
    "projectSupport1Name",
    "projectSupport2",
    "projectSupport2Name",
    "projectSupport3",
    "projectSupport3Name",
    "projectSupport4",
    "projectSupport4Name",
    "projectDescription",
    "projectStatus",
    "projectDueDate")

# This inputs are used to display the names of people entered on the addProjects
# form, but are not saved to the database. This is used just so that the person
# inputing the data sees the persons name for clarity sake
addProjectResearcherNames <- 
  c("projectPIName",
    "projectSupport1Name",
    "projectSupport2Name",
    "projectSupport3Name",
    "projectSupport4Name")

addProjectEmployeeNames <- 
  c("bdshLeadName",
    "bdshSecondaryName")

addProjectRemoveForDatabase <- 
  c("projectPIName",
    "projectSupport1Name",
    "projectSupport2Name",
    "projectSupport3Name",
    "projectSupport4Name",
    "bdshLeadName",
    "bdshSecondaryName",
    "value",
    "label")


# addTime form inputs
addTimeFields <- 
  c("effortID",
    "timeProjectID",
    "timeProjectName",
    "workBy",
    "workByName",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")

addTimeRemoveForDatabase <- 
  c("timeProjectName", 
    "workByName")


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
    addDeleteEditLink(projectFormData[-1], "projectFormData")
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
    addDeleteEditLink(timeFormData[-1], "timeFormData")
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

loadResearcherFormData <- function() {
  if (exists("researcherFormData")) {
    addDeleteEditLink(researcherFormData[-1], "researcherFormData")
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
    addDeleteEditLink(employeeFormData[-1], "employeeFormData")
  }
}


# Functions and helpers to create/manipulate delete/edit buttons ----------

# function that adds the delete button to data.frames
addDeleteEditLink <- function(df, idPrefix) {
  # function to make delete link to be used with lapply
  deleteLink <- function(rowID) {
    # create inputId name
    delID <- paste0(idPrefix, "Delete")
    
    as.character(
      actionLink(
        inputId = paste(idPrefix, rowID, sep = "_"),
        label = "Delete",
        onclick = 
          paste0(
            'Shiny.setInputValue(\"',
            delID,
            '\", this.id, {priority: "event"})'
          )
      )
    )
  }
  
  # function to make edit link to be used with lapply
  editLink <- function(rowID) {
    # create inputId name
    editID <- paste0(idPrefix, "Edit")
    
    as.character(
      actionLink(
        inputId = paste(idPrefix, rowID, sep = "_"),
        label = "Edit",
        onclick = 
          paste0(
            'Shiny.setInputValue(\"',
            editID,
            '\", this.id, {priority: "event"})'
          )
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
  res <- as.integer(sub(".*_([0-9]+)", "\\1", idstr))
  if (!is.na(res)) res
}



# Functions to Modify The UI ----------------------------------------------