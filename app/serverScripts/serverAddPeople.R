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
    
    # Reload database
    loadDatabase()
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
    dbWriteTable(BDSHProjects, "effort", employeeFormData, append = TRUE)
    employeeFormData <<- employeeFormData[c(), ]
    
    output$employeeFormResponses <- DT::renderDataTable({
      input$submitAddEmployee
      loadEmployeeFormData()})
    
    # reload database
    loadDatabase()
    
  }
)