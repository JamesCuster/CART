
# 1 Helper Functions And Objects ------------------------------------------

# Add time form inputs
addTimeInputs <- 
  c("effortID",
    "timeProjectID",
    "workBy",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")

# addTimeFormData variables
addTimeFields <- 
  c("Delete",
    "Edit",
    "effortID",
    "timeProjectID",
    "timeProjectName",
    "workBy",
    "workByName",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")

addTimeRemoveForDatabase <- 
  c("Delete",
    "Edit",
    "timeProjectName", 
    "workByName")


# 2 Reactives ---------------------------------------------------------------

# 2.1 addTimeFormData reactive --------------------------------------------
# make reactive data.frame for addTimeFormData
reactiveFormData$timeFormData <- 
  setNames(data.frame(matrix(nrow = 0, ncol = 13)), addTimeFields)


# 2.2 cleanTimeFormData reactive ------------------------------------------
# Reactive that cleans form data to be converted to data.frame
cleanTimeFormData <-
  reactive({
    #browser()
    timeFormResponse <- sapply(addTimeFields, function(x) {
      if (x %in% c("dateOfWork", "dateOfEntry")) {
        as.character(input[[x]])
      }
      # takes the projectID and fetches projectName from projects data.frame
      else if (x %in% "timeProjectName") {
        y <- gsub("Name", "ID", x)
        # This uses the projectID used above to fetch projectName
        projects[projects$projectID == input[[y]], "projectName", drop = TRUE]
      }
      else if (x %in% "workByName") {
        y <- gsub("Name", "", x)
        employees[employees$bdshID == input[[y]], "employeeName", drop = TRUE]
      }
      
      # projectID is handled by database. Delete/Edit are added when Add To
      # Queue is pressed
      else if (x %in% c("Delete", "Edit", "effortID")) {
        NA
      }
      else if (input[[x]] == "" || is.null(input[[x]])) {
        NA
      }
      else {
        input[[x]]
      }
    })
  })



# 3 Observers ---------------------------------------------------------------

# 3.1 Add To Queue button -------------------------------------------------
observeEvent(
  input$submitAddTime, {
    # Applies the cleanTimeFormData reactive and converts it to data.frame
    timeFormResponse <- as.data.frame(t(cleanTimeFormData()), stringsAsFactors = FALSE)
    
    # Adds timeFormResponses to the timeFormData reactive
    reactiveFormData$timeFormData <- rbind(reactiveFormData$timeFormData, timeFormResponse)
    
    # adds the Delete/Edit links to timeFormData
    reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
    
    # Resets the addTime form inputs to defaults
    sapply(
      addTimeInputs,
      function(x) {
        reset(x)
      }
    )
  })


# 3.2 Save To Database button ---------------------------------------------
observeEvent(
  input$timeToDatabase, {
    # remove variables that are not saved to database (Peoples Names,
    # delete/edit links, values/labels variables)
    timeFormData <-
      reactiveFormData$timeFormData[, !(names(reactiveFormData$timeFormData) %in% addTimeRemoveForDatabase)]
    
    # Write table to database
    dbWriteTable(BDSHProjects, "effort", timeFormData, append = TRUE)
    
    # Clear reactive data.frame after added to database
    reactiveFormData$timeFormData <- reactiveFormData$timeFormData[c(), ]
  }
)


# 3.3 Table Link Delete Row -------------------------------------------------
# This controls what happens when the delete buttons on the time form
# datatable are pressed
observeEvent(
  input$timeFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$timeFormDataDelete)
    
    # delete row from data.frame
    reactiveFormData$timeFormData <- reactiveFormData$timeFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$timeFormData) <- NULL
    reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
  }
)


# 3.4 Table Links Edit Row --------------------------------------------------
# # This controls what happens when the edit buttons on the time form
# datatable are pressed
observeEvent(
  input$timeFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$timeFormDataEdit)
    
    # Grab row to be edited
    editTime <<- reactiveFormData$timeFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    reactiveFormData$timeFormData <- reactiveFormData$timeFormData[-rowID, ]
    
    # reset data.frame's row.names and recalculate the Delete/Edit links
    row.names(reactiveFormData$timeFormData) <- NULL
    reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
    
    # When a row is edited, need to make sure the correct time input is used
    # (categry/hour). This will check which was used in the row to be edited,
    # and will make sure the UI displays it
    if (!is.na(editTime$workTime)) {
      if (!(input$timeAsCat %% 2 == 0)) {
        click("timeAsCat")
      }
    }
    else if (!is.na(editTime$workTimeCat)) {
      if (input$timeAsCat %% 2 == 0) {
        click("timeAsCat")
      }
    }
    
    # Repopulate the form with the values of row to be edited
    sapply(
      addTimeInputs,
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = editTime[, x]
        )
      }
    )
  }
)


# 3.5 Time As Category/Hours buttons --------------------------------------
observe({
  if (input$timeAsCat %% 2 == 0) {
    updateActionButton(
      session,
      inputId = "timeAsCat",
      label = "Enter As Category"
    )
  } else {
    updateActionButton(
      session,
      inputId = "timeAsCat",
      label = "Enter As Hours"
    )
  }
})



# 4 Output ------------------------------------------------------------------

# 4.1 Time Form Datatable ---------------------------------------------------
output$timeFormData <- 
  renderDataTable(
    datatable(
      reactiveFormData$timeFormData[-3], 
      escape = FALSE)
  )