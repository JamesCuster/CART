
# Define server logic required to draw a histogram
shinyServer(
  function(input, output, session) {

# 1 Database functionalities ------------------------------------------------

    BDSHProjects <- dbConnect(SQLite(), paste0(dirPath, "/BDSHProjects.sqlite"))
    
# 1.1 Monitor Database ------------------------------------------------------
# This reactive checks the modified table in the database against the one loaded
# into the app every second. If the modified table has been updated in the
# database then the table that was modifed is reloaded into the app
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
    
    
    # observe which applies the monitorDatabase reactive
    observe({
      monitorDatabase()
    })
    
    
    
# Database Callback Functions ---------------------------------------------
    # These functions are used to create SQL queries which manipulate the database
    
    # function that create insert SQL query
    insertCallback <- function(ids, tab) {
      insert <- paste0(
        "insert into ",
        tab,
        " (",
        paste0(ids, collapse = ", "),
        ") values ("
      )
      fields <- paste(
        lapply(
          ids, 
          function(x) {
            if (is.null(input[[x]]) || is.na(input[[x]]) || class(input[[x]]) == "Date" ||input[[x]] == "") {
              "null"
            }
            else {
              paste0("'", input[[x]], "'")
            }
          }
        ),
        collapse = ", "
      )
      query <- paste0(insert, fields, ")")
      dbExecute(BDSHProjects, query)
    }
    
    
    # function that create delete SQL query
    deleteCallback <- function(df, row, idVar, tab) {
      rowid <- df[row, idVar]
      query <- paste0(
        "delete from ",
        tab, 
        " where ",
        idVar,
        " = ",
        rowid
      )
      dbExecute(BDSHProjects, query)
    }
    
    
    # function that create update SQL query
    updateCallback <- function(ids, df, row, idVar, tab) {
      ids <- ids[!ids %in% idVar]
      update <- paste0(
        "update ",
        tab,
        " set "
      )
      fields <- paste(
        lapply(
          ids, 
          function(x) {
            if (class(input[[x]]) == "Date" || input[[x]] == "") {
              paste0(x, " = ", "null")
            }
            else {
              paste0(x, " = ", paste0("'", input[[x]], "'"))
            }
          }
        ),
        collapse = ", "
      )
      where <- paste0(" where ", idVar, " = ", df[row, idVar])
      query <- paste0(update, fields, where)
      dbExecute(BDSHProjects, query)
    }
    



    
# 2 Update Dropdown Selections ----------------------------------------------
# This section allows for the dropdown menus to be updated as new data from the
# database is loaded
 
# 2.1 update employee dependent inputs --------------------------------------
#     observe({#c(input$addProject, input$editProject), {
#       #browser()
# #      reactiveData$employees, {
#         # Update selection inputs in the Add Project form
#         updateSelectizeInput(
#           session,
#           inputId = "bdshLead",
#           choices = reactiveData$employees[order(reactiveData$employees$employeeName), ],
#           selected = input[["bdshLead"]],
#           server = TRUE
#         )
# 
#         updateSelectizeInput(
#           session,
#           inputId = "bdshSecondary",
#           choices = reactiveData$employees[order(reactiveData$employees$employeeName), ],
#           selected = input[["bdshSecondary"]],
#           server = TRUE
#         )
# 
#         # Update selection inputs in the Add Time form
#         updateSelectizeInput(
#           session,
#           inputId = "workBy",
#           choices = reactiveData$employees[order(reactiveData$employees$employeeName), ],
#           selected = input[["workBy"]],
#           server = TRUE
#         )
# 
#         # Update selection inputs in View Projects
#         updateSelectizeInput(
#           session,
#           inputId = "viewProjectsByEmployee",
#           choices = rbind(
#             data.frame(bdshID = NA,
#                        employeeUteid = NA,    # This is done in order to provide the "All" option
#                        employeeName = NA,
#                        employeeEmail = NA,
#                        degree = NA,
#                        role = NA,
#                        value = "All",
#                        label = "All",
#                        stringsAsFactors = FALSE),
#             reactiveData$employees[order(reactiveData$employees$employeeName), ]),
#           selected = input[["viewProjectsByEmployee"]],
#           server = TRUE
#         )
# 
#         # Update selection inputs in View Time
#         updateSelectizeInput(
#           session,
#           inputId = "viewTimeByEmployee",
#           choices = rbind(
#             data.frame(bdshID = NA,
#                        employeeUteid = NA,    # This is done in order to provide the "All" option
#                        employeeName = NA,
#                        employeeEmail = NA,
#                        degree = NA,
#                        role = NA,
#                        value = "All",
#                        label = "All",
#                        stringsAsFactors = FALSE),
#             reactiveData$employees[order(reactiveData$employees$employeeName), ]),
#           selected = input[["viewTimeByEmployee"]],
#           server = TRUE
#         )
#       }
#     )
# 
# 
# # 2.1 update researcher dependent inputs ------------------------------------
# observeEvent(
#   reactiveData$researchers, {
#     # update selection inputs in the add project form
#     updateSelectizeInput(
#       session,
#       inputId = "projectPI",
#       choices = reactiveData$researchers[order(reactiveData$researchers$researcherName), ],
#       selected = input[["projectPI"]],
#       server = TRUE
#     )
# 
#     updateSelectizeInput(
#       session,
#       inputId = "projectSupport1",
#       choices = reactiveData$researchers[order(reactiveData$researchers$researcherName), ],
#       selected = input[["projectSupport1"]],
#       server = TRUE
#     )
# 
#     updateSelectizeInput(
#       session,
#       inputId = "projectSupport2",
#       choices = reactiveData$researchers[order(reactiveData$researchers$researcherName), ],
#       selected = input[["projectSupport2"]],
#       server = TRUE
#     )
# 
#     updateSelectizeInput(
#       session,
#       inputId = "projectSupport3",
#       choices = reactiveData$researchers[order(reactiveData$researchers$researcherName), ],
#       selected = input[["projectSupport3"]],
#       server = TRUE
#     )
# 
#     updateSelectizeInput(
#       session,
#       inputId = "projectSupport4",
#       choices = reactiveData$researchers[order(reactiveData$researchers$researcherName), ],
#       selected = input[["projectSupport4"]],
#       server = TRUE
#     )
# 
#     # Update selection inputs in view projects
#     updateSelectizeInput(
#       session,
#       inputId = "viewProjectsByResearcher",
#       choices = rbind(
#         data.frame(researcherID = NA,
#                    researcherUteid = NA,
#                    researcherName = NA,
#                    researcherEmail = NA,
#                    primaryDept = NA,
#                    secondaryDept = NA,
#                    value = "All",
#                    label = "All",
#                    stringsAsFactors = FALSE),
#         reactiveData$researchers[order(reactiveData$researchers$researcherName), ]
#       ),
#       selected = input[["viewProjectsByResearcher"]],
#       server = TRUE
#     )
#   }
# )
# 
# 
# # update project dependent inputs -----------------------------------------
# observeEvent(
#   reactiveData$projects, {
#     # update selection inputs in the add time form
#     updateSelectizeInput(
#       session,
#       inputId = "timeProjectID",
#       choices = reactiveData$projects[order(reactiveData$projects$projectName), ],
#       selected = input[["timeProjectID"]],
#       server = TRUE
#     )
# 
#     # update selection inputs in view time
#     updateSelectizeInput(
#       session,
#       inputId = "viewTimeByProject",
#       choices = rbind(
#         data.frame(projectID = NA,
#                    projectName = NA,    # This is done in order to provide the "All" option
#                    bdshLead = NA,
#                    bdshSecondary = NA,
#                    projectPI = NA,
#                    projectSupport1 = NA,
#                    projectSupport2 = NA,
#                    projectSupport3 = NA,
#                    projectSupport4 = NA,
#                    projectDescription = NA,
#                    projectStatus = NA,
#                    projectDueDate = NA,
#                    value = "All",
#                    label = "All",
#                    stringsAsFactors = FALSE),
#         reactiveData$projects[order(reactiveData$projects$projectName), ]),
#       selected = input[["viewTimeByProject"]],
#       server = TRUE
#     )
# 
#     # update selection inputs in view projects
#     updateSelectInput(
#       session,
#       inputId = "viewProjectsByStatus",
#       choices = c("All", unique(reactiveData$projects$projectStatus))
#     )
#   }
# )
#     
#     
#     
# # 3 Server Scripts ----------------------------------------------------------
#     # serverAddProject
#     source(
#       paste0(dirPath, "/app/serverScripts/serverAddProject.r"), 
#       local = TRUE
#     )
#     
#     # serverAddTime
#     source(
#       paste0(dirPath, "/app/serverScripts/serverAddTime.r"),
#       local = TRUE
#     )
    
    # serverAddPeople
    source(
      paste0(dirPath, "/app/serverScripts/serverAddPeople.r"),
      local = TRUE
    )
    
    # serverViewProjects
    source(
      paste0(dirPath, "/app/serverScripts/serverViewProjects.r"),
      local = TRUE
    )

    # # serverViewTime
    # source(
    #   paste0(dirPath, "/app/serverScripts/serverViewTime.r"),
    #   local = TRUE
    # )
    # 
    # # serverViewPeople
    # source(
    #   paste0(dirPath, "/app/serverScripts/serverViewPeople.r"),
    #   local = TRUE
    # )
    # 

# 4. On App Disconnect ----------------------------------------------------
    # stops the app when window is closed
    session$onSessionEnded(function() {
      dbDisconnect(BDSHProjects)
    })
  }
)