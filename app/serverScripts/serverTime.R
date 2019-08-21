
# 1 UI Components ---------------------------------------------------------

# controls the edit buttons being grayed out
observe({
  if (is.null(input[["time_rows_selected"]]) || input[["time_rows_selected"]] == "") {
    disable("editTime")
  }
  else {
    enable("editTime")
  }
})



# NEED TO ADD THIS --------------------------------------------------------
# Controls the project filter UI components
output$timeFilters <- renderUI({
  choices <- choicesTime()
  div(
    # By Project
    selectizeInput(
      inputId = "viewTimeByProject",
      label = "Project",
      choices = choices[["viewTimeByProject"]],
      selected = input$viewTimeByProject
    ),
    
    # By employee
    div(
      selectizeInput(
        inputId = "viewTimeByEmployee",
        label = "BDSH Staff",
        choices = choices[["viewTimeByEmployee"]],
        selected = input$viewTimeByEmployee
      ),
      style = "margin-left: 20px;"
    ),
    
    # By date range
    div(
      dateRangeInput(
        inputId = "viewTimeByDate",
        label = "Date Range",
        start = as.Date(NA),
        end = as.Date(NA)
      ),
      style = "margin-left: 20px;"
    ),
    style = "display: flex; align-itme: flex-start"
  )
})




output$time <- renderDataTable(
  datatable(
 reactiveData$time,
    selection='single', 
    rownames=FALSE,
    escape = FALSE,
    options = list(
      dom = '<"top"fl> t <"bottom"ip>'
    )
  ),
  server=TRUE
)



# 2 Manipulate Time Data -----------------------------------------------

# 2.1 Helper Objects And Functions ----------------------------------------

# this data.frame stores information about what inputs are used for time
timeInputs <- data.frame(
  ids = c("timeID",
          "timeProjectID",
          "workBy",
          "dateOfWork",
          "dateOfEntry",
          "workTime",
          "workTimeCategory",
          "timeAsCat",
          "workCategory",
          "workDescription"),
  labels = c("timeID",
             "Select Project",
             "BDSH Staff",
             "Work Completed On",
             "Work Logged On",
             "Time Spent",
             "Time Category",
             "Enter As Category",
             "Work Category",
             "Work Description"),
  type = c("skip",
           "selectizeInput",
           "selectizeInput",
           "dateInput",
           "dateInput",
           "textInput",
           "selectizeInput",
           "actionButton",
           "selectizeInput",
           "textAreaInput"),
  stringsAsFactors = FALSE
)


# This reactive creates the object which stores the choices for the selection
# inputs
choicesTime <- reactive({
  x <- list()
  
  # Time Inputs
  x[["timeProjectID"]] <- valueLabel(reactiveData$projects, "projectID", "projectName")
  x[["workBy"]] <- valueLabel(reactiveData$employees, "bdshID", "employeeName")
  x[["workTimeCategory"]] <- c("Small", "Medium", "Large", "Extra Large")
  x[["workCategory"]] <- list(
    `Study Design` = c("Conceptualization", "Analysis Plan", "Power/Sample Size"),
    Analysis = c("Data Management", "Analysis", "Report/Manuscript"),
    `BDSH Other` = c("Professional Development", "Other"))
  
  # Time filter input choices
  x[["viewTimeByProject"]] <- c("All", valueLabel(reactiveData$projects, "projectID", "projectName"))
  x[["viewTimeByEmployee"]] <- c("All", valueLabel(reactiveData$employees, "bdshID", "employeeName"))
  x
})



# Add Time ----------------------------------------------------------------

observeEvent(
  input$addTime, {
    choices <- choicesTime()
    fields <- 
      modalInputs(
        timeInputs$ids, 
        timeInputs$labels, 
        timeInputs$type,
        choices = choices
      )
    
    showModal(
      modalDialog(
        title = "Add Time",
        fields,
        footer = 
          div(
            modalButton("Cancel"),
            actionButton("insertTime", "Save")
          )
      )
    )
  }
)


observeEvent(
  input$insertTime, {
    # browser()
    insertCallback(timeInputs[!timeInputs$ids == "timeAsCat", "ids"], "time")
    removeModal()
  }
)








# # 1 Helper Functions And Objects ------------------------------------------
# 
# # Add time form inputs
# addTimeInputs <- 
  # c("timeID",
  #   "timeProjectID",
  #   "workBy",
  #   "dateOfWork",
  #   "dateOfEntry",
  #   "workTime",
  #   "workTimeCategory",
  #   "workCategory",
  #   "workDescription")
