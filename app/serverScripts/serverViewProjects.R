# Reactive to filter projects data based on viewProjectsByStatus and
# viewProjectsByEmployee
filterViewProjects <- 
  reactive({
    test <- employees[employees$employeeName == input$viewProjectsByEmployee, "employeeUteid"]
    
    filtered <- reactiveData$projects %>% 
      {if (input$viewProjectsByStatus != "All") {
        filter(., projectStatus == input$viewProjectsByStatus)
      }
        else {.}
      } %>% 
      {if (input$viewProjectsByEmployee != "All") {
        filter(., 
               bdshLead == test | 
                 bdshSecondary == test)
      } 
        else {.}}
    return(filtered)
  })

# Create datatable output
output$viewProjects <-
  renderDataTable({
    datatable(
      filterViewProjects(),
      rownames = FALSE
    )
  })