
# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {

# Database functionalities ------------------------------------------------

    # Connect to database
    BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")
    
    # Load all database tables
    loadDatabase()
    
# Reactive value that gets triggered when new data is loaded from the database
    updateOnLoad <- reactiveValues(
      dropdown = FALSE,
      viewProjects = FALSE,
      viewTime = FALSE)
    
# monitor database for changes and reload changed tables
    monitorDatabase <- 
      reactivePoll(
        intervalMillis = 1000,
        session,
        checkFunc = function() {
          modifiedCurrent <- tbl(BDSHProjects, "modified") %>% 
            collect() %>% 
            as.data.frame(stringsAsfactors = FALSE)
          if (as.POSIXct(modified$modified) < as.POSIXct(modifiedCurrent$modified)) {
            modified <<- modifiedCurrent
            return(TRUE)
          } else {
            return(FALSE)
          }
        },
        valueFunc = function() {
          loadDatabase(tables = modified$tableName)
          updateOnLoad$dropdown <- TRUE
          updateOnLoad$viewProjects <- TRUE
          updateOnLoad$viewTime <- TRUE
        }
      )
    
    # observe which applies the monitorDatabase reactives
    observe({
      monitorDatabase()
    })
    
    
    
# inputId's for inputs which need updating as the database gets modified
    
    # Need updating when new employees data is fetched
    employeesDependentValues <- 
      c(# Update selection inputs in the Add Project form
        "bdshLead",
        "bdshSecondary",
        # Update selection inputs in the Add Time form
        "workBy",
        # Update selection inputs in View Projects
        "viewProjectsByEmployee",
        "viewTimeByEmployee"
      )
    
    # Need updating when new projects data is fetched
    projectsDependentValues <- 
      c(# update selection inputs in the add time form
        "timeProjectID",
        "viewTimeByProject"
      )
    
    # Need updating when new researchers data is fetched
    researchersDependentValues <- 
      c(# update selection inputs in the add project form
        "projectPI",
        "projectSupport1",
        "projectSupport2",
        "projectSupport3",
        "projectSupport4",
        "viewProjectsByResearcher"
      )
    
    
# reactiveValues which will preserve a users inputs even if new data is loaded
# into the database
    dropdownMenuSelections <- reactiveValues()
    sapply(c(employeesDependentValues, projectsDependentValues, researchersDependentValues),
           function(x) {
             observeEvent(input[[x]], {
               # browser()
               if (x %in% c("viewProjectsByEmployee", "viewProjectsByResearcher", "viewTimeByProject", "viewTimeByEmployee") && input[[x]] == "") {
                 dropdownMenuSelections[[x]] <- "All"
               } else {
                 dropdownMenuSelections[[x]] <- input[[x]]
               }
             })
           })
    
    
    
