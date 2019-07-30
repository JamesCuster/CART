# Reactives for add time --------------------------------------------------
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

# This is what controls what happens when the submit button on the add time
# tab is pressed
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
  }
)

output$timeFormData <- DT::renderDataTable({
  input$submitAddTime
  loadTimeFormData()
})

observeEvent(
  input$timeToDatabase, {
    # remove variables that are not saved to database (Peoples names)
    timeFormData <- timeFormData[, !(names(timeFormData) %in% "workByName")]
    
    # Write table to database
    dbWriteTable(BDSHProjects, "effort", timeFormData, append = TRUE)
    
    # clear data.frame after added to database
    timeFormData <<- timeFormData[c(), ]
    
    # render the now blank data.frame to be displayed in the UI
    output$timeFormData <- DT::renderDataTable({
      input$submitAddTime
      loadTimeFormData()})
  }
)