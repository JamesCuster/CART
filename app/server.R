library(shiny)

# Project form functions
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


# Time form functions
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
    
    # This is an attempt to add "add researcher" option to add project tab
    # observeEvent({
    #   if ((input$submitNewResearcher) || (input$projectPI == "Add Researcher")) TRUE
    #       else return()
    # }, {
    #     # creates button to submit data to database once a form is submitted
    #     output$submitNewResearcher <- renderUI({
    #       tagList(
    #         tags$br(),
    #         textInputRow("name", "Researchers Name"),
    #         textInputRow("Email", "Researchers Email"),
    #         actionButton("researcherToDatabase", "Add researcher to the database"),
    #         tags$br(),
    #         tags$br()
    #       )
    #     })
    #   }
    # )
    
    


    
    
    
    
    
    
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
      #rm()
      #    stopApp()
      #    quit("no")
    })



  }
)



# timeFormData <-
#   reactive({
#     data <- sapply(addTimeFields, function(x) {
#       if (grepl("date", x, ignore.case = TRUE)) {
#         as.character(input[[x]])
#       } else {
#         input[[x]]
#       }
#     })
#     data
#   })
# 
# # what happens when submit button on Add Time is pressed
# observeEvent(
#   input$submitAddTime, {
#     output$timeFormResponses <- DT::renderDataTable(t(timeFormData()))
#   }
# )