library(shiny)
library(dplyr)
library(RSQLite)
library(DT)
library(shinyjs)
library(shinyalert)


# Database related functions ----------------------------------------------
  # dirPath is defined in run.R and supplied via an argument in the CART.bat
  # call to rscript. However, if dirPath is not defined up to this point, then
  # need it defined locally, that is what this code below does
dirPath <- ifelse(exists("dirPath"), 
                  dirPath, 
                  ifelse(Sys.info()["nodename"] == "DMSBIOMED02", 
                         "Z:/CART/",
                         "C:/Users/jmc6538/Documents/BDSHProjects/CART/"))

# Connect to database
BDSHProjects <- dbConnect(dbDriver("SQLite"), paste0(dirPath, "/BDSHProjects.sqlite"))


# Define the reactiveData reactive
reactiveData <- reactiveValues()


# function that loads specified tables from database and updates reactiveData
loadDatabase <- function(tables = c("projects", "employees", "time", "researchers", "modified")) {
  # projects 
  if ("projects" %in% tables) {
    reactiveData$projects <- tbl(BDSHProjects, "projects") %>% 
      collect() %>% 
      as.data.frame(stringsAsFactors = FALSE) 
  }
  # employees
  if ("employees" %in% tables) {
    reactiveData$employees <- tbl(BDSHProjects, "employees") %>% 
      collect()  %>% 
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


# Manage Project IDs Based On Fiscal Year ---------------------------------
getFY <- function(date = Sys.Date()) {
  ifelse(format(date, "%m") %in% c("09", "10", "11", "12"), 
         as.numeric(format(Sys.Date(),"%Y")) + 1,
         as.numeric(format(Sys.Date(),"%Y")))
}

projectIDFiscalYear <- function() {
  if (format(Sys.Date(),"%m") %in% c("09", "10", "11", "12")) {
    idStart <- (as.numeric(format(Sys.Date(),"%y")) + 1) * 1000
  } else {
    idStart <- as.numeric(format(Sys.Date(),"%y")) * 1000
  }
  idStartQuery <- paste0("UPDATE SQLITE_SEQUENCE SET seq = ", idStart," WHERE name = 'projects';")
  dbExecute(BDSHProjects, idStartQuery)
}
projectIDFiscalYear()



# Function That Builds Inputs for Modals ----------------------------------
modalInputs <- function(ids, labels, type, values, df, choices) {
  fields <- list()
  for (i in seq_along(ids)) {
    if (type[i] == "skip") {
      fields[[ids[i]]] <- NULL
    }
    else if (type[i] == "textInput") {
      value <- ifelse(missing(values) || is.na(values[ids[i]]), "", values[ids[i]])
      fields[[ids[i]]] <- textInput(inputId = ids[i],
                                    label = labels[i],
                                    value = value,
                                    width = 400)
    }
    else if (type[i] == "selectizeInput") {
      value <- ifelse(missing(values) || is.na(values[ids[i]]), "", values[ids[i]])
      fields[[ids[i]]] <- selectizeInput(inputId = ids[i],
                                         label = labels[i],
                                         choices = c("", choices[[ids[[i]]]]),
                                         selected = value,
                                         width = 400)
    }
    else if (type[i] == "selectInput") {
      value <- ifelse(missing(values) || is.na(values[ids[i]]), "", values[ids[i]])
      fields[[ids[i]]] <- selectInput(inputId = ids[i],
                                      label = labels[i],
                                      choices = c("", choices[[ids[[i]]]]),
                                      selected = value,
                                      width = 400)
    }
    else if (type[i] == "textAreaInput") {
      value <- ifelse(missing(values) || is.na(values[ids[i]]), "", values[ids[i]])
      fields[[ids[i]]] <- textAreaInput(inputId = ids[i],
                                        label = labels[i],
                                        value = value,
                                        width = "400px",
                                        height = "102px")
    }
    else if (type[i] == "dateInput") {
      value <- ifelse(missing(values) || is.na(values[ids[i]]), NA, values[ids[i]])
      if (is.na(value)) {
        value <- NULL
        }
      fields[[ids[i]]] <- dateInput(inputId = ids[i],
                                    label = labels[i],
                                    value = value,
                                    width = 400)
    }
    else if (type[i] == "actionButton") {
      fields[[ids[i]]] <- actionButton(inputId = ids[i],
                                       label = labels[i],
                                       style = "margin-left: 20px; margin-top: 24px; height: 34px;")
    }
  }
  fields
}



# This function takes a data frame and creates a value/label data.frame for use
# in selectInputs
valueLabel <- function(df, value, label) {
  x <- setNames(
    as.character(df[[value]]),
    df[[label]]
  )
  x <- x[sort(names(x))]
  return(x)
}

# special case for when value/label is projectID/projectName
valueLableProject <- function(df, value, label) {
  # Creates the new label
  label <- paste(df[[value]], df[["projectPIName"]], "-", df[[label]])
  x <- setNames(
    as.character(df[[value]]),
    label
  )
  x <- x[sort(names(x))]
  return(x)
}




# Function that grabs the rowID for the row to view the details on
parseDeleteEvent <- function(idstr) {
  res <- as.integer(sub(".*_([0-9]+)", "\\1", idstr))
  if (!is.na(res)) res
}



# This function is used to compile a two column data.frame into a simple html
# table to be displayed underneath an input to provide additional notes and
# directions for an input.
inputNotesTable <- function(x) {
  # td elements
  tdElements <- apply(x, 1, function(y) {lapply(y, tags$td)})
  withTags({
    table(class = "input-notes-table",
          lapply(tdElements, tr)
    )
  })
}

