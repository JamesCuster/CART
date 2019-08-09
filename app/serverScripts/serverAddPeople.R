#310
# todos ---------------------------------------------------------------------
# modify checkDuplicateResearcher/Employee to have checks on names as well?

# 1 Add Researcher Helper functions and objects --------------------------------

# 1.1 Vectors of input names and variable names in addResearcherFormData -------
# addResearcher form inputs
addResearcherInputs <- 
  c("Delete",
    "Edit",
    "researcherID",
    "researcherUteid",
    "researcherName",
    "researcherEmail",
    "primaryDept",
    "secondaryDept"
  )

# researcherFromData variables
addResearcherFields <- 
  c("Delete",
    "Edit",
    "researcherID",
    "researcherUteid",
    "researcherName",
    "researcherEmail",
    "primaryDept",
    "secondaryDept"
  )

# variables that need to be removed from reseearcherFormData before adding to
# database
addResearcherRemoveForDatabase <- 
  c("Delete",
    "Edit",
    "value",
    "label")


# 2 Add Researcher Reactives ------------------------------------------------

# 2.1 addResearcherFormData reactive ----------------------------------------
# make reactive data.frame for addResearcherFormData
reactiveFormData$researcherFormData <- 
  setNames(data.frame(matrix(nrow = 0, ncol = 8)), addResearcherFields)


# 2.2 cleanResearcherFormData -----------------------------------------------
# reactive that cleans form data after added to queue is pressed. Used in 1.2
cleanResearcherFormData <- reactive({
  #browser()
  researcherFormResponse <- 
    sapply(
      addResearcherFields,
      function(x) {
        # researcherID is handled by database. Delete/Edit are added when Add To
        # Queue is pressed
        if (x %in% c("Delete", "Edit", "researcherID")) {
          NA
        }
        else if (input[[x]] == "") {
          NA
        } else {
          input[[x]]
        }
      }
    )
})


# 2.3 checkDuplicateResearcher reactive -------------------------------------
# Checks if researcher is already in database
checkDuplicateResearcher <- reactive({
  if (input[["researcherUteid"]] %in% researchers$researcherUteid) {
    TRUE
  } else {
    FALSE
  }
})



# 3 Add Researcher Observers ------------------------------------------------

# 3.1 Add To Queue Button ---------------------------------------------------
observeEvent(
  input$submitAddResearcher, {
    # Check if input is a duplicate if so return error in UI otherwise proceed
    if (checkDuplicateResearcher()) {
      output$checkDuplicateResearcher <- 
        renderText(
          "Warning: The researcher UTeid you input already exisit in the researchers table")
    } else {
      # Applies the cleanResearcherFormData reactive and converts it to data.frame
      researcherFormResponse <- as.data.frame(t(cleanResearcherFormData()), stringsAsFactors = FALSE)
      
      # Adds researcherFormResponses to the researcherFormData reactive
      reactiveFormData$researcherFormData <- rbind(reactiveFormData$researcherFormData, researcherFormResponse)
      
      # adds the Delete/Edit links to researcherFormData
      reactiveFormData$researcherFormData <- addDeleteEditLink(reactiveFormData$researcherFormData, "researcherFormData")
      
      # Resets the addProject form inputs to defaults
      sapply(
        addResearcherFields,
        function(x) {
          reset(x)
        }
      )
    }
    
  }
)


# 3.2 Save To Database button ---------------------------------------------
observeEvent(
  input$researcherToDatabase, {
    # remove variables that are not saved to database (delete/edit links,
    # values/labels variables)
    researcherFormData <-
      reactiveFormData$researcherFormData[, !(names(reactiveFormData$researcherFormData) %in% addResearcherRemoveForDatabase)]
    
    # Write table to database
    dbWriteTable(BDSHProjects, "researchers", researcherFormData, append = TRUE)
    
    # Clear reactive data.frame after added to database
    reactiveFormData$researcherFormData <- reactiveFormData$researcherFormData[c(), ]
  }
)


# 3.3 Table Link Delete Row -----------------------------------------------
# This controls what happens when the delete buttons on the researcherForm
# datatable are pressed
observeEvent(
  input$researcherFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$researcherFormDataDelete)
    
    # delete row from data.frame
    reactiveFormData$researcherFormData <- reactiveFormData$researcherFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$researcherFormData) <- NULL
    reactiveFormData$researcherFormData <- addDeleteEditLink(reactiveFormData$researcherFormData, "researcherFormData")
  }
)


# 3.4 Table Link Edit Row -------------------------------------------------
# # This controls what happens when the edit buttons on the researcherForm
# datatable are pressed
observeEvent(
  input$researcherFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$researcherFormDataEdit)
    
    # Grab row to be edited
    edit <- reactiveFormData$researcherFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    reactiveFormData$researcherFormData <- reactiveFormData$researcherFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$researcherFormData) <- NULL
    reactiveFormData$researcherFormData <- addDeleteEditLink(reactiveFormData$researcherFormData, "researcherFormData")
    
    # Repopulate the form with the values of row to be edited
    sapply(
      addResearcherInputs,
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = edit[, x]
        )
      }
    )
  }
)


