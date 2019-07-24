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

    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/serverScripts/serverAddProject.R", 
      local = TRUE)
    
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
    
    

# Reactives for add time --------------------------------------------------
    cleanTimeFormData <-
      reactive({
        timeFormResponse <- sapply(addTimeFields, function(x) {
          if (grepl("date", x, ignore.case = TRUE)) {
            as.character(input[[x]])
          } 
          else if (grepl("workBy", x)) {
            people[people$name == input[[x]], "uteid", drop = TRUE]
          } 
          else {
            input[[x]]
          }
        })
        timeFormResponse
      })
    
    # This is what controls what happens when the submit button on the add time
    # tab is pressed
    observeEvent(
      input$submitAddTime, {
        # creates and displays table of inputs
        saveTimeFormData(cleanTimeFormData())
        
        # Clears data from the forms
        sapply(addTimeFields, function(x) {
          updateTextInput(session, x, value = "")
          session$sendCustomMessage(type = "resetValue", message = x)
        })
        
        # creates button to submit data to database once a form is submitted
        output$timeToDatabase <- renderUI({
          actionButton("timeToDatabase", "Add data above to the database")
        })
      }
    )
    
    output$timeFormResponses <- DT::renderDataTable({
      input$submitAddTime
      loadTimeFormData()})
    
    observeEvent(
      input$timeToDatabase, {
        dbWriteTable(BDSHProjects, "effort", timeFormData, append = TRUE)
        timeFormData <<- timeFormData[c(), ]
        
        output$timeFormResponses <- DT::renderDataTable({
          input$submitAddTime
          loadTimeFormData()})
        
        # reload database
        #loadDatabase()
        
      }
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