# 
# # addTimeFormData variables
# addTimeFields <- 
#   c("Delete",
#     "Edit",
#     "timeID",
#     "timeProjectID",
#     "timeProjectName",
#     "workBy",
#     "workByName",
#     "dateOfWork",
#     "dateOfEntry",
#     "workTime",
#     "workTimeCategory",
#     "workCategory",
#     "workDescription")
# 
# addTimeRemoveForDatabase <- 
#   c("Delete",
#     "Edit",
#     "timeProjectName", 
#     "workByName")
# 
# 
# # 2 Reactives ---------------------------------------------------------------
# 
# # 2.1 addTimeFormData reactive --------------------------------------------
# # make reactive data.frame for addTimeFormData
# reactiveFormData$timeFormData <- 
#   setNames(data.frame(matrix(nrow = 0, ncol = 13)), addTimeFields)
# 
# 
# # 2.2 cleanTimeFormData reactive ------------------------------------------
# # Reactive that cleans form data to be converted to data.frame
# cleanTimeFormData <-
#   reactive({
#     timeFormResponse <- sapply(addTimeFields, function(x) {
#       if (x %in% c("dateOfWork", "dateOfEntry")) {
#         as.character(input[[x]])
#       }
#       # takes the projectID and fetches projectName from projects data.frame
#       else if (x %in% "timeProjectName") {
#         if (input[[gsub("Name", "ID", x)]] == "") {
#           NA
#         }
#         else {
#           x <- gsub("Name", "ID", x)
#           reactiveData$projects[reactiveData$projects$projectID == input[[x]], "projectName", drop = TRUE]
#         }
#       }
#       else if (x %in% "workByName") {
#         if (input[[gsub("Name", "", x)]] == "") {
#           NA
#         }
#         else {
#           x <- gsub("Name", "", x)
#           reactiveData$employees[reactiveData$employees$bdshID == input[[x]], "employeeName", drop = TRUE]
#         }
#       }
#       
#       # projectID is handled by database. Delete/Edit are added when Add To
#       # Queue is pressed
#       else if (x %in% c("Delete", "Edit", "timeID")) {
#         NA
#       }
#       else if (input[[x]] == "" || is.null(input[[x]])) {
#         NA
#       }
#       else {
#         input[[x]]
#       }
#     })
#   })
# 
# 
# 
# # 3 Observers ---------------------------------------------------------------
# 
# # 3.1 Add To Queue button -------------------------------------------------
# observeEvent(
#   input$submitAddTime, {
#     # Applies the cleanTimeFormData reactive and converts it to data.frame
#     timeFormResponse <- as.data.frame(t(cleanTimeFormData()), stringsAsFactors = FALSE)
#     
#     # Adds timeFormResponses to the timeFormData reactive
#     reactiveFormData$timeFormData <- rbind(reactiveFormData$timeFormData, timeFormResponse)
#     
#     # adds the Delete/Edit links to timeFormData
#     reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
#     
#     # Resets the addTime form inputs to defaults
#     sapply(
#       addTimeInputs,
#       function(x) {
#         reset(x)
#       }
#     )
#   })
# 
# 
# # 3.2 Save To Database button ---------------------------------------------
# observeEvent(
#   input$timeToDatabase, {
#     # remove variables that are not saved to database (Peoples Names,
#     # delete/edit links, values/labels variables)
#     timeFormData <-
#       reactiveFormData$timeFormData[, !(names(reactiveFormData$timeFormData) %in% addTimeRemoveForDatabase)]
#     
#     # Write table to database
#     dbWriteTable(BDSHProjects, "time", timeFormData, append = TRUE)
#     
#     # Clear reactive data.frame after added to database
#     reactiveFormData$timeFormData <- reactiveFormData$timeFormData[c(), ]
#   }
# )
# 
# 
# # 3.3 Table Link Delete Row -------------------------------------------------
# # This controls what happens when the delete buttons on the time form
# # datatable are pressed
# observeEvent(
#   input$timeFormDataDelete, {
#     # identify row to be deleted
#     rowID <- parseDeleteEvent(input$timeFormDataDelete)
#     
#     # delete row from data.frame
#     reactiveFormData$timeFormData <- reactiveFormData$timeFormData[-rowID, ]
#     
#     # reset data.frame's row.names and recalculate the Delete/Edit links
#     row.names(reactiveFormData$timeFormData) <- NULL
#     reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
#   }
# )
# 
# 
# # 3.4 Table Links Edit Row --------------------------------------------------
# # # This controls what happens when the edit buttons on the time form
# # datatable are pressed
# observeEvent(
#   input$timeFormDataEdit, {
#     # identify row to be edited
#     rowID <- parseDeleteEvent(input$timeFormDataEdit)
#     
#     # Grab row to be edited
#     editTime <- reactiveFormData$timeFormData[rowID, ]
#     
#     # Remove the row to be edited from the data.frame/table
#     reactiveFormData$timeFormData <- reactiveFormData$timeFormData[-rowID, ]
#     
#     # reset data.frame's row.names and recalculate the Delete/Edit links
#     row.names(reactiveFormData$timeFormData) <- NULL
#     reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
#     
#     # When a row is edited, need to make sure the correct time input is used
#     # (categry/hour). This will check which was used in the row to be edited,
#     # and will make sure the UI displays it
#     if (!is.na(editTime$workTime)) {
#       if (!(input$timeAsCat %% 2 == 0)) {
#         click("timeAsCat")
#       }
#     }
#     else if (!is.na(editTime$workTimeCat)) {
#       if (input$timeAsCat %% 2 == 0) {
#         click("timeAsCat")
#       }
#     }
#     
#     # Repopulate the form with the values of row to be edited
#     sapply(
#       addTimeInputs,
#       function(x) {
#         updateTextInput(
#           session,
#           inputId = x,
#           value = editTime[, x]
#         )
#       }
#     )
#   }
# )
# 
# 
# # 3.5 Time As Category/Hours buttons --------------------------------------
# observeEvent(
#   input$timeAsCat, {
#     if (input$timeAsCat %% 2 == 0) {
#       updateActionButton(
#         session,
#         inputId = "timeAsCat",
#         label = "Enter As Category"
#       )
#     } else {
#       updateActionButton(
#         session,
#         inputId = "timeAsCat",
#         label = "Enter As Hours"
#       )
#     }
# })
# 
# 
# 
# # 4 Output ------------------------------------------------------------------
# 
# # 4.1 Time Form Datatable ---------------------------------------------------
# output$timeFormData <- 
#   renderDataTable(
#     datatable(
#       reactiveFormData$timeFormData[-3], 
#       escape = FALSE)
#   )