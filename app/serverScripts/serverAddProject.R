# Add Reactives For Add Project ---------------------------------------------

# Creates the datatable to dislay add project queue
output$projectFormData <-
  renderDataTable({
    loadProjectFormData()
  })

# 1.1 Clean form Data -------------------------------------------------------
# reactive that cleans form data after it has been added to queue. Used in 1.2
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
          else if (x %in% addProjectPeopleNames) {
            x <- gsub("Name", "", x)
            input[[x]]
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


# 1.2 Add To Queue Button ---------------------------------------------------

# This controls what heppens when the add to queue button on the add project
# form is pressed
observeEvent(
  input$submitAddProject, {
    # creates and displays table of inputs
    saveProjectFormData(cleanProjectFormData())
    
    # Clears data from the forms
    sapply(
      addProjectFields, 
      function(x) {
        updateTextInput(session, x, value = "")
        session$sendCustomMessage(type = "resetValue", message = x)
      }
    )
    
    # creates the datetable to display add researcher queue
    output$projectFormData <-
      renderDataTable({
        loadProjectFormData()
      })
  }
)


# 1.3 Save To Database Button -----------------------------------------------
# This controls what happens when the save to database button is pressed on the
# add project section
observeEvent(
  input$projectToDatabase, {
    # remove variables that are not saved to database (Peoples Names)
    projectFormData <- projectFormData[, !(names(projectFormData) %in% addProjectPeopleNames)]
    
    # Write table to database
    dbWriteTable(BDSHProjects, "projects", projectFormData, append = TRUE)
    
    # Clear data.frame after added to database
    projectFormData <<- projectFormData[c(), ]
    
    # render the now blank data.frame to be displayed in the UI
    output$projectFormData <-
      renderDataTable({
        loadProjectFormData()
      })
  }
)


# 1.4 Delete Row Table Buttons --------------------------------------------
# This controls what happens when the delete buttons on the employeeForm
# datatable are pressed
observeEvent(
  input$projectFormDataDelete, {
    
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$projectFormDataDelete)
    
    # delete row from data.frame
    projectFormData <- projectFormData[-rowID, ]
    
    # reset data.frame's row.names, remove rowID, and save projectFormData to
    # global environment
    row.names(projectFormData) <- NULL
    rowID <- NULL
    projectFormData <<- projectFormData
    
    # Re-render the table for display in the UI
    output$projectFormData <-
      renderDataTable({
        loadProjectFormData()
      })
  }
)


# 1.5 Edit Row Table Buttons ------------------------------------------------
# # This controls what happens when the edit buttons on the projectForm
# datatable are pressed
observeEvent(
  input$projectFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$projectFormDataEdit)
    
    # Grab row to be edited
    edit <- projectFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    projectFormData <- projectFormData[-rowID, ]
    
    # reset data.frame's row.names, remove rowID, and save projectFormData to
    # global environment
    row.names(projectFormData) <- NULL
    rowID <- NULL
    projectFormData <<- projectFormData
    
    # Put the values of the row to be updated back into the form
    sapply(
      names(projectFormData[-1]),
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = edit[, x]
        )
      }
    )
    
    # Re-render table after the row to edit has been removed
    output$projectFormData <-
      renderDataTable({
        loadProjectFormData()
      })
  }
)
