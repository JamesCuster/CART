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
    
    return(filtered)
  })

# # variables we don't want displayed in the app
# rmv <- c("projectID",        "bdshLead",          "bdshSecondary", 
#          "projectPI",        "projectSupport1",   "projectSupport2",
#          "projectSupport3",  "projectSupport4")
# 
# # Remove columns not needed for displaying (all the ID columns)
# filtered <<- filtered[, !(names(filtered) %in% rmv)]
# 



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
        addViewDetails(filterViewProjects(), "viewProjects")
      })
    
    updateOnLoad$viewProjects <- FALSE
  }
)



# Function to create view details action button
addViewDetails <- function(df, idPrefix) {
  # function to create view details link to be used with lapply
  detailsLink <- function(projectID) {
    # create the ID that will be associated with the input
    detsID <- paste0(idPrefix, "Details")
    
    as.character(
      actionLink(
        inputId = paste(idPrefix, projectID, sep = "_"),
        label = "View Details",
        onclick = 
          paste0(
            'Shiny.setInputValue(\"',
            detsID,
            '\", this.id, {priority: "event"})'
          )
      )
    )
  }
  
  # Variables that are shown in the datatable
  viewProjectsDisplay <- c("projectName",
                           "bdshLeadName",
                           "projectPIName",
                           "projectStatus",
                           "projectDueDate"
                           )
  
  # Create datatable with given dataframe and the function above
  datatable(
    cbind(
      df[, viewProjectsDisplay],
      `View Details` = sapply(df[, "projectID"], detailsLink)
    ),
#    rownames = FALSE,
    escape = FALSE
  )
}


# Controls what happens when one of the view details buttons is pressed
observeEvent(
  input$viewProjectsDetails, {
    # Identify the row to display details on
    rowID <- parseDeleteEvent(input$viewProjectsDetails)

    # display the modal
    showModal(
      modalDialog(
        modalText(viewProjects[viewProjects$projectID == rowID, ])
      )
    )
  }
)


modalText <- function(x) {
  div(
    h1(x$projectName),
    
    # column content div
    div(
      # first column div
      div(
        # BDSH Lead
        div("BDSH Lead", class = "modalVariableNames"),
        div(x$bdshLeadName, class = "modalVariableContent"),
        
        # Project PI
        div("Project Primary Investigator", class = "modalVariableNames"),
        div(x$projectPIName, class = "modalVariableContent"),
        
        # PI Primary Department
        div("PI Primary Department", class = "modalVariableNames"),
        div(x$projectPIPrimaryDept, class = "modalVariableContent"),
        
        # Support Staff1
        div("Support Staff 1", class = "modalVariableNames"),
        div(x$projectSupport1Name, class = "modalVariableContent"),
        
        # Support Staff2
        div("Support Staff 2", class = "modalVariableNames"),
        div(x$projectSupport2Name, class = "modalVariableContent"),
        
        # Support Staff3
        div("Support Staff 3", class = "modalVariableNames"),
        div(x$projectSupport3Name, class = "modalVariableContent"),
        
        # Support Staff4
        div("Support Staff 4", class = "modalVariableNames"),
        div(x$projectSupport4Name, class = "modalVariableContent")
      ),
      
      # second column div
      div(
        # BDSH secondary
        div("BDSH Secondary", class = "modalVariableNames"),
        div(x$bdshSecondaryName, class = "modalVariableContent"),
        
        # PI Email
        div("PI Email", class = "modalVariableNames"),
        div(x$projectPIEmail, class = "modalVariableContent"),
        
        # PI Secondary Department
        div("PI Secondary Department", class = "modalVariableNames"),
        div(x$projectPISecondaryDept, class = "modalVariableContent"),
        
        # Support Staff Email 1
        div("Support Staff 1 Email", class = "modalVariableNames"),
        div(x$projectSupport1Email, class = "modalVariableContent"),
        
        # Support Staff Email 2
        div("Support Staff 2 Email", class = "modalVariableNames"),
        div(x$projectSupport2Email, class = "modalVariableContent"),
        
        # Support Staff Email 3
        div("Support Staff 3 Email", class = "modalVariableNames"),
        div(x$projectSupport3Email, class = "modalVariableContent"),
        
        # Support Staff Email 4
        div("Support Staff 4 Email", class = "modalVariableNames"),
        div(x$projectSupport4Email, class = "modalVariableContent"),
        style = "margin-left: 15%"
      ),
      style = "display: flex; align-items: flex-start;"
    ),
    
    # Description div
    div("Project Description", class = "modalVariableNames"),
    div(x$projectDescription, class = "modalVariableContent"),
    
    # Project Status
    div("Project Status", class = "modalVariableNames"),
    div(x$projectStatus, class = "modalVariableContent"),
    
    # Project Due Date
    div("Project Due Date", class = "modalVariableNames"),
    div(x$projectDueDate, class = "modalVariableContent")
  )
}