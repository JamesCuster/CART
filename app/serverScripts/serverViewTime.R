
# 1 Helper Functions and Objects --------------------------------------------

# 1.1 Database Query ------------------------------------------------------
# This query request the database to get the time table and join with projects
# and employees
viewTimeQuery <- 
  "select t.timeID,
       t.timeProjectID,
       p.projectName,
       t.workBy,
       e.employeeName,
       e.employeeEmail,
       t.dateOfWork,
       t.dateOfEntry,
       t.workTime,
       t.workTimeCategory,
       t.workCategory,
       t.workDescription
from time t
left join projects p on t.timeProjectID = p.projectID
left join employees e on t.workBy = e.bdshID"


# 1.2 Vector of Variables to Display in Datatable ---------------------------
viewTimeDisplay <- c("projectName",
                     "employeeName",
                     "employeeEmail",
                     "dateOfWork",
                     "dateOfEntry",
                     "workTime",
                     "workTimeCategory",
                     "workCategory",
                     "workDescription")



# 2 Reactives -------------------------------------------------------------

# filterViewTime Reactive -------------------------------------------------
# Reactive to filter projects data based on viewTimeByProject,
# viewTimeByEmployee, and viewTimeByDate
filterViewTime <- 
  reactive({
filtered <- viewTables$time %>% 
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



# 3 Observers -------------------------------------------------------------

# 3.1 Fetch View Time Data --------------------------------------------
# This observer fetches the data for the viewTables$time reactive using the
# SQL query above whenever new time data is loaded from the database
observeEvent(
  reactiveData$time, {
    viewTimeQuery <- dbSendQuery(BDSHProjects, viewTimeQuery)
    viewTables$time <- dbFetch(viewTimeQuery)
    dbClearResult(viewTimeQuery)
  }
)



# 4 Output ----------------------------------------------------------------

# Create datatable output
output$viewTime <- 
  renderDataTable({
    datatable(
      filterViewTime()[, viewTimeDisplay],
      rownames = FALSE
    )
  })