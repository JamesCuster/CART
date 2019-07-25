# Add Reactives for add Researcher ----------------------------------------
cleanResearcherFormData <- reactive({
  researcherFormResponse <- 
    sapply(
      addResearcherFields,
      function(x) {
        if (length(input[[x]]) == 0 || x == "effortID" || input[[x]] == ''|| is.na(input[[x]])) {
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


