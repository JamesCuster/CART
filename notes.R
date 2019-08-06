
# Attempt to make general observe event for edit/delete buttons -----------

observeEvent(
  input$deletePressed, {
    # Parse the delete event to determine the data.frame delete was clicked
    # and which row
    x <- strsplit(input$deletePressed, "_")
    x <<- 
      list(
        df = x[[1]][1],
        row = as.integer(x[[1]][2])
      )
    
    # save the data.frame that had the delete event to df, remove the
    # deleted row, and reset row.names()
    # eval(parse(text = paste0("df <- ", x$df)))
    # df <- df[-x$row, ]
    # row.names(df) <- NULL
    # df <<- df
    
    # maked the updates to the correct data.frame and display datatable
    if (x$df == "projectFormData") {
      projectFormData <- projectFormData[-x$row, ]
      row.names(projectFormData) <- NULL
      projectFormData <<- projectFormData
      
      output$projectFormResponses <- 
        renderDataTable({
          loadprojectFormData()
        })
    }
    else if (x$df == "timeFormData") {
      timeFormData <- timeFormData[-x$row, ]
      row.names(timeFormData) <- NULL
      timeFormData <<- timeFormData
      
      output$timeFormResponses <- 
        renderDataTable({
          loadtimeFormData()
        })
    }
    else if (x$df == "researcherFormData") {
      researcherFormData <- researcherFormData[-x$row, ]
      row.names(researcherFormData) <- NULL
      researcherFormData <<- researcherFormData
      
      output$researcherFormDataResponses <-
        renderDataTable({
          loadResearcherFormData()
        })
    }
    else if (x$df == "employeeFormData") {
      employeeFormData <- employeeFormData[-x$row, ]
      row.names(employeeFormData) <- NULL
      employeeFormData <<- employeeFormData
      
      output$employeeFormResponses <- 
        renderDataTable({
          loadEmployeeFormData()
        })
    }
    
    
    
  }
)




# playing with viewProjects datatable possibilites
rmv <- c("projectID",        "bdshLead",          "bdshSecondary", 
         "projectPI",        "projectSupport1",   "projectSupport2",
         "projectSupport3",  "projectSupport4")



tableView <- viewProjects[, c()]