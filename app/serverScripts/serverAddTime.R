# Reactives for add time --------------------------------------------------
cleanTimeFormData <-
  reactive({
    timeFormResponse <- sapply(addTimeFields, function(x) {
      if (grepl("date", x, ignore.case = TRUE)) {
        as.character(input[[x]])
      } 
      else if (grepl("workBy", x)) {
        people[people$name == input[[x]], "uteid", drop = TRUE]
      } 
      else {
        input[[x]]
      }
    })
    timeFormResponse
  })

# This is what controls what happens when the submit button on the add time
# tab is pressed
observeEvent(
  input$submitAddTime, {
    # creates and displays table of inputs
    saveTimeFormData(cleanTimeFormData())
    
    # Clears data from the forms
    sapply(addTimeFields, function(x) {
      updateTextInput(session, x, value = "")
      session$sendCustomMessage(type = "resetValue", message = x)
    })
    
    # creates button to submit data to database once a form is submitted
    output$timeToDatabase <- renderUI({
      actionButton("timeToDatabase", "Add data above to the database")
    })
  }
)

output$timeFormResponses <- DT::renderDataTable({
  input$submitAddTime
  loadTimeFormData()})

observeEvent(
  input$timeToDatabase, {
    dbWriteTable(BDSHProjects, "effort", timeFormData, append = TRUE)
    timeFormData <<- timeFormData[c(), ]
    
    output$timeFormResponses <- DT::renderDataTable({
      input$submitAddTime
      loadTimeFormData()})
    
    # reload database
    #loadDatabase()
    
  }
)