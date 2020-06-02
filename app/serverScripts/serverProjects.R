
# 1 UI Components ---------------------------------------------------------

# controls the edit buttons being grayed out
observe({
  if (is.null(input[["projects_rows_selected"]]) || input[["projects_rows_selected"]] == "") {
    disable("editProject")
  }
  else {
    enable("editProject")
  }
})



# 1.1 Project Filters -----------------------------------------------------

# Updates the project filter choices 
observeEvent(reactiveData, {
  choices <- choicesProjects()
  updateSelectizeInput(
    session,
    inputId = "viewProjectsByStatus",
    choices = choices[["viewProjectsByStatus"]],
    selected = input[["viewProjectsByStatus"]]
  )
  
  updateSelectizeInput(
    session,
    inputId = "viewProjectsByEmployee",
    label = "BDSH Staff",
    choices = choices[["viewProjectsByEmployee"]],
    selected = input[["viewProjectsByEmployee"]]
  )
  
  updateSelectizeInput(
    session,
    inputId = "viewProjectsByResearcher",
    label = "Researcher",
    choices = choices[["viewProjectsByResearcher"]],
    selected = input[["viewProjectsByResearcher"]]
  )
})



# 1.2 Projects Datatable --------------------------------------------------
output$projects <- renderDataTable(
  datatable(
    filterViewProjects()[, viewProjectsDisplay],
    selection = list(
      mode = 'single',
      selected = projectRowSelected
    ), 
    rownames = FALSE,
    escape = FALSE,
    options = list(
      dom = '<"top"fl> t <"bottom"ip>',
      order = list(1, 'desc')
    )
  ),
  server=TRUE
)



# 2 Manipulate Project Data -----------------------------------------------

# 2.1 Helper Objects And Functions ----------------------------------------

# this data.frame stores information about what inputs are used for projects
projectInputs <-
  data.frame(
    ids = c("projectID",
            "projectName",
            "bdshLead",
            "bdshSecondary",
            "projectPI",
            "projectSupport1",
            "projectSupport2",
            "projectSupport3",
            "projectSupport4",
            "projectDescription",
            "projectFunded",
            "projectStatus",
            "projectStatusComment",
            "projectDueDate",
            "educationProject"),
    labels = c("projectID",
               "Project Name",
               "BDSH Lead",
               "BDSH Secondary",
               "Primary Investigator",
               "Support Staff 1",
               "Support Staff 2",
               "Support Staff 3",
               "Support Staff 4",
               "Brief Description",
               "Project Funded",
               "Project Status",
               "Project Status Comment",
               "Due Date",
               "Is this a resident, fellow, or student project?"),
    type = c("skip",
             "textInput",
             "selectizeInput",
             "selectizeInput",
             "selectizeInput",
             "selectizeInput",
             "selectizeInput",
             "selectizeInput",
             "selectizeInput",
             "textAreaInput",
             "selectizeInput",
             "selectInput",
             "textAreaInput",
             "dateInput",
             "selectInput"),
    stringsAsFactors = FALSE
  )


# This reactive creates the object which stores the choices for the selection
# inputs
choicesProjects <- reactive({
  x <- list()
  
  # Project inputs
  x[["bdshLead"]] <- valueLabel(reactiveData$employees, "bdshID", "employeeName")
  x[["bdshSecondary"]] <- valueLabel(reactiveData$employees, "bdshID", "employeeName")
  x[["projectPI"]] <- valueLabel(reactiveData$researchers, "researcherID", "researcherName")
  x[["projectSupport1"]] <- valueLabel(reactiveData$researchers, "researcherID", "researcherName")
  x[["projectSupport2"]] <- valueLabel(reactiveData$researchers, "researcherID", "researcherName")
  x[["projectSupport3"]] <- valueLabel(reactiveData$researchers, "researcherID", "researcherName")
  x[["projectSupport4"]] <- valueLabel(reactiveData$researchers, "researcherID", "researcherName")
  x[["projectFunded"]] <- c("Yes", "No")
  x[["projectStatus"]] <- list("Active", 
                               Closed = paste0("Closed - ", 
                                               c("Funding Declined", "Manuscript Accepted",
                                                 "Analysis Completed", "Loss to Follow-up")), 
                               Dormant = paste0("Dormant - ", 
                                                c("Grant Submitted", "Manuscript Submitted", 
                                                  "Analysis Completed", "Loss to Follow-up")))
  x[["educationProject"]] <- c("No", "Resident or Fellow", "Student")
  
  # Project Filter Input choices (Inputs Created in Section 1)
  x[["viewProjectsByStatus"]] <- c(All = "All", x[["projectStatus"]])
  x[["viewProjectsByEmployee"]] <- c(All = "All", valueLabel(reactiveData$employees, "bdshID", "employeeName"))
  x[["viewProjectsByResearcher"]] <- c(All = "All", valueLabel(reactiveData$researchers, "researcherID", "researcherName"))
  x
})




# 2.2 Manipulate Project Data ---------------------------------------------

