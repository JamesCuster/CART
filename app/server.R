
# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {
    
    # # monitor database for changes
    # loaddb <- reactivePoll(1000, session)


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