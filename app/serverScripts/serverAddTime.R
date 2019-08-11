
# 1 Helper Functions And Objects ------------------------------------------

# Add time form inputs
addTimeInputs <- 
  c("effortID",
    "timeProjectID",
    "workBy",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")

# addTimeFormData variables
addTimeFields <- 
  c("Delete",
    "Edit",
    "effortID",
    "timeProjectID",
    "timeProjectName",
    "workBy",
    "workByName",
    "dateOfWork",
    "dateOfEntry",
    "workTime",
    "workTimeCategory",
    "workCategory",
    "workDescription")

addTimeRemoveForDatabase <- 
  c("Delete",
    "Edit",
    "timeProjectName", 
    "workByName")


# 2 Reactives ---------------------------------------------------------------

# 2.1 addTimeFormData reactive --------------------------------------------
# make reactive data.frame for addTimeFormData
reactiveFormData$timeFormData <- 
  setNames(data.frame(matrix(nrow = 0, ncol = 13)), addTimeFields)


# 2.2 cleanTimeFormData reactive ------------------------------------------
# Reactive that cleans form data to be converted to data.frame
cleanTimeFormData <-
  reactive({
    #browser()
    timeFormResponse <- sapply(addTimeFields, function(x) {
      if (x %in% c("dateOfWork", "dateOfEntry")) {
        as.character(input[[x]])
      }
      # takes the projectID and fetches projectName from projects data.frame
      else if (x %in% "timeProjectName") {
        y <- gsub("Name", "ID", x)
        # This uses the projectID used above to fetch projectName
        projects[projects$projectID == input[[y]], "projectName", drop = TRUE]
      }
      else if (x %in% "workByName") {
        y <- gsub("Name", "", x)
        employees[employees$bdshID == input[[y]], "employeeName", drop = TRUE]
      }
      
      # projectID is handled by database. Delete/Edit are added when Add To
      # Queue is pressed
      else if (x %in% c("Delete", "Edit", "effortID")) {
        NA
      }
      else if (input[[x]] == "" || is.null(input[[x]])) {
        NA
      }
      else {
        input[[x]]
      }
    })
  })



# Observers ---------------------------------------------------------------

# 3.1 Add To Queue button -------------------------------------------------
observeEvent(
  input$submitAddTime, {
    # Applies the cleanTimeFormData reactive and converts it to data.frame
    timeFormResponse <- as.data.frame(t(cleanTimeFormData()), stringsAsFactors = FALSE)
    
    # Adds timeFormResponses to the timeFormData reactive
    reactiveFormData$timeFormData <- rbind(reactiveFormData$timeFormData, timeFormResponse)
    
    # adds the Delete/Edit links to timeFormData
    reactiveFormData$timeFormData <- addDeleteEditLink(reactiveFormData$timeFormData, "timeFormData")
    
    # Resets the addTime form inputs to defaults
    sapply(
      addTimeInputs,
      function(x) {
        reset(x)
      }
    )
  })

# 
# 
# 
# 
# # 1.2 Add To Queue Button -------------------------------------------------
# # This is what controls what happens when the add to queue button on the add time
# # form is pressed
# observeEvent(
#   input$submitAddTime, {
#     # creates and displays table of inputs
#     saveTimeFormData(cleanTimeFormData())
# 
#     # Clears data from the forms
#     sapply(
#       addTimeFields, 
#       function(x) {
#         updateTextInput(session, x, value = "")
#         session$sendCustomMessage(type = "resetValue", message = x)
#       }
#     )
#     
#     # Creats the datatable to display add time queue
#     output$timeFormData <- 
#       renderDataTable({
#         loadTimeFormData()
#       })
#   }
# )
# 
# 
# # 1.3 Save To Database Button -----------------------------------------------
# #This controls what happens when the save to databse button is pressed on the
# #add time page
# observeEvent(
#   input$timeToDatabase, {
#     # remove variables that are not saved to database (Peoples names)
#     timeFormData <- timeFormData[, !(names(timeFormData) %in% addTimeRemoveForDatabase)]
#     timeFormData <- unnest(timeFormData)
#     
#     # Write table to database
#     dbWriteTable(BDSHProjects, "effort", timeFormData, append = TRUE)
#     
#     # clear data.frame after added to database
#     timeFormData <<- timeFormData[c(), ]
#     
#     # Creats the datatable to display add time queue
#     output$timeFormData <- 
#       renderDataTable({
#         loadTimeFormData()
#       })
#   }
# )
# 
# 
# # 1.4 Delete Row Table Buttons ----------------------------------------------
# # This controls what happens when the delete buttons on the timeForm
# # datatable are pressed
# observeEvent(
#   input$timeFormDataDelete, {
#     # identify row to be deleted
#     rowID <- parseDeleteEvent(input$timeFormDataDelete)
#     
#     # delete row from data.frame
#     timeFormData <- timeFormData[-rowID, ]
#     
#     # reset data.frame's row.names, remove rowID, and save timeFormData to
#     # global environment
#     row.names(timeFormData) <- NULL
#     rowID <- NULL
#     timeFormData <<- timeFormData
#     
#     # Re-render the table for display in the UI
#     output$timeFormData <-
#       renderDataTable({
#         loadTimeFormData()
#       })
#   }
# )
# 
# 
# # 1.5 Edit Row Table Buttons ------------------------------------------------
# # # This controls what happens when the edit buttons on the timeForm
# # datatable are pressed
# observeEvent(
#   input$timeFormDataEdit, {
#     # identify row to be edited
#     rowID <- parseDeleteEvent(input$timeFormDataEdit)
#     
#     # Grab row to be edited
#     edit <- timeFormData[rowID, ]
#     
#     # Remove the row to be edited from the data.frame/table
#     timeFormData <- timeFormData[-rowID, ]
#     
#     # reset data.frame's row.names, remove rowID, and save timeFormData to
#     # global environment
#     row.names(timeFormData) <- NULL
#     rowID <- NULL
#     timeFormData <<- timeFormData
#     
#     # Put the values of the row to be updated back into the form
#     sapply(
#       names(timeFormData[-1]),
#       function(x) {
#         updateTextInput(
#           session,
#           inputId = x,
#           value = edit[, x]
#         )
#       }
#     )
#     
#     # Re-render table after the row to edit has been removed
#     output$timeFormData <-
#       renderDataTable({
#         loadTimeFormData()
#       })
#   }
# )
# 
# # 1.6 Add Time As Category --------------------------------------------------
# # This part changes the input depending on value of input$timeAsCat
# output$workTime <- renderUI({
#   if (input$timeAsCat %% 2 == 0) {
#     tagList(
#       textInput(
#         inputId = "workTime", 
#         label = "Time spent in hours as numeric"
#       ),
#       tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;")
#     )
#   } else {
#     tagList(
#       selectizeInput(
#         inputId = "workTimeCategory",
#         label = "Effort Category",
#         choices = c("Small", "Medium", "Large", "Extra Large"),
#         options = list(
#           placeholder = NA,
#           onInitialize = I("function() {this.setValue('');}")
#         )
#       ),
#       tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;")
#     )
#   }
# })
# 
# # This part changes the button depending on value of input$timeAsCat
# observe({
#   if (input$timeAsCat %% 2 == 0) {
#     updateActionButton(
#       session,
#       inputId = "timeAsCat",
#       label = "Enter As Category"
#     )
#   } else {
#     updateActionButton(
#       session,
#       inputId = "timeAsCat",
#       label = "Enter As Hours"
#     )
#   }
# })
# 
