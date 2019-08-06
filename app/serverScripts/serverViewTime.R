# This query request the database to get the effort table and join with projects
# and employees
viewTimeQuery <- 
  "select ef.effortID,
       ef.timeProjectID,
       p.projectName,
       ef.workBy,
       em.employeeName,
       em.employeeEmail,
       ef.dateOfWork,
       ef.dateOfEntry,
       ef.workTime,
       ef.workTimeCategory,
       ef.workCategory,
       ef.workDescription
from effort ef
left join projects p on ef.timeProjectID = p.projectID
left join employees em on ef.workBy = em.bdshID"


# Reactive to filter projects data based on viewTimeByProject,
# viewTimeByEmployee, and viewTimeByDate
filterViewTime <- 
  reactive({
#    browser()
    #employeeUteid <- employees[employees$employeeName == input$viewTimeByEmployee, "employeeUteid"]
    
    filtered <- viewEffort %>% 
      {if (input$viewTimeByProject != "All") {
        filter(., timeProjectID == input$viewTimeByProject)
      }
        else {.}
      } %>% 
      {if (input$viewTimeByEmployee != "All") {
        filter(., workBy == input$viewTimeByEmployee)
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


observeEvent(
  updateOnLoad$viewTime == TRUE, {
    # Code to query database should go here #############################################################
    viewTimeQuery <- dbSendQuery(BDSHProjects, viewTimeQuery)
    viewTime <- dbFetch(viewTimeQuery)
    dbClearResult(viewTimeQuery)
    viewTime <<- viewTime
    
    # Create datatable output
    output$viewTime <-
      renderDataTable({
        datatable(
          filterViewTime(),
          rownames = FALSE
        )
      })
    
    updateOnLoad$viewTime <- FALSE
  }
)