# Output --------------------------------------------------------------------
output$researcherFormData <- 
  renderDataTable({
    datatable(reactiveFormData$researcherFormData[-3], escape = FALSE)
  })



# 4 Add Employee Helper Objects and Functions -------------------------------

# Add employee form inputs
addEmployeeInputs <- 
  c("employeeUteid",
    "employeeName",
    "employeeEmail",
    "degree",
    "role"
  )

# addEmployeeFormData variables
addEmployeeFields <- 
  c("Delete", 
    "Edit",
    "bdshID",
    "employeeUteid",
    "employeeName",
    "employeeEmail",
    "degree",
    "role"
  )

# variables that need to be removed from employeeFormData before adding to
# database
addEmployeeRemoveForDatabase <- 
  c("Delete",
    "Edit",
    "value",
    "label")


# 5 Add Employee Reactives --------------------------------------------------

# 5.1 addEmployeeFormData reactive -------------------------------------------
# make reactive data.frame for addEmployeeFormData
reactiveFormData$employeeFormData <- 
  setNames(data.frame(matrix(nrow = 0, ncol = 8)), addEmployeeFields)


# reactive that cleans form data after it has been added to queue. Used in 2.2
cleanEmployeeFormData <-
  reactive({
    employeeFormResponse <- 
      sapply(
        addEmployeeFields, 
        function(x) {
          # researcherID is handled by database. Delete/Edit are added when Add To
          # Queue is pressed
          if (x %in% c("Delete", "Edit", "bdshID")) {
            NA
          }
          else if (input[[x]] == "") {
            return(NA)
          } else {
            input[[x]]
          }
        }
      )
    employeeFormResponse
  })


# 5.3 checkDuplicateEmployee reactive ---------------------------------------
# Checks if employee is already in database
checkDuplicateEmployee <- reactive({
  if (input[["employeeUteid"]] %in% employees$employeeUteid) {
    TRUE
  } else {
    FALSE
  }
})



# 6 Add Employee Observers ------------------------------------------------

# 6.1 Add To Queue Button ---------------------------------------------------
# This controls what happens when the add to queue button on the add employee
# tab is pressed
observeEvent(
  input$submitAddEmployee, {
    # Check if input is a duplicate if so return error in UI otherwise proceed
    if (checkDuplicateEmployee()) {
      output$checkDuplicateEmployee <- 
        renderText(
          "Warning: The employee UTeid you input already exisit in the employees table")
    } else {
      # Applies the cleanEmployeeFormData reactive and converts it to data.frame
      employeeFormResponse <- as.data.frame(t(cleanEmployeeFormData()), stringsAsFactors = FALSE)
      
      # Adds employeeFormResponses to the employeeFormData reactive
      reactiveFormData$employeeFormData <- rbind(reactiveFormData$employeeFormData, employeeFormResponse)
      
      # adds the Delete/Edit links to employeeFormData
      reactiveFormData$employeeFormData <- addDeleteEditLink(reactiveFormData$employeeFormData, "employeeFormData")
      
      # Resets the addEmployee form inputs to defaults
      sapply(
        addEmployeeInputs,
        function(x) {
          reset(x)
        }
      )
    }
  }
)


# 6.2 Save To Database button -----------------------------------------------
observeEvent(
  input$employeeToDatabase, {
    # remove variables that are not saved to database (Peoples Names,
    # delete/edit links, values/labels variables)
    employeeFormData <-
      reactiveFormData$employeeFormData[, !(names(reactiveFormData$employeeFormData) %in% addEmployeeRemoveForDatabase)]
    
    # Write table to database
    dbWriteTable(BDSHProjects, "employees", employeeFormData, append = TRUE)
    
    # Clear reactive data.frame after added to database
    reactiveFormData$employeeFormData <- reactiveFormData$employeeFormData[c(), ]
  }
)


# 6.3 Table Link Delete Row -------------------------------------------------
# This controls what happens when the delete buttons on the employee form
# datatable are pressed
observeEvent(
  input$employeeFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$employeeFormDataDelete)
    
    # delete row from data.frame
    reactiveFormData$employeeFormData <- reactiveFormData$employeeFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$employeeFormData) <- NULL
    reactiveFormData$employeeFormData <- addDeleteEditLink(reactiveFormData$employeeFormData, "employeeFormData")
  }
)


# 6.4 Table Links Edit Row --------------------------------------------------
# # This controls what happens when the edit buttons on the employee form
# datatable are pressed
observeEvent(
  input$employeeFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$employeeFormDataEdit)
    
    # Grab row to be edited
    edit <- reactiveFormData$employeeFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    reactiveFormData$employeeFormData <- reactiveFormData$employeeFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$employeeFormData) <- NULL
    reactiveFormData$employeeFormData <- addDeleteEditLink(reactiveFormData$employeeFormData, "employeeFormData")
    
    # Repopulate the form with the values of row to be edited
    sapply(
      addEmployeeInputs,
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = edit[, x]
        )
      }
    )
  }
)



# Output --------------------------------------------------------------------
output$employeeFormData <-
  renderDataTable(
    datatable(reactiveFormData$employeeFormData[-3], escape = FALSE)
  )