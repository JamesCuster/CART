# Add Reactives for add Researcher ----------------------------------------

# creates the datetable to display add researcher queue
output$researcherFormData <- 
  renderDataTable({
    loadResearcherFormData()
  })

# 1.1 Clean form data -------------------------------------------------------
# reactive that cleans form data after it has been added to queue. Used in 1.2
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


# 1.2 Add To Queue Button ---------------------------------------------------
# This controls what happens when the add to queue button on the add researcher
# form is pressed
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
    
    # creates the datetable to display add researcher queue
    output$researcherFormData <- 
      renderDataTable({
        loadResearcherFormData()
      })
  }
)


# 1.3 Save to Database Button -----------------------------------------------
# This controls what happens when the save to database button is pressed on the
# add researcher section
observeEvent(
  input$researcherToDatabase, {
    dbWriteTable(BDSHProjects, "researchers", researcherFormData, append = TRUE)
    researcherFormData <<- researcherFormData[c(), ]
    
    output$researcherFormData <- 
      renderDataTable({
        loadResearcherFormData()
      })
  }
)



# 1.4 Delete Table Row Buttons ----------------------------------------------
# This controls what happens when the delete buttons on the employeeForm
# datatable are pressed
observeEvent(
  input$researcherFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$researcherFormDataDelete)

    # delete row from data.frame
    researcherFormData <- researcherFormData[-rowID, ]

    # reset data.frame's row.names, remove rowID, and save researcherFormData to
    # global environment
    row.names(researcherFormData) <- NULL
    rowID <- NULL
    researcherFormData <<- researcherFormData

    # Re-render the table for display in the UI
    output$researcherFormData <-
      renderDataTable({
        loadResearcherFormData()
      })
  }
)


# 1.5 Edit Table Row Buttons ------------------------------------------------
# # This controls what happens when the edit buttons on the employeeForm
# datatable are pressed
observeEvent(
  input$researcherFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$researcherFormDataEdit)

    # Grab row to be edited
    edit <- researcherFormData[rowID, ]

    # Remove the row to be edited from the data.frame/table
    researcherFormData <- researcherFormData[-rowID, ]

    # reset data.frame's row.names, remove rowID, and save researcherFormData to
    # global environment
    row.names(researcherFormData) <- NULL
    rowID <- NULL
    researcherFormData <<- researcherFormData

    # Put the values of the row to be updated back into the form
    sapply(
      names(researcherFormData[-1]),
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = edit[, x]
        )
      }
    )

    # Re-render table after the row to edit has been removed
    output$researcherFormData <-
      renderDataTable({
        loadResearcherFormData()
      })
  }
)



# 2 Add Employee Reactives --------------------------------------------------

# Creates the datatable to display add employee queue
output$employeeFormData <- 
  renderDataTable({
    loadEmployeeFormData()
  })


# 2.1 Clean form Data -------------------------------------------------------
# reactive that cleans form data after it has been added to queue. Used in 2.2
cleanEmployeeFormData <-
  reactive({
    employeeFormResponse <- 
      sapply(
        addEmployeeFields, 
        function(x) {
          if (length(input[[x]]) == 0 || input[[x]] == ''|| is.na(input[[x]])) {
            return(NA)
          } else {
            input[[x]]
          }
        }
      )
    employeeFormResponse <<- employeeFormResponse
  })

# 2.2 Add To Queue Button ---------------------------------------------------
# This controls what happens when the add to queue button on the add employee
# tab is pressed
observeEvent(
  input$submitAddEmployee, {
    # creates and displays table of inputs
    saveEmployeeFormData(cleanEmployeeFormData())
    
    # Clears data from the input forms
    sapply(
      addEmployeeFields, 
      function(x) {
        updateTextInput(session, x, value = "")
        session$sendCustomMessage(type = "resetValue", message = x)
      }
    )
    
    # Creates the datatable to display add employee queue
    output$employeeFormData <- 
      renderDataTable({
        loadEmployeeFormData()
      })
  }
)


# 2.3 Save To Database Button -----------------------------------------------
# This controls what happens when the save to database button is pressed on the
# add employee section
observeEvent(
  input$employeeToDatabase, {
    
    dbWriteTable(
      BDSHProjects, 
      "employees", 
      employeeFormData, 
      append = TRUE)
    
    employeeFormData <<- employeeFormData[c(), ]
    
    output$employeeFormData <- 
      renderDataTable({
        loadEmployeeFormData()
      })
  }
)


# 2.4 Delete Table Row Buttons ----------------------------------------------
# This controls what happens when the delete buttons on the employeeForm
# datatable are pressed
observeEvent(
  input$employeeFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$employeeFormDataDelete)

    # delete row from data.frame
    employeeFormData <- employeeFormData[-rowID, ]

    # reset data.frame's row.names, remove rowID, and save employeeFormData to
    # global environment
    row.names(employeeFormData) <- NULL
    rowID <- NULL
    employeeFormData <<- employeeFormData

    # Re-render the table for display in the UI
    output$employeeFormData <-
      renderDataTable({
        loadEmployeeFormData()
      })
  }
)


# 2.5 Edit Table Row Buttons ------------------------------------------------
# This controls what happens when the edit buttons on the employeeForm
# datatable are pressed
observeEvent(
  input$employeeFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$employeeFormDataEdit)

    # Grab row to be edited
    edit <- employeeFormData[rowID, ]

    # Remove the row to be edited from the data.frame/table
    employeeFormData <- employeeFormData[-rowID, ]

    # reset data.frame's row.names, remove rowID, and save employeeFormData to
    # global environment
    row.names(employeeFormData) <- NULL
    rowID <- NULL
    employeeFormData <<- employeeFormData

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
    output$employeeFormData <-
      renderDataTable({
        loadEmployeeFormData()
      })
  }
)