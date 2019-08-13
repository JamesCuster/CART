library(shiny)
library(dplyr)
library(tidyr)
library(RSQLite)
library(DT)
library(shinyjs)


# Database related functions ----------------------------------------------

# Connect to database
BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")

# reactives for the form data
reactiveFormData <- 
  reactiveValues(
    projectFormData = NULL,
    timeFormData = NULL,
    researcherFormData = NULL,
    employeeFormData = NULL
  )

# Reactives for the view tabs
viewTables <- reactiveValues(
  projects = NULL,
  time = NULL
)


# Define the reactiveData reactive
reactiveData <- reactiveValues()

# function that loads specified tables from database and updates reactiveData
loadDatabase <- function(tables = c("projects", "employees", "effort", "researchers", "modified")) {
  # projects 
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
  # employees
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
  # effort
  if ("effort" %in% tables) {
    effort <<- tbl(BDSHProjects, "effort") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
    reactiveData$effort <- effort
  }
  # researchers
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
  # modified
  if ("modified" %in% tables) {
    modified <<- tbl(BDSHProjects, "modified") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
}

loadDatabase()



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
  
  df$Delete <- sapply(row.names(df), deleteLink)
  df$Edit <- sapply(row.names(df), editLink)
  return(df)
}


# Function that grabs the rowID for the row to be edited or deleted
parseDeleteEvent <- function(idstr) {
  res <- as.integer(sub(".*_([0-9]+)", "\\1", idstr))
  if (!is.na(res)) res
}
