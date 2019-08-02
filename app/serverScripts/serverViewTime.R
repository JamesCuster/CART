# Reactive to filter projects data based on viewTimeByProject,
# viewTimeByEmployee, and viewTimeByDate
filterViewTime <- 
  reactive({
#    browser()
    employeeUteid <- employees[employees$employeeName == input$viewTimeByEmployee, "employeeUteid"]
    
    filtered <- reactiveData$effort %>% 
      {if (input$viewTimeByProject != "All") {
        filter(., timeProjectID == input$viewTimeByProject)
      }
        else {.}
      } %>% 
      {if (input$viewTimeByEmployee != "All") {
        filter(., workBy == employeeUteid)
      } 
        else {.}
      } %>% 
      {if (!is.na(input$viewTimeByDate[1])) {
        filter(., as.Date(dateOfWork) >= input$viewTimeByDate[1])
      }
        else {.}
      } %>% 
      {if (!is.na(input$viewTimeByDate[2])) {
        filter(., as.Date(dateOfWork) <= input$viewTimeByDate[2])
      }
        else {.}
      }
    return(filtered)
  })

# Create datatable output
output$viewTime <-
  renderDataTable({
    datatable(
      filterViewTime(),
      rownames = FALSE
    )
  })
