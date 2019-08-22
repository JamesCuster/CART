
# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {

# 1 Database functionalities ------------------------------------------------

    BDSHProjects <- dbConnect(SQLite(), paste0(dirPath, "/BDSHProjects.sqlite"))
    
# 1.1 Monitor Database ------------------------------------------------------
# This reactive checks the modified table in the database against the one loaded
# into the app every second. If the modified table has been updated in the
# database then the table that was modifed is reloaded into the app
    monitorDatabase <- 
      reactivePoll(
        intervalMillis = 1000,
        session,
        checkFunc = function() {
          modifiedCurrent <- tbl(BDSHProjects, "modified") %>% 
            collect() %>% 
            as.data.frame(stringsAsfactors = FALSE)
          if (as.POSIXct(modified$modified) < as.POSIXct(modifiedCurrent$modified)) {
            modified <<- modifiedCurrent
            return(TRUE)
          } else {
            return(FALSE)
          }
        },
        valueFunc = function() {
          loadDatabase(tables = modified$tableName)
        }
      )
    
    # observe which applies the monitorDatabase reactive
    observe({
      monitorDatabase()
    })
    
    
    
# Database Callback Functions ---------------------------------------------
    # These functions are used to create SQL queries which manipulate the database
    
    # creates insert SQL query
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
            if (is.null(input[[x]]) || is.na(input[[x]]) || class(input[[x]]) == "Date" ||input[[x]] == "") {
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
    
    
    # Creates update SQL query
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
            if (class(input[[x]]) == "Date" || input[[x]] == "") {
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
    
    
    
# 3 Server Scripts ----------------------------------------------------------
    
    # Projects
    source(
      paste0(dirPath, "/app/serverScripts/serverProjects.r"),
      local = TRUE
    )
    
    # Time
    source(
      paste0(dirPath, "/app/serverScripts/serverTime.r"),
      local = TRUE
    )
    
    # People
    source(
      paste0(dirPath, "/app/serverScripts/serverPeople.r"),
      local = TRUE
    )
    
    
    
# 4. On App Disconnect ----------------------------------------------------
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
    })
  }
)