# 2.2.1 Add Project -------------------------------------------------------
observeEvent(
  input$addProject, {
    choices <- choicesProjects()
    fields <- 
      modalInputs(
        projectInputs$ids, 
        projectInputs$labels, 
        projectInputs$type,
        choices = choices
      )
    
    showModal(
      modalDialog(
        title = "Add Project",
        # *************************************************************************************************
        radioButtons(
          inputId =  "fiscalYear19", 
          label = "Was The Project Initiated in FY 2019?", 
          choices = c("Yes", "No"),
          selected = "No",
          inline = TRUE
        ),
        tags$hr(),
        # *************************************************************************************************
        fields,
        
        footer = 
          div(
            modalButton("Cancel"),
            actionButton("insertProject", "Save")
          )
      )
    )
  })


# *************************************************************************************************
observeEvent(input$fiscalYear19, {
  if (input$fiscalYear19 == "Yes") {
    session$sendCustomMessage(
      "projectID", 
      max(
        reactiveData$projects[reactiveData$projects$projectID < 20000, "projectID"]
      ) + 1)
  }
  else {
    return()
  }
})
# *************************************************************************************************

observeEvent(
  input$insertProject, {
    insertCallback(projectInputs$ids, "projects")
    removeModal()
  }
)


# 2.2.2 Edit Project ------------------------------------------------------
# this object is used to preserve the row selected. It is assinged once a row is
# selected and the edit button is pressed. It is used in the renderDataTable
# call
projectRowSelected <- NULL

observeEvent(
  input$editProject, {
    projectRowSelected <<- input[["projects_rows_selected"]]
    choices <- choicesProjects()
    row <- input[["projects_rows_selected"]]
    rowID <- filterViewProjects()[row, "projectID"]
    if(!is.null(row)) {
      if (row > 0) {
        fields <- 
          modalInputs(
            projectInputs$ids, 
            projectInputs$labels, 
            projectInputs$type,
            reactiveData$projects[reactiveData$projects$projectID == rowID, ],
            choices = choices
          )
        # Add extra text to projectFunded input 
        fields$projectFunded$children <- 
          list(fields$projectFunded$children,
               div("If this project was unfunded and became funded, do not 
                   change this field to funded as this would change all unfunded 
                   time entered to funded time. If you need to track funded time 
                   for this project, please create a new project entry in CART. 
                   If you just need to indicate that the project became funded, 
                   please do so in the Project Status below.",
                   style = "margin-top: -15px;"))
        
        showModal(
          modalDialog(
            title = "Edit Project",
            fields,
            footer = 
              div(
                modalButton("Cancel"),
                actionButton("updateProject", "Save")
              )
          )
        )
      }
    }
  }
)

observeEvent(
  input$updateProject, {
    row <- input[["projects_rows_selected"]]
    rowID <- filterViewProjects()[row, "projectID"]
    updateCallback(
      projectInputs$ids,
      rowID, 
      "projectID",
      "projects")
    removeModal()
  }
)



# 3 Get Project Data ------------------------------------------------------

# 3.1 Database Query ------------------------------------------------------
# This query request the database to get the projects table and join with
# employees and reasearchers
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
            p.projectDueDate,
            p.educationProject
        from projects p
    left join employees e1 on p.bdshLead = e1.bdshID
    left join employees e2 on p.bdshSecondary = e2.bdshID
    left join researchers r1 on p.projectPI = r1.researcherID
    left join researchers r2 on p.projectSupport1 = r2.researcherID
    left join researchers r3 on p.projectSupport2 = r3.researcherID
    left join researchers r4 on p.projectSupport3 = r4.researcherID
    left join researchers r5 on p.projectSupport4 = r5.researcherID"


# 3.2 Fetch View Projects Data --------------------------------------------
# This observer fetches the data for the reactiveData$viewProjects reactive
# using the SQL query above whenever new project data is loaded from the
# database
observeEvent(
  reactiveData$projects, {
    viewProjectsQuery <- dbSendQuery(BDSHProjects, viewProjectsQuery)
    reactiveData$viewProjects <- dbFetch(viewProjectsQuery)
    dbClearResult(viewProjectsQuery)
  }
)



# 4 View Project Data -----------------------------------------------------

# 4.1 Helper Objects And Functions ----------------------------------------

# 4.1.1 Variables To Display in Datatable ---------------------------------
# This vector is a subset of variables in ReactiveData$viewProjects which are
# viewable in the datatable output
viewProjectsDisplay <- c("View Details",
                         "projectID",
                         "projectName",
                         "bdshLeadName",
                         "bdshSecondaryName",
                         "projectPIName",
                         "projectStatus",
                         "projectDueDate")


# 4.1.2 Add View Details Link ---------------------------------------------
# This function is used to create the View Details Link in the datatable which
# when clicked will display a modal with more details about the project
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
  
  df$`View Details` <- sapply(df[, "projectID"], detailsLink)
  return(df)
}


