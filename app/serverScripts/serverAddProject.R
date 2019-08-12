
# 1 Helper functions and objects --------------------------------------------

# 1.1 Vectors of input names and variable names in addProjectFormData -------

# Add project form inputs
addProjectInputs <- 
  c("projectName",
    "bdshLead",
    "bdshSecondary",
    "projectPI",
    "projectSupport1",
    "projectSupport2",
    "projectSupport3",
    "projectSupport4",
    "projectDescription",
    "projectStatus",
    "projectDueDate")

# projectFormData variables
addProjectFields <- 
  c("Delete",
    "Edit",
    "projectID",
    "projectName",
    "bdshLead",
    "bdshLeadName",
    "bdshSecondary",
    "bdshSecondaryName",
    "projectPI",
    "projectPIName",
    "projectSupport1",
    "projectSupport1Name",
    "projectSupport2",
    "projectSupport2Name",
    "projectSupport3",
    "projectSupport3Name",
    "projectSupport4",
    "projectSupport4Name",
    "projectDescription",
    "projectStatus",
    "projectDueDate")

# Researcher name variables
addProjectResearcherNames <- 
  c("projectPIName",
    "projectSupport1Name",
    "projectSupport2Name",
    "projectSupport3Name",
    "projectSupport4Name")

# Employee name variables
addProjectEmployeeNames <- 
  c("bdshLeadName",
    "bdshSecondaryName")

# variables that need to be removed from projectFormData before adding to
# database
addProjectRemoveForDatabase <- 
  c("Delete",
    "Edit",
    "projectPIName",
    "projectSupport1Name",
    "projectSupport2Name",
    "projectSupport3Name",
    "projectSupport4Name",
    "bdshLeadName",
    "bdshSecondaryName",
    "value",
    "label")


# 2 Reactives ---------------------------------------------------------------

# 2.1 addProjectFormData reactive -------------------------------------------
# make reactive data.frame for addProjectFormData
reactiveFormData$projectFormData <- 
  setNames(data.frame(matrix(nrow = 0, ncol = 21)), addProjectFields)

# 2.2 cleanProjectFormData reactive -----------------------------------------
# Reactive that cleans the form data to be converted to dataframe
cleanProjectFormData <-
  reactive({
    projectFormResponse <-
      sapply(
        addProjectFields,
        function(x) {
          # dates needs to be sent to database as character
          if (x %in% c("projectDueDate")) {
            as.character(input[[x]])
          }
          # If researcher names are used fetches name from researcher table
          else if (x %in% addProjectResearcherNames) {
            if (input[[gsub("Name", "", x)]] == "") {
              NA
            }
            else {
              x <- gsub("Name", "", x)
              researchers[researchers$researcherID == input[[x]], "researcherName", drop = TRUE]
            }
          }
          # If employee names are used fetches name from employee table
          else if (x %in% addProjectEmployeeNames) {
            if (input[[gsub("Name", "", x)]] == "") {
              NA
            }
            else {
              x <- gsub("Name", "", x)
              employees[employees$bdshID == input[[x]], "employeeName", drop = TRUE]
            }
          }
          # projectID is handled by database. Delete/Edit are added when Add To
          # Queue is pressed
          else if (x %in% c("Delete", "Edit", "projectID")) {
            NA
          }
          # handles inputs left blank
          else if (input[[x]] == "") {
            NA
          }
          # returns input value if it was given
          else {
            input[[x]]
          }
        }
      )
  })



# 3 Observers ---------------------------------------------------------------

# 3.1 Add To Queue button ---------------------------------------------------
observeEvent(
  input$submitAddProject, {
    # Applies the cleanProjectFormData reactive and converts it to data.frame
    projectFormResponse <- as.data.frame(t(cleanProjectFormData()), stringsAsFactors = FALSE)
    
    # Adds projectFormResponses to the projectFormData reactive
    reactiveFormData$projectFormData <- rbind(reactiveFormData$projectFormData, projectFormResponse)
    
    # adds the Delete/Edit links to projectFormData
    reactiveFormData$projectFormData <- addDeleteEditLink(reactiveFormData$projectFormData, "projectFormData")
    
    # Resets the addProject form inputs to defaults
    sapply(
      addProjectInputs,
      function(x) {
        reset(x)
      }
    )
  })


# 3.2 Save To Database button -----------------------------------------------
observeEvent(
  input$projectToDatabase, {
    # remove variables that are not saved to database (Peoples Names,
    # delete/edit links, values/labels variables)
    projectFormData <-
      reactiveFormData$projectFormData[, !(names(reactiveFormData$projectFormData) %in% addProjectRemoveForDatabase)]

    # Write table to database
    dbWriteTable(BDSHProjects, "projects", projectFormData, append = TRUE)

    # Clear reactive data.frame after added to database
    reactiveFormData$projectFormData <- reactiveFormData$projectFormData[c(), ]
  }
)


# 3.3 Table Link Delete Row -------------------------------------------------
# This controls what happens when the delete buttons on the project form
# datatable are pressed
observeEvent(
  input$projectFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$projectFormDataDelete)
    
    # delete row from data.frame
    reactiveFormData$projectFormData <- reactiveFormData$projectFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$projectFormData) <- NULL
    reactiveFormData$projectFormData <- addDeleteEditLink(reactiveFormData$projectFormData, "projectFormData")
  }
)


# 3.4 Table Links Edit Row --------------------------------------------------
# # This controls what happens when the edit buttons on the project form
# datatable are pressed
observeEvent(
  input$projectFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$projectFormDataEdit)
    
    # Grab row to be edited
    edit <- reactiveFormData$projectFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    reactiveFormData$projectFormData <- reactiveFormData$projectFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$projectFormData) <- NULL
    reactiveFormData$projectFormData <- addDeleteEditLink(reactiveFormData$projectFormData, "projectFormData")
    
    # Repopulate the form with the values of row to be edited
    sapply(
      addProjectInputs,
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



# 4 Output ------------------------------------------------------------------

# 4.1 Project Form Datatable ----------------------------------------------
output$projectFormData <-
  renderDataTable(
    datatable(reactiveFormData$projectFormData[-3], escape = FALSE)
  )