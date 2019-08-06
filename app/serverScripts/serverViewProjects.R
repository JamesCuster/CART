# This query request the database to get the projects table and join with employees and reasearchers
viewProjectsQuery <- 
  "select  p.projectID, 
            p.projectName, 
            p.bdshLead,
            e1.employeeName as bdshLeadName, 
            e1.employeeEmail as bdshLeadEmail, 
            p.bdshSecondary, 
            e2.employeeName as bdshSecondaryName, 
            e2.employeeEmail as bdshSecondaryEmail,
            p.projectPI,
            r1.researcherName as projectPIName,
            r1.researcherEmail as projectPIEmail,
            r1.primaryDept as projectPIPrimaryDept,
            r1.secondaryDept as projectPISecondaryDept,
            p.projectSupport1,
            r2.researcherName as projectSupport1Name,
            r2.researcherEmail as projectSupport1Email,
            p.projectSupport2,
            r3.researcherName as projectSupport2Name,
            r3.researcherEmail as projectSupport2Email,
            p.projectSupport3,
            r4.researcherName as projectSupport3Name,
            r4.researcherEmail as projectSupport3Email,
            p.projectSupport4,
            r5.researcherName as projectSupport4Name,
            r5.researcherEmail as projectSupport4Email,
            p.projectDescription,
            p.projectStatus,
            p.projectDueDate
        from projects p
    left join employees e1 on p.bdshLead = e1.bdshID
    left join employees e2 on p.bdshSecondary = e2.bdshID
    left join researchers r1 on p.projectPI = r1.researcherID
    left join researchers r2 on p.projectSupport1 = r2.researcherID
    left join researchers r3 on p.projectSupport2 = r3.researcherID
    left join researchers r4 on p.projectSupport3 = r4.researcherID
    left join researchers r5 on p.projectSupport4 = r5.researcherID"


# Reactive to filter projects data based on viewProjectsByStatus and
# viewProjectsByEmployee
filterViewProjects <- 
  reactive({
    # employeeUteid <- employees[employees$employeeName == input$viewProjectsByEmployee, "employeeUteid"]
    # researcherUteid <- researchers[researchers$researcherName == input$viewProjectsByResearcher, "researcherUteid"]
    
    filtered <- viewProjects %>% 
      # Status filter
      {if (input$viewProjectsByStatus != "All") {
        filter(., projectStatus == input$viewProjectsByStatus)
      }
        else {.}
      } %>% 
      # Employee filter
      {if (input$viewProjectsByEmployee != "All") {
        filter(., 
               bdshLead == input$viewProjectsByEmployee | 
                 bdshSecondary == input$viewProjectsByEmployee)
      } 
        else {.}
      } %>% 
      # Researcher filter
      {if (input$viewProjectsByResearcher != "All") {
        filter(., projectPI == input$viewProjectsByResearcher |
                 projectSupport1 == input$viewProjectsByResearcher |
                 projectSupport2 == input$viewProjectsByResearcher |
                 projectSupport3 == input$viewProjectsByResearcher |
                 projectSupport4 == input$viewProjectsByResearcher)
      }
        else {.}}
    
    # variables we don't want displayed in the app
    rmv <- c("projectID",        "bdshLead",          "bdshSecondary", 
                "projectPI",        "projectSupport1",   "projectSupport2",
                "projectSupport3",  "projectSupport4")
    
    # Remove columns not needed for displaying (all the ID columns)
    filtered <- filtered[, !(names(filtered) %in% rmv)]
    return(filtered)
  })


# when new data is loaded update the projects view data from database
observeEvent(
  updateOnLoad$viewProjects == TRUE, {
    viewProjectsQuery <- dbSendQuery(BDSHProjects, viewProjectsQuery)
    viewProjects <- dbFetch(viewProjectsQuery)
    dbClearResult(viewProjectsQuery)
    viewProjects <<- viewProjects
    
    
    # Create datatable output
    output$viewProjects <-
      renderDataTable({
        datatable(
          filterViewProjects(),
          rownames = FALSE
        )
      })
    
    updateOnLoad$viewProjects <- FALSE
  }
)

