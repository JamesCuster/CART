
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
      # Creates data.frame of field values for new entry
      new <- lapply(ids,
                    function(x) {
                      if (class(input[[x]]) == "Date") {
                        if (length(input[[x]]) == 0) {
                          NA
                        }
                        else {
                          as.character(input[[x]])
                        }
                      }
                      else if (is.null(input[[x]]) || length(input[[x]]) == 0 || input[[x]] == "") {
                        NA
                      }
                      else {
                        input[[x]]
                      }
                    }) %>% 
        setNames(ids) %>% 
        as.data.frame()
      
      # inserts new entry into database
      dbWriteTable(BDSHProjects, tab, new, append = TRUE)
    }
    
    
    # Creates update SQL query
    updateCallback <- function(ids, rowID, idVar, tab) {
      # Creates data.frame of updated field values
      new <- lapply(ids,
                    function(x) {
                      if (x == idVar) {
                        rowID
                      }
                      else if (class(input[[x]]) == "Date") {
                        if (length(input[[x]]) == 0) {
                          NA
                        }
                        else {
                          as.character(input[[x]])
                        }
                      }
                      else if (is.null(input[[x]]) || length(input[[x]]) == 0 || input[[x]] == "") {
                        NA
                      }
                      else {
                        input[[x]]
                      }
                    }) %>% 
        setNames(ids) %>% 
        as.data.frame(stringsAsFactors = FALSE)
      
      # creates update statement with named matching for values
      upStatement <- 
        paste0(
          "update ",
          tab,
          " set ",
          paste0("'", ids[!ids == idVar], "'= $", ids[!ids == idVar], collapse = ", "),
          " where ",
          idVar,
          "= $",
          idVar
        )
      
      up <- dbSendQuery(BDSHProjects, upStatement)
      # fills in upStatement with values from new data.frame
      dbBind(up, new)
      dbClearResult(up)
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
      stopApp()
    })
  }
)