# Reactives that trigger after new data is loaded from the database that update
# the necessary input dropdown menus to reflect any changes in the database
    updateSelectDropdownMenus <- 
      reactive({
        
      # When new employee data is fetched from database
          # Update selection inputs in the Add Project form
          updateSelectizeInput(
            session,
            inputId = "bdshLead",
            choices = reactiveData$employees[order(employees$employeeName), ],
            selected = dropdownMenuSelections[["bdshLead"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "bdshSecondary",
            choices = reactiveData$employees[order(employees$employeeName), ],
            selected = dropdownMenuSelections[["bdshSecondary"]],
            server = TRUE
          )
          
          # Update selection inputs in the Add Time form
          updateSelectizeInput(
            session,
            inputId = "workBy",
            choices = reactiveData$employees[order(employees$employeeName), ],
            selected = dropdownMenuSelections[["workBy"]],
            server = TRUE
          )
          
          # Update selection inputs in View Projects
          updateSelectizeInput(
            session,
            inputId = "viewProjectsByEmployee",
            choices = rbind(
              data.frame(bdshID = NA,
                         employeeUteid = NA,    # This is done in order to provide the "All" option
                         employeeName = NA,
                         employeeEmail = NA,
                         degree = NA,
                         role = NA,
                         value = "All",
                         label = "All",
                         stringsAsFactors = FALSE),
              employees[order(employees$employeeName), ]),
            selected = dropdownMenuSelections[["viewProjectsByEmployee"]],
            server = TRUE
            )
          
          
          # Update selection inputs in View Time
          updateSelectizeInput(
            session,
            inputId = "viewTimeByEmployee",
            choices = rbind(
              data.frame(bdshID = NA,
                         employeeUteid = NA,    # This is done in order to provide the "All" option
                         employeeName = NA,
                         employeeEmail = NA,
                         degree = NA,
                         role = NA,
                         value = "All",
                         label = "All",
                         stringsAsFactors = FALSE),
              employees[order(employees$employeeName), ]),
            selected = dropdownMenuSelections[["viewTimeByEmployee"]],
            server = TRUE
          )
          
        
      # When new project data is fetched from database
          # update selection inputs in the add time form
          updateSelectizeInput(
            session,
            inputId = "timeProjectID",
            choices = reactiveData$projects[order(projects$projectName), ],
            selected = dropdownMenuSelections[["timeProjectID"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "viewTimeByProject",
            choices = rbind(
              data.frame(projectID = NA,
                         projectName = NA,    # This is done in order to provide the "All" option
                         bdshLead = NA,
                         bdshSecondary = NA,
                         projectPI = NA,
                         projectSupport1 = NA,
                         projectSupport2 = NA,
                         projectSupport3 = NA,
                         projectSupport4 = NA,
                         projectDescription = NA,
                         projectStatus = NA,
                         projectDueDate = NA,
                         value = "All",
                         label = "All",
                         stringsAsFactors = FALSE),
              projects[order(projects$projectName), ]),
            selected = dropdownMenuSelections[["viewTimeByProject"]],
            server = TRUE
          )
          
        
      # When new researcher data is fetched from database
          # update selection inputs in the add project form
          updateSelectizeInput(
            session,
            inputId = "projectPI",
            choices = reactiveData$researchers[order(researchers$researcherName), ],
            selected = dropdownMenuSelections[["projectPI"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport1",
            choices = reactiveData$researchers[order(researchers$researcherName), ],
            selected = dropdownMenuSelections[["projectSupport1"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport2",
            choices = reactiveData$researchers[order(researchers$researcherName), ],
            selected = dropdownMenuSelections[["projectSupport2"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport3",
            choices = reactiveData$researchers[order(researchers$researcherName), ],
            selected = dropdownMenuSelections[["projectSupport3"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport4",
            choices = reactiveData$researchers[order(researchers$researcherName), ],
            selected = dropdownMenuSelections[["projectSupport4"]],
            server = TRUE
          )
          
          updateSelectizeInput(
            session,
            inputId = "viewProjectsByResearcher",
            choices = rbind(
              data.frame(researcherID = NA,
                         researcherUteid = NA,
                         researcherName = NA,
                         researcherEmail = NA,
                         primaryDept = NA,
                         secondaryDept = NA,
                         value = "All",
                         label = "All",
                         stringsAsFactors = FALSE),
              researchers[order(researchers$researcherName), ]
            ),
            selected = dropdownMenuSelections[["viewProjectsByResearcher"]],
            server = TRUE
          )
          
      })
    
    
# observeEvent which applies updateSelectDropdownMenus whenever the loadDatabase
# function is called
    observeEvent(
      updateOnLoad$dropdown == TRUE, {
        updateSelectDropdownMenus()
        updateOnLoad$dropdown <- FALSE
    })
    


# Server Scripts ----------------------------------------------------------

    # serverAddProject
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/serverScripts/serverAddProject.R", 
      local = TRUE
    )
    
    # serverAddTime
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking//app/serverScripts/serverAddTime.R",
      local = TRUE
    )
    
    #serverAddPeople
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking//app/serverScripts/serverAddPeople.R",
      local = TRUE
    )
    
    #serverViewProjects
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking//app/serverScripts/serverViewProjects.R",
      local = TRUE
    )
    
    #serverViewTime
    source(
      "C:/Users/jmc6538/Desktop/BDSHProjectTracking//app/serverScripts/serverViewTime.R",
      local = TRUE
    )
    
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
    })
  }
)