# 
# # Project form functions --------------------------------------------------
# 
# saveProjectFormData <- function(formResponse) {
#   formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
#   if (exists("projectFormData")) {
#     projectFormData <<- rbind(projectFormData, formResponse)
#   } else {
#     projectFormData <<- formResponse
#   }
# }
# 
# loadProjectFormData <- function() {
#   if (exists("projectFormData")) {
#     projectFormData[-1]
#   }
# }
# 
# 
# # Time form functions -----------------------------------------------------
# 
# saveTimeFormData <- function(formResponse) {
#   formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
#   if (exists("timeFormData")) {
#     timeFormData <<- rbind(timeFormData, formResponse)
#   } else {
#     timeFormData <<- formResponse
#   }
# }
# 
# loadTimeFormData <- function() {
#   if (exists("timeFormData")) {
#     timeFormData[-1]
#   } 
# }
# 
# 
# # Researcher form functions -----------------------------------------------
# 
# saveResearcherFormData <- function(formResponse) {
#   formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
#   if (exists("researcherFormData")) {
#     researcherFormData <<- rbind(researcherFormData, formResponse)
#   } else {
#     researcherFormData <<- formResponse
#   }
# }
# 
# loadResearcherFromData <- function() {
#   if (exists("researcherFormData")) {
#     researcherFormData[-1]
#   }
# }


# BDSH employee form functions --------------------------------------------

saveEmployeeFormData <- function(formResponse) {
  formResponse <- as.data.frame(t(formResponse), stringsAsFactors = FALSE)
  if (exists("employeeFormData")) {
    employeeFormData <<- rbind(employeeFormData, formResponse)
  } else {
    employeeFormData <<- formResponse
  }
}

loadEmployeeFormData <- function(formResponse) {
  if (exists("employeeFormData")) {
    employeeFormData[-1]
  }
}


# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {
    

# monitor database for changes and reload changed tables ------------------
    
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
          refresh[[modified$tableName]] <- TRUE
        }
      )
    
    observe({
      monitorDatabase()
    })
    

# Update select(ize)Input's when tables from database are reloaded --------
    
    # When new employee data is fetched from database
    observeEvent(refresh$employees == TRUE, {
      updateSelectizeInput(
        session,
        inputId = "bdshLead",
        choices = employees$employeeName
      )
      
      updateSelectizeInput(
        session,
        inputId = "bdshSecondary",
        choices = employees$employeeName
      )
      
      # Update selection inputs in the Add Time form
      updateSelectizeInput(
        session,
        inputId = "workBy",
        choices = employees$employeeName
      )
      
      refresh$employees <- FALSE
    })
    
    # When new project data is fetched from database
    observeEvent(refresh$projects == TRUE, {
      updateSelectizeInput(
        session,
        inputId = "timeProjectID",
        choices = projects$projectName
      )
      
      refresh$projects <- FALSE
    })

    # When new researcher data is fetched from database
    observeEvent(refresh$researchers == TRUE, {
      updateSelectizeInput(
        session,
        inputId = "projectPI",
        choices = researchers$researcherName
      )
      
      updateSelectizeInput(
        session,
        inputId = "projectSupport1",
        choices = researchers$researcherName
      )
      
      updateSelectizeInput(
        session,
        inputId = "projectSupport2",
        choices = researchers$researcherName
      )
      
      updateSelectizeInput(
        session,
        inputId = "projectSupport3",
        choices = researchers$researcherName
      )
      
      updateSelectizeInput(
        session,
        inputId = "projectSupport4",
        choices = researchers$researcherName
      )
      refresh$researchers <- FALSE
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
    
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
      #rm()
      #    stopApp()
      #    quit("no")
    })
  }
)