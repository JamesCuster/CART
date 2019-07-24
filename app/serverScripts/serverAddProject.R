# Reactives ---------------------------------------------------------------

# Reactive to clean addProject after submit button is pressed
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
      actionButton("projectToDatabase", "Save To Database")
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
    
    # reload database
    loadDatabase()
    updateSelectInput(session, "projectID", "Select the project to add time to", projects$projectName)
  }
)