library(shiny)
library(dplyr)
library(RSQLite)
library(DT)
library(shinyjs)


# Database related functions ----------------------------------------------
dirPath <- "C:/Users/jmc6538/Desktop/BDSHProjectTracking"

# Connect to database
BDSHProjects <- dbConnect(SQLite(), paste0(dirPath, "/BDSHProjects.sqlite"))

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
loadDatabase <- function(tables = c("projects", "employees", "time", "researchers", "modified")) {
  # projects 
  if ("projects" %in% tables) {
    reactiveData$projects <- tbl(BDSHProjects, "projects") %>% 
      collect() %>% 
      mutate(
        value = projectID,
        label = projectName
      ) %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  # employees
  if ("employees" %in% tables) {
    reactiveData$employees <- tbl(BDSHProjects, "employees") %>% 
      collect()  %>% 
      mutate(
        value = bdshID,
        label = paste0(employeeName, " (", employeeUteid, ")")
      )%>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  # time
  if ("time" %in% tables) {
    reactiveData$time <- tbl(BDSHProjects, "time") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  # researchers
  if ("researchers" %in% tables) {
    reactiveData$researchers <- tbl(BDSHProjects, "researchers") %>% 
      collect() %>% 
      mutate(
        value = researcherID,
        label = paste0(researcherName, " (", researcherEmail, ")")
      ) %>% 
      as.data.frame(stringsAsFactors = FALSE)
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
