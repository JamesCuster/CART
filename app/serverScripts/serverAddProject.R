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
          else if (length(input[[x]]) == 0 || input[[x]] == ''|| is.na(input[[x]])) {
            return(NA)
          }
          else if (x %in% addProjectFieldsBDSH) {
            employees[employees$employeeName == input[[x]], "employeeUteid", drop = TRUE]
          } 
          else if (x %in% addProjectFieldsResearchers) {
            researchers[researchers$researcherName == input[[x]], "researcherUteid", drop = TRUE]
          } 
          else {
            input[[x]]
        }
    })
    projectFormResponse <<- projectFormResponse
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


output$projectFormResponses <-
  DT::renderDataTable({
    input$submitAddProject
    loadProjectFormData()
  })

# controls actions when Save to Database is pressed
observeEvent(
  input$projectToDatabase, {
    dbWriteTable(BDSHProjects, "projects", projectFormData, append = TRUE)
    projectFormData <<- projectFormData[c(), ]
    
    output$projectFormResponses <-
      DT::renderDataTable({
        input$submitAddProject
        loadProjectFormData()
      })
    
    # reload database after submission
    loadDatabase()
    
    # update inputs after data is reloaded
    updateSelectizeInput(
      session,
      inputId = "timeProjectID",
      choices = projects$projectName
    )
  }
)