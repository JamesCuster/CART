# Reactive to filter projects data based on viewProjectsByStatus and
# viewProjectsByEmployee
filterViewProjects <- 
  reactive({
    employeeUteid <- employees[employees$employeeName == input$viewProjectsByEmployee, "employeeUteid"]
    researcherUteid <- researchers[researchers$researcherName == input$viewProjectsByResearcher, "researcherUteid"]
    
    filtered <- reactiveData$projects %>% 
      # Status filter
      {if (input$viewProjectsByStatus != "All") {
        filter(., projectStatus == input$viewProjectsByStatus)
      }
        else {.}
      } %>% 
      # Employee filter
      {if (input$viewProjectsByEmployee != "All") {
        filter(., 
               bdshLead == employeeUteid | 
                 bdshSecondary == employeeUteid)
      } 
        else {.}
      } %>% 
      # Researcher filter
      {if (input$viewProjectsByResearcher != "All") {
        filter(., projectPI == researcherUteid |
                 projectSupport1 == researcherUteid |
                 projectSupport2 == researcherUteid |
                 projectSupport3 == researcherUteid |
                 projectSupport4 == researcherUteid)
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