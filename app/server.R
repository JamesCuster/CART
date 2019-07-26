
# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {
    
    # monitor database for changes
    monitorDatabase <- 
      reactivePoll(
        intervalMillis = 1000,
        session,
        checkFunc = function() {
          modifiedCurrent <- tbl(BDSHProjects, "modified") %>% 
            collect() %>% 
            as.data.frame(stringsAsfactors = FALSE)
          if (modified$modified < modifiedCurrent$modified) {
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
    
    observe({monitorDatabase()})


# Server Scripts ----------------------------------------------------------

    # serverAddProject
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/serverScripts/serverAddProject.R", 
      local = TRUE
    )
    
    # serverAddTime
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking//app/serverScripts/serverAddTime.R",
      local = TRUE
    )
    
    #serverAddPeople
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking//app/serverScripts/serverAddPeople.R",
      local = TRUE
    )
    
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
      #rm()
      #    stopApp()
      #    quit("no")
    })
  }
)