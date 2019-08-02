
# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {

# Database functionalities ------------------------------------------------

    # Connect to database
    BDSHProjects <- dbConnect(SQLite(), "C:/Users/jmc6538/Desktop/BDSHProjectTracking/BDSHProjects.sqlite")
    
    # Load all database tables
    loadDatabase()
    
    
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
        }
      )
    
    
# inputId's for inputs which need updating as the database gets modified
    # Need updating when new employee data is fetched
    employeesDependentValues <- 
      c(# Update selection inputs in the Add Project form
        "bdshLead",
        "bdshSecondary",
        # Update selection inputs in the Add Time form
        "workBy",
        # Update selection inputs in View Projects
        "viewProjectsByEmployee"
      )
    
    projectsDependentValues <- 
      c(# update selection inputs in the add time form
        "timeProjectID"
      )
    
    researchersDependentValues <- 
      c(# update selection inputs in the add project form
        "projectPI",
        "projectSupport1",
        "projectSupport2",
        "projectSupport3",
        "projectSupport4"
      )
    
    
# Reactive values which will preserve a users inputs even if new data is loaded
# into the database
    dropdownMenuSelections <- reactiveValues()
      
      
    
# Reactives that trigger after new data is loaded from the database that update
# the necessary input dropdown menus to reflect any changes in the database
    updateSelectDropdownMenus <- 
      reactive({
        
        sapply(c(employeesDependentValues, projectsDependentValues, researchersDependentValues),
               function(x) {
                 dropdownMenuSelections[[x]] <<- input[[x]]
               })
        
      # When new employee data is fetched from database
          # Update selection inputs in the Add Project form
          updateSelectizeInput(
            session,
            inputId = "bdshLead",
            choices = sort(reactiveData$employees$employeeName)
          )
          
          updateSelectizeInput(
            session,
            inputId = "bdshSecondary",
            choices = sort(reactiveData$employees$employeeName)
          )
          
          # Update selection inputs in the Add Time form
          updateSelectizeInput(
            session,
            inputId = "workBy",
            choices = sort(reactiveData$employees$employeeName)
          )
          
          # Update selection inputs in View Projects
          updateSelectizeInput(
            session,
            inputId = "viewProjectsByEmployee",
            choices = c("All", sort(reactiveData$employees$employeeName)),
            selected = dropdownMenuSelections[["viewProjectsByEmployee"]]
            )
          
        
      # When new project data is fetched from database
          # update selection inputs in the add time form
          updateSelectizeInput(
            session,
            inputId = "timeProjectID",
            choices = sort(reactiveData$projects$projectName)
          )
          
        
      # When new researcher data is fetched from database
          # update selection inputs in the add project form
          updateSelectizeInput(
            session,
            inputId = "projectPI",
            choices = sort(reactiveData$researchers$researcherName)
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport1",
            choices = sort(researchers$researcherName)
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport2",
            choices = sort(reactiveData$researchers$researcherName)
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport3",
            choices = sort(reactiveData$researchers$researcherName)
          )
          
          updateSelectizeInput(
            session,
            inputId = "projectSupport4",
            choices = sort(reactiveData$researchers$researcherName)
          )
      })
    
    
# observe which applies the monitorDatabase and updateSelectDropdownMenus
# reactives
    observe({
      monitorDatabase()
      updateSelectDropdownMenus()
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
    
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
    })
  }
)