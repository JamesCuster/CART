# Add Reactives for add Researcher ----------------------------------------
cleanResearcherFormData <- reactive({
  researcherFormResponse <- 
    sapply(
      addResearcherFields,
      function(x) {
        if (length(input[[x]]) == 0 || input[[x]] == ''|| is.na(input[[x]])) {
          return(NA)
        } else {
          input[[x]]
        }
      }
    )
  researcherFormResponse <<- researcherFormResponse
})


# controls what happens when submit researcher button is pressed
observeEvent(
  input$submitAddResearcher, {
    saveResearcherFormData(cleanResearcherFormData())
    
    # Clears form data
    sapply(
      addResearcherFields,
      function(x) {
        updateTextInput(session, x, value = "")
        session$sendCustomMessage(type = "resetValue", message = x)
      }
    )
  }
)


# creates the researcher queue table
output$researcherFormResponses <- DT::renderDataTable({
  input$submitAddResearcher
  loadResearcherFromData()
})


# Controls what happens when Save To Database is pressed
observeEvent(
  input$researcherToDatabase, {
    dbWriteTable(BDSHProjects, "researchers", researcherFormData, append = TRUE)
    researcherFormData <<- researcherFormData[c(), ]
    
    output$researcherFormResponses <- DT::renderDataTable({
      input$submitAddResearcher
      loadResearcherFromData()
    })
  }
)

# Add Reactives for add BDSH employee -------------------------------------
cleanEmployeeFormData <-
  reactive({
    employeeFormResponse <- sapply(addEmployeeFields, function(x) {
      if (length(input[[x]]) == 0 || input[[x]] == ''|| is.na(input[[x]])) {
        return(NA)
      } else {
        input[[x]]
      }
    })
    employeeFormResponse <<- employeeFormResponse
  })

# This is what controls what happens when the submit button on the add employee
# tab is pressed
observeEvent(
  input$submitAddEmployee, {
    # creates and displays table of inputs
    saveEmployeeFormData(cleanEmployeeFormData())
    
    # Clears data from the forms
    sapply(
      addEmployeeFields, 
      function(x) {
        updateTextInput(session, x, value = "")
        session$sendCustomMessage(type = "resetValue", message = x)
      }
    )
  }
)

output$employeeFormResponses <- DT::renderDataTable({
  input$submitAddEmployee
  loadEmployeeFormData()
})

observeEvent(
  input$employeeToDatabase, {
    dbWriteTable(BDSHProjects, "employees", employeeFormData, append = TRUE)
    employeeFormData <<- employeeFormData[c(), ]
    
    output$employeeFormResponses <- DT::renderDataTable({
      input$submitAddEmployee
      loadEmployeeFormData()})
  }
)


# handling the delete buttons on the employeeForm datatable
observeEvent(
  input$deletePressed, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$deletePressed)
    
    # delete row from data.frame
    employeeFormData <- employeeFormData[-rowID, ]
    
    # reset data.frame's row.names, remove rowID, and save employeeFormData to
    # global environment
    row.names(employeeFormData) <- NULL
    rowID <- NULL
    employeeFormData <<- employeeFormData
    
    # Re-render the table for display in the UI
    output$employeeFormResponses <- DT::renderDataTable({
      input$submitAddEmployee
      loadEmployeeFormData()})
  }
)


# handling the edit buttons on the employeeForm datatable
observeEvent(
  input$editPressed, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$editPressed)
    
    # Grab row to be edited
    edit <- employeeFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    employeeFormData <<- employeeFormData[-rowID, ]
    
    # Put the values of the row to be updated back into the form
    sapply(
      names(employeeFormData[-1]),
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = edit[, x]
        )
      }
    )
    
    # Re-render table after the row to edit has been removed
    output$employeeFormResponses <- DT::renderDataTable({
      input$submitAddEmployee
      loadEmployeeFormData()})
  }
)