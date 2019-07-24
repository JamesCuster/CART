# Reactives ---------------------------------------------------------------

# Reactive to clean addProject after submit button is pressed
cleanProjectFormData <-
  reactive({
    projectFormResponse <- 
      sapply(
        addProjectFields, 
        function(x) {
          if (grepl("date", x, ignore.case = TRUE)) {
            as.character(input[[x]])
          } 
          else if (grepl("projectID", x)) {
            NA
          } 
          else if (x %in% addProjectFieldsBDSH) {
            people[people$name == input[[x]], "uteid", drop = TRUE]
          } 
          else if (x %in% addProjectFieldsResearchers) {
            researchers[researchers$name == input[[x]], "uteid", drop = TRUE]
          } 
          else {
            input[[x]]
        }
    })
    projectFormResponse
  })


# Observe Events ----------------------------------------------------------

# controls actions when add to queue is pressed
observeEvent(
  input$submitAddProject, {
    # creates and displays table of inputs
    saveProjectFormData(cleanProjectFormData())
    
    # Clears data from the forms
    sapply(addProjectFields, function(x) {
      updateTextInput(session, x, value = "")
      session$sendCustomMessage(type = "resetValue", message = x)
    })
  }
)


# controls actions when Save to Database is pressed
observeEvent(
  input$projectToDatabase, {
    dbWriteTable(BDSHProjects, "projects", projectFormData, append = TRUE)
    projectFormData <<- projectFormData[c(), ]
    
    # output$projectFormResponses <- 
    #   DT::renderDataTable({
    #     input$submitAddProject
    #     loadProjectFormData()
    #   })
    
    # reload database after submission
    loadDatabase()
    
    # update inputs after data is reloaded
    updateSelectInput(session, "projectID", "Select the project to add time to", projects$projectName)
  }
)