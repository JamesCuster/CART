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

# Reactives for addProject ------------------------------------------------

    # Creates reactive when addProject/Time submit buttons are pressed
    cleanProjectFormData <-
      reactive({
        projectFormResponse <- sapply(addProjectFields, function(x) {
          if (grepl("date", x, ignore.case = TRUE)) {
            as.character(input[[x]])
          } 
          else if (grepl("projectID", x)) {
            NA
          } 
          else if (grepl("bdshLead", x)) {
            people[people$name == input[[x]], "uteid", drop = TRUE]
          } 
          else {
            input[[x]]
          }
        })
        projectFormResponse
      })
    
    # Create reactive to reload data from database when it is edited
    # loadDatabaseReactive <-
    #   reactive({
    #     projects <- tbl(BDSHProjects, "projects") %>% collect()
    #     people <- tbl(BDSHProjects, "bdshPeople") %>% collect()
    #     effort <- tbl(BDSHProjects, "effort") %>% collect()
    #     researchers <- tbl(BDSHProjects, "researchers") %>% collect()
    #   })
    # loadDatabaseReactive()

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
    
    
# what happens when submit button on Add Projects is pressed
    observeEvent(
      input$submitAddProject, {
        # creates and displays table of inputs
        saveProjectFormData(cleanProjectFormData())
        
        # Clears data from the forms
        sapply(addProjectFields, function(x) {
          updateTextInput(session, x, value = "")
          session$sendCustomMessage(type = "resetValue", message = x)
        })
        
        # creates button to submit data to database once a form is submitted
        output$projectToDatabase <- renderUI({
          actionButton("projectToDatabase", "Add data above to the database")
        })
      }
    )
    
    output$projectFormResponses <- DT::renderDataTable({
      input$submitAddProject
      loadProjectFormData()})
    
    observeEvent(
      input$projectToDatabase, {
        dbWriteTable(BDSHProjects, "projects", projectFormData, append = TRUE)
        projectFormData <<- projectFormData[c(), ]
        
        output$projectFormResponses <- DT::renderDataTable({
          input$submitAddProject
          loadProjectFormData()})
        
        # # reload database
        loadDatabase()
      }
    )

    
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
        loadDatabase()
        
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