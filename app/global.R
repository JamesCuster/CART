library(shiny)
library(dplyr)
library(RSQLite)


# Database related functions ----------------------------------------------

BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")

# function that loads all tables from database
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


# List of database field names used to clean form data --------------------

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

# addTime form inputs
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
    projectFormData
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
    timeFormData
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
    researcherFormData
  }
}


# addEmployee form functions
saveEmployeeFormData <- function(formResponse) {
  formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
  if (exists("employeeFormData")) {
    employeeFormData <<- rbind(employeeFormData, formResponse)
  } else {
    employeeFormData <<- formResponse
  }
}

loadEmployeeFormData <- function(formResponse) {
  if (exists("employeeFormData")) {
    employeeFormData
  }
}



# Function that allows for two text inputs to be in a row
    # Not currently used, but leaving in here for now because it might be useful
    # later
# textInputRow <- function(inputId, label, value = "") {
#   div(style="display:inline-block",
#       tags$label(label, `for` = inputId), 
#       tags$input(id = inputId, type = "text", value = value,class="input-small"))
# }