# 4.1.3 Modal Function --------------------------------------------------------
# This function creates the HTML for a modal when View Details is clicked on a
# row in the datatable output
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
        if (!is.na(x$projectSupport1Name)) {
          list(
            div("Support Staff 1", class = "modalVariableNames"),
            div(x$projectSupport1Name, class = "modalVariableContent")
          )
        },
        
        # Support Staff2
        if (!is.na(x$projectSupport2Name)) {
          list(
            div("Support Staff 2", class = "modalVariableNames"),
            div(x$projectSupport2Name, class = "modalVariableContent")
          )
        },
        
        # Support Staff3
        if (!is.na(x$projectSupport3Name)) {
          list(
            div("Support Staff 3", class = "modalVariableNames"),
            div(x$projectSupport3Name, class = "modalVariableContent")
          )
        },
        
        # Support Staff4
        if (!is.na(x$projectSupport4Name)) {
          list(
            div("Support Staff 4", class = "modalVariableNames"),
            div(x$projectSupport4Name, class = "modalVariableContent")
          )
        },
        
        # Education project
        div("Student/Trainee Education Project", class = "modalVariableNames"),
        div(x$educationProject, class = "modalVariableContent"),
        
        # Project Status
        div("Project Status", class = "modalVariableNames"),
        div(x$projectStatus, class = "modalVariableContent"),
        
        # Project Status Comment
        div("Project Status Comment", class = "modalVariableNames"),
        div(x$projectStatusComment, class = "modalVariableContent"),
        
        # Project Due Date
        div("Project Due Date", class = "modalVariableNames"),
        div(x$projectDueDate, class = "modalVariableContent")
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
        if (!is.na(x$projectSupport1Email)) {
          list(
            div("Support Staff 1 Email", class = "modalVariableNames"),
            div(x$projectSupport1Email, class = "modalVariableContent")
          )
        },
        
        # Support Staff Email 2
        if (!is.na(x$projectSupport2Email)) {
          list(
            div("Support Staff 2 Email", class = "modalVariableNames"),
            div(x$projectSupport2Email, class = "modalVariableContent")
          )
        },
        
        # Support Staff Email 3
        if (!is.na(x$projectSupport3Email)) {
          list(
            div("Support Staff 3 Email", class = "modalVariableNames"),
            div(x$projectSupport3Email, class = "modalVariableContent")
          )
        },
        
        # Support Staff Email 4
        if (!is.na(x$projectSupport4Email)) {
          list(
            div("Support Staff 4 Email", class = "modalVariableNames"),
            div(x$projectSupport4Email, class = "modalVariableContent")
          )
        },
        
        style = "margin-left: 15%"
      ),
      style = "display: flex; align-items: flex-start;"
    ),
    
    # Description div
    div("Project Description", class = "modalVariableNames"),
    div(x$projectDescription, class = "modalVariableContent")
  )
}



# 4.2 View Project Reactions ----------------------------------------------

# 4.2.1 View Details Link -------------------------------------------------
# Controls what happens when one of the view details buttons in the datatable
# output is pressed
observeEvent(
  input$viewProjectsDetails, {
    # Identify the row to display details on
    rowID <- parseDeleteEvent(input$viewProjectsDetails)
    
    # display the modal
    showModal(
      modalDialog(
        modalText(
          reactiveData$viewProjects[reactiveData$viewProjects$projectID == rowID, ])
      )
    )
  }
)


# 4.2.2 Filter Projects Reactive ------------------------------------------
# Reactive to filter projects data based on viewProjectsByStatus,
# viewProjectsByEmployee, and viewProjectsByResearcher
filterViewProjects <-
  reactive({
    # If reactiveData$viewProjects has not been created yet, this allows the
    # reactive to be skipped
    if (is.null(reactiveData$viewProjects)) {
      return()
    }
    if (!(is.null(input$viewProjectsByStatus) ||
          is.null(input$viewProjectsByEmployee) ||
          is.null(input$viewProjectsByResearcher))) {
      
      filtered <- reactiveData$viewProjects %>%
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
      
      # add View Details link
      filtered <- addViewDetails(filtered, "viewProjects")
      return(filtered)
      }
    else {
      # add View Details link
      filtered <- addViewDetails(reactiveData$viewProjects, "viewProjects")
      return(filtered)
    }
  })



# 5 Download Projects -----------------------------------------------------

# 5.1 Download Projects Modal ---------------------------------------------
observeEvent(
  input$downloadProjectData, {
    showModal(
      modalDialog(
        title = "Download Project Data",
        
        radioButtons(
          "projectsDownloadSelection",
          "Select The Project Data You Want",
          c("Complete Data", "Filtered Data"),
          selected = "Complete Data"
        ),
        
        footer = 
          div(
            modalButton("Cancel"),
            downloadButton("downloadProjects", "Download Projects")
          )
      )
    )
  }
)


# 5.2 Collect Projects Download Data --------------------------------------
getDownloadProjectData <- reactive({
    if (input$projectsDownloadSelection == "Filtered Data") {
      df <- filterViewProjects()
    }
    else {
      df <- reactiveData$viewProjects
    }
    df
  }
)


# 5.3 Projects Download Handler -------------------------------------------
output$downloadProjects <- downloadHandler(
  filename = function() {
    paste("projects_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(getDownloadProjectData(),
              file,
              row.names = FALSE)
  }
)