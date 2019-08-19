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
#      mutate(
#        value = projectID,
#        label = projectName
#      ) %>% 
      as.data.frame(stringsAsFactors = FALSE)
  }
  # employees
  if ("employees" %in% tables) {
    reactiveData$employees <- tbl(BDSHProjects, "employees") %>% 
      collect()  %>% 
#      mutate(
#        value = bdshID,
#        label = paste0(employeeName, " (", employeeUteid, ")")
#      )%>% 
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
#      mutate(
#        value = researcherID,
#        label = paste0(researcherName, " (", researcherEmail, ")")
#      ) %>% 
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


# Database Callback Functions ---------------------------------------------
# These functions are used to create SQL queries which manipulate the database

# function that create insert SQL query
insertCallback <- function(ids, tab) {
  insert <- paste0(
    "insert into ",
    tab,
    " (",
    paste0(ids, collapse = ", "),
    ") values ("
  )
  fields <- paste(
    lapply(
      ids, 
      function(x) {
        if (is.null(input[[x]]) || is.na(input[[x]]) || input[[x]] == "") {
          "null"
        }
        else {
          paste0("'", input[[x]], "'")
        }
      }
    ),
    collapse = ", "
  )
  query <- paste0(insert, fields, ")")
  dbExecute(BDSHProjects, query)
}


# function that create delete SQL query
deleteCallback <- function(df, row, idVar, tab) {
  rowid <- df[row, idVar]
  query <- paste0(
    "delete from ",
    tab, 
    " where ",
    idVar,
    " = ",
    rowid
  )
  dbExecute(BDSHProjects, query)
}


# function that create update SQL query
updateCallback <- function(ids, df, row, idVar, tab) {
  ids <- ids[!ids %in% idVar]
  update <- paste0(
    "update ",
    tab,
    " set "
  )
  fields <- paste(
    lapply(
      ids, 
      function(x) {
        if (input[[x]] == "") {
          paste0(x, " = ", "null")
        }
        else {
          paste0(x, " = ", paste0("'", input[[x]], "'"))
        }
      }
    ),
    collapse = ", "
  )
  where <- paste0(" where ", idVar, " = ", df[row, idVar])
  query <- paste0(update, fields, where)
  dbExecute(BDSHProjects, query)
}



# Function That Builds Inputs for Modals ----------------------------------
modalInputs <- function(ids, labels, type, values) {
  fields <- list()
  for (i in seq_along(ids)) {
    if (type[i] == "skip") {
      fields[[i]] <- NULL
    }
    else if (type[i] == "textInput") {
      value <- ifelse(missing(values) || is.na(values[i]), "", values[i])
      fields[[i]] <- textInput(inputId = ids[i],
                               label = labels[i],
                               value = value)
    }
    else if (type[i] == "selectizeInput") {
      value <- ifelse(missing(values) || is.na(values[i]), "", values[i])
      fields[[i]] <- selectizeInput(inputId = ids[i],
                                    label = labels[i],
                                    choices = NULL,
                                    selected = value)
    }
  }
  fields
}





# projects notes ----------------------------------------------------------

# This function takes a data frame and creates a value/label data.frame for use
# in selectInputs
valueLabel <- function(df, value, label) {
  x <- data.frame(
    value = df[[value]],
    label = df[[label]]
  )
  return(x)
}


# selectInputChoices <- 
#   list(
#     bdshLead = valueLabel(reactiveData$employees, "bdshID", "employeeName"),
#     bdshSecondary = valueLabel(reactiveData$employees, "bdshID", "employeeName"),
#     projectPI = valueLabel(reactiveData$researchers, "researcherID", "researcherName"),
#     projectSupport1 = valueLabel(reactiveData$researchers, "researcherID", "researcherName"),
#     projectSupport2 = valueLabel(reactiveData$researchers, "researcherID", "researcherName"),
#     projectSupport3 = valueLabel(reactiveData$researchers, "researcherID", "researcherName"),
#     projectSupport4 = valueLabel(reactiveData$researchers, "researcherID", "researcherName"),
#     projectStatus = c("Active", "Closed", "Dormant")
#   )












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
