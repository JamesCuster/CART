# Add Reactives for add time --------------------------------------------------

# Creats the datatable to display add time queue
output$timeFormData <- 
  renderDataTable({
    loadTimeFormData()
  })


# 1.1 Clean Form Data -------------------------------------------------------
#reactive that cleans the form data after added to queue is pressed. Used in 1.2
cleanTimeFormData <-
  reactive({
    timeFormResponse <- sapply(addTimeFields, function(x) {
      if (grepl("date", x, ignore.case = TRUE)) {
        as.character(input[[x]])
      } 
      else if (x %in% "workByName") {
        x <- gsub("Name", "", x)
        input[[x]]
      }
      else if (length(input[[x]]) == 0 || x == "effortID" || input[[x]] == ''|| is.na(input[[x]])) {
        return(NA)
      }
      else if (grepl("workBy", x)) {
        employees[employees$employeeName == input[[x]], "employeeUteid", drop = TRUE]
      }
      else {
        input[[x]]
      }
    })
    timeFormResponse <<- timeFormResponse
  })


# 1.2 Add To Queue Button -------------------------------------------------
# This is what controls what happens when the add to queue button on the add time
# form is pressed
observeEvent(
  input$submitAddTime, {
    # creates and displays table of inputs
    saveTimeFormData(cleanTimeFormData())

    # Clears data from the forms
    sapply(
      addTimeFields, 
      function(x) {
        updateTextInput(session, x, value = "")
        session$sendCustomMessage(type = "resetValue", message = x)
      }
    )
    
    # Creats the datatable to display add time queue
    output$timeFormData <- 
      renderDataTable({
        loadTimeFormData()
      })
  }
)


# 1.3 Save To Database Button -----------------------------------------------
#This controls what happens when the save to databse button is pressed on the
#add time page
observeEvent(
  input$timeToDatabase, {
    # remove variables that are not saved to database (Peoples names)
    timeFormData <- timeFormData[, !(names(timeFormData) %in% "workByName")]
    
    # Write table to database
    dbWriteTable(BDSHProjects, "effort", timeFormData, append = TRUE)
    
    # clear data.frame after added to database
    timeFormData <<- timeFormData[c(), ]
    
    # Creats the datatable to display add time queue
    output$timeFormData <- 
      renderDataTable({
        loadTimeFormData()
      })
  }
)


# 1.4 Delete Row Table Buttons ----------------------------------------------
# This controls what happens when the delete buttons on the timeForm
# datatable are pressed
observeEvent(
  input$timeFormDataDelete, {
    # identify row to be deleted
    rowID <- parseDeleteEvent(input$timeFormDataDelete)
    
    # delete row from data.frame
    timeFormData <- timeFormData[-rowID, ]
    
    # reset data.frame's row.names, remove rowID, and save timeFormData to
    # global environment
    row.names(timeFormData) <- NULL
    rowID <- NULL
    timeFormData <<- timeFormData
    
    # Re-render the table for display in the UI
    output$timeFormData <-
      renderDataTable({
        loadTimeFormData()
      })
  }
)


# 1.5 Edit Row Table Buttons ------------------------------------------------
# # This controls what happens when the edit buttons on the timeForm
# datatable are pressed
observeEvent(
  input$timeFormDataEdit, {
    # identify row to be edited
    rowID <- parseDeleteEvent(input$timeFormDataEdit)
    
    # Grab row to be edited
    edit <- timeFormData[rowID, ]
    
    # Remove the row to be edited from the data.frame/table
    timeFormData <- timeFormData[-rowID, ]
    
    # reset data.frame's row.names, remove rowID, and save timeFormData to
    # global environment
    row.names(timeFormData) <- NULL
    rowID <- NULL
    timeFormData <<- timeFormData
    
    # Put the values of the row to be updated back into the form
    sapply(
      names(timeFormData[-1]),
      function(x) {
        updateTextInput(
          session,
          inputId = x,
          value = edit[, x]
        )
      }
    )
    
    # Re-render table after the row to edit has been removed
    output$timeFormData <-
      renderDataTable({
        loadTimeFormData()
      })
  }
)

# 1.6 Add Time As Category --------------------------------------------------
# This part changes the input depending on value of input$timeAsCat
output$workTime <- renderUI({
  if (input$timeAsCat %% 2 == 0) {
    tagList(
      textInput(
        inputId = "workTime", 
        label = "Time spent in hours as numeric"
      ),
      tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;")
    )
  } else {
    tagList(
      selectizeInput(
        inputId = "workTimeCategory",
        label = "Effort Category",
        choices = c("Small", "Medium", "Large"),
        options = list(
          placeholder = NA,
          onInitialize = I("function() {this.setValue('');}")
        )
      ),
      tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;")
    )
  }
})

# This part changes the button depending on value of input$timeAsCat
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

# 
# observeEvent(
#   input$timeAsCat, {
#     output$timeAsCat <- renderUI(
#       selectizeInput(
#         inputId = "workTimeCategory",
#         label = "Effort Category",
#         choices = c("Small", "Medium", "Large"),
#         options = list(
#           placeholder = NA,
#           onInitialize = I("function() {this.setValue('');}")
#         )
#       )
#     )
#   }
# )