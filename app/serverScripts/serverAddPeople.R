
# controls the edit/delete buttons being grayed out
observe({
  if (is.null(input[["researchers_rows_selected"]]) || input[["researchers_rows_selected"]] == "") {
    disable("editResearcher")
    disable("removeResearcher")
  }
  else {
    enable("editResearcher")
    enable("removeResearcher")
  }
})


# Create Input data.frame
# this data.frame stores information about what inputs are used for researchers 
researcherInputs <- 
  data.frame(
    ids = c("researcherID",
            "researcherUteid",
            "researcherName",
            "researcherEmail",
            "primaryDept",
            "secondaryDept"),
    labels = c("researcherID",
               "Researcher's UT EID",
               "Researcher's Name",
               "Researchers Email",
               "Primary Department",
               "Secondary Department"),
    type = c("skip",
             "textInput",
             "textInput",
             "textInput",
             "textInput",
             "textInput"),
    stringsAsFactors = FALSE
  )



# Modal Functions ---------------------------------------------------------

# Function that creates the inputs for the researcher modal
modalInputs <- function(ids, labels, type, values) {
  fields <- list()
  for (i in seq_along(ids)) {
    if (type[i] == "skip") {
      fields[[i]] <- NULL
    }
    else if (type[i] == "textInput") {
      value <- ifelse(missing(values) || is.na(values[i]), "", values[i])
      fields[[i]] <- textInput(inputId = ids[i],
                               label = labels[i],
                               value = value)
    }
  }
  fields
}





# Database Callback Functions ---------------------------------------------

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
        if (is.null(input[[x]]) || is.na(input[[x]]) || input[[x]] == "") {
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



# Delete researcher callback
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
        if (input[[x]] == "") {
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


# Add Researcher -----------------------------------------------------
observeEvent(
  input$addResearcher, {
    fields <- 
      modalInputs(
        researcherInputs$ids, 
        researcherInputs$labels, 
        researcherInputs$type
      )
    
    showModal(
      modalDialog(
        title = "Add Researcher",
        fields,
        footer = 
          div(
            modalButton('Cancel'),
            actionButton("insertResearcher", "Save")
          )
      )
    )
  }
)


observeEvent(
  input$insertResearcher, {
    insertCallback(researcherInputs$ids, "researchers")
    removeModal()
  }
)



# Edit Researcher ------------------------------------------------------------
observeEvent(
  input$editResearcher, {
    row <- input[["researchers_rows_selected"]]
    if(!is.null(row)) {
      if (row > 0) {
        fields <- 
          modalInputs(
            researcherInputs$ids, 
            researcherInputs$labels, 
            researcherInputs$type,
            reactiveData$researchers[row, ]
          )
        
        showModal(
          modalDialog(
            title = "Edit Researcher",
            fields,
            footer = 
              div(
                modalButton("Cancel"),
                actionButton("updateResearcher", "Save")
              )
          )
        )
      }
    }
  }
)


observeEvent(
  input$updateResearcher, {
    row <- input[["researchers_rows_selected"]]
    updateCallback(
      researcherInputs$ids, 
      reactiveData$researchers, 
      row, 
      "researcherID",
      "researchers")
    removeModal()
  }
)


# Delete Researcher -------------------------------------------------------
observeEvent(
  input$removeResearcher, {
    row <- input[["researchers_rows_selected"]]
    if (!is.null(row) && row > 0) {
      rowid <- reactiveData$researchers[input[["researchers_rows_selected"]], "researcherID"]
      fields <- list()
      for (i in researcherInputs$ids) {
        fields[[i]] <- div(paste0(i, " = ", reactiveData$researchers[rowid, i]))
      }

      showModal(
        modalDialog(
          title = "Delete Researcher",
          tags$p("Are you sure you want to delete this record?"),
          fields,
          footer = 
            div(
              modalButton("Cancel"),
              actionButton("deleteResearcher", "Delete")
            )
        )
      )
    }
  }
)


observeEvent(
  input$deleteResearcher, {
    row <- input[["researchers_rows_selected"]]
    deleteCallback(
      reactiveData$researchers,
      row,
      "researcherID",
      "researchers")
    removeModal()
  }
)



output$researchers <- 
  renderDataTable(
    datatable(
      reactiveData$researchers[, !names(reactiveData$researchers) %in% c("value", "label")],
      selection='single', 
      rownames=FALSE,
      options = list(
        dom = '<"top"fl> t <"bottom"ip>'
      )
    ),
    server=TRUE
  )






# Employees ---------------------------------------------------------------

# controls the edit/delete buttons being grayed out
observe({
  if (is.null(input[["employees_rows_selected"]]) || input[["employees_rows_selected"]] == "") {
    disable("editEmployee")
    disable("removeEmployee")
  }
  else {
    enable("editEmployee")
    enable("removeEmployee")
  }
})

employeeInputs <- 
  data.frame(
    ids = c("bdshID",
            "employeeUteid",
            "employeeName",
            "employeeEmail",
            "degree",
            "role"),
    labels = c("bdshIDID",
               "Employees's UT EID",
               "Employees's Name",
               "Emplyees Email",
               "Degree",
               "Role"),
    type = c("skip",
             "textInput",
             "textInput",
             "textInput",
             "textInput",
             "textInput"),
    stringsAsFactors = FALSE
  )


# Add Employee -----------------------------------------------------
observeEvent(
  input$addEmployee, {
    fields <- 
      modalInputs(
        employeeInputs$ids, 
        employeeInputs$labels, 
        employeeInputs$type
      )
    
    showModal(
      modalDialog(
        title = "Add BDSH Employee",
        fields,
        footer = 
          div(
            modalButton("Cancel"),
            actionButton("insertEmployee", "Save")
          )
      )
    )
  }
)


observeEvent(
  input$insertEmployee, {
    insertCallback(employeeInputs$ids, "employees")
    removeModal()
  }
)



# edit Employee -----------------------------------------------------------
observeEvent(
  input$editEmployee, {
    row <- input[["employees_rows_selected"]]
    if(!is.null(row)) {
      if (row > 0) {
        fields <- 
          modalInputs(
            employeeInputs$ids, 
            employeeInputs$labels, 
            employeeInputs$type,
            reactiveData$employees[row, ]
          )
        
        showModal(
          modalDialog(
            title = "Edit Employee",
            fields,
            footer = 
              div(
                modalButton("Cancel"),
                actionButton("updateEmployee", "Save")
              )
          )
        )
      }
    }
  }
)


observeEvent(
  input$updateEmployee, {
    row <- input[["employees_rows_selected"]]
    updateCallback(
      employeeInputs$ids, 
      reactiveData$employees, 
      row, 
      "bdshID",
      "employees")
    removeModal()
  }
)



# Delete Employee -------------------------------------------------------
observeEvent(
  input$removeEmployee, {
    row <- input[["employees_rows_selected"]]
    if (!is.null(row) && row > 0) {
      rowid <- reactiveData$employees[input[["employees_rows_selected"]], "bdshID"]
      fields <- list()
      for (i in employeeInputs$ids) {
        fields[[i]] <- div(paste0(i, " = ", reactiveData$employees[rowid, i]))
      }
      
      showModal(
        modalDialog(
          title = "Delete Employee",
          tags$p("Are you sure you want to delete this record?"),
          fields,
          footer = 
            div(
              modalButton("Cancel"),
              actionButton("deleteEmployee", "Delete")
            )
        )
      )
    }
  }
)


observeEvent(
  input$deleteEmployee, {
    row <- input[["employees_rows_selected"]]
    deleteCallback(
      reactiveData$employees,
      row,
      "bdshID",
      "employees")
    removeModal()
  }
)



# output ------------------------------------------------------------------

output$employees <- 
  renderDataTable(
    datatable(
      reactiveData$employees[, !names(reactiveData$employees) %in% c("value", "label")],
      selection='single', 
      rownames=FALSE,
      options = list(
        dom = '<"top"fl> t <"bottom"ip>'
      )
    ),
    server=TRUE
  )



# # todos ---------------------------------------------------------------------
# # modify checkDuplicateResearcher/Employee to have checks on names as well?
# 
# # 1 Add Researcher Helper functions and objects --------------------------------
# 
# # 1.1 Vectors of input names and variable names in addResearcherFormData -------
# # addResearcher form inputs
# addResearcherInputs <- 
#   c("Delete",
#     "Edit",
#     "researcherID",
#     "researcherUteid",
#     "researcherName",
#     "researcherEmail",
#     "primaryDept",
#     "secondaryDept"
#   )
# 
# # researcherFromData variables
# addResearcherFields <- 
#   c("Delete",
#     "Edit",
#     "researcherID",
#     "researcherUteid",
#     "researcherName",
#     "researcherEmail",
#     "primaryDept",
#     "secondaryDept"
#   )
# 
# # variables that need to be removed from reseearcherFormData before adding to
# # database
# addResearcherRemoveForDatabase <- 
#   c("Delete",
#     "Edit")
# 
# 
# # 2 Add Researcher Reactives ------------------------------------------------
# 
# # 2.1 addResearcherFormData reactive ----------------------------------------
# # make reactive data.frame for addResearcherFormData
# reactiveFormData$researcherFormData <- 
#   setNames(data.frame(matrix(nrow = 0, ncol = 8)), addResearcherFields)
# 
# 
# # 2.2 cleanResearcherFormData -----------------------------------------------
# # reactive that cleans form data after added to queue is pressed. Used in 1.2
# cleanResearcherFormData <- reactive({
#   #browser()
#   researcherFormResponse <- 
#     sapply(
#       addResearcherFields,
#       function(x) {
#         # researcherID is handled by database. Delete/Edit are added when Add To
#         # Queue is pressed
#         if (x %in% c("Delete", "Edit", "researcherID")) {
#           NA
#         }
#         else if (input[[x]] == "") {
#           NA
#         } else {
#           input[[x]]
#         }
#       }
#     )
# })
# 
# 
# # 2.3 checkDuplicateResearcher reactive -------------------------------------
# # Checks if researcher is already in database
# checkDuplicateResearcher <- reactive({
#   if (input[["researcherUteid"]] %in% reactiveData$researchers$researcherUteid) {
#     TRUE
#   } else {
#     FALSE
#   }
# })
# 
# 
# 
# # 3 Add Researcher Observers ------------------------------------------------
# 
# # 3.1 Add To Queue Button ---------------------------------------------------
# observeEvent(
#   input$submitAddResearcher, {
#     # Check if input is a duplicate if so return error in UI otherwise proceed
#     if (checkDuplicateResearcher()) {
#       output$checkDuplicateResearcher <- 
#         renderText(
#           "Warning: The researcher UTeid you input already exisit in the researchers table")
#     } else {
#       # Applies the cleanResearcherFormData reactive and converts it to data.frame
#       researcherFormResponse <- as.data.frame(t(cleanResearcherFormData()), stringsAsFactors = FALSE)
#       
#       # Adds researcherFormResponses to the researcherFormData reactive
#       reactiveFormData$researcherFormData <- rbind(reactiveFormData$researcherFormData, researcherFormResponse)
#       
#       # adds the Delete/Edit links to researcherFormData
#       reactiveFormData$researcherFormData <- addDeleteEditLink(reactiveFormData$researcherFormData, "researcherFormData")
#       
#       # Resets the addProject form inputs to defaults
#       sapply(
#         addResearcherFields,
#         function(x) {
#           reset(x)
#         }
#       )
#     }
#     
#   }
# )
# 
# 
# # 3.2 Save To Database button ---------------------------------------------
# observeEvent(
#   input$researcherToDatabase, {
#     # remove variables that are not saved to database (delete/edit links,
#     # values/labels variables)
#     researcherFormData <-
#       reactiveFormData$researcherFormData[, !(names(reactiveFormData$researcherFormData) %in% addResearcherRemoveForDatabase)]
#     
#     # Write table to database
#     dbWriteTable(BDSHProjects, "researchers", researcherFormData, append = TRUE)
#     
#     # Clear reactive data.frame after added to database
#     reactiveFormData$researcherFormData <- reactiveFormData$researcherFormData[c(), ]
#   }
# )
# 
# 
# # 3.3 Table Link Delete Row -----------------------------------------------
# # This controls what happens when the delete buttons on the researcherForm
# # datatable are pressed
# observeEvent(
#   input$researcherFormDataDelete, {
#     # identify row to be deleted
#     rowID <- parseDeleteEvent(input$researcherFormDataDelete)
#     
#     # delete row from data.frame
#     reactiveFormData$researcherFormData <- reactiveFormData$researcherFormData[-rowID, ]
#     
#     # reset data.frame's row.names and recalculate the Delete/Edit links
#     row.names(reactiveFormData$researcherFormData) <- NULL
#     reactiveFormData$researcherFormData <- addDeleteEditLink(reactiveFormData$researcherFormData, "researcherFormData")
#   }
# )
# 
# 
# # 3.4 Table Link Edit Row -------------------------------------------------
# # # This controls what happens when the edit buttons on the researcherForm
# # datatable are pressed
# observeEvent(
#   input$researcherFormDataEdit, {
#     # identify row to be edited
#     rowID <- parseDeleteEvent(input$researcherFormDataEdit)
#     
#     # Grab row to be edited
#     editResearcher <- reactiveFormData$researcherFormData[rowID, ]
#     
#     # Remove the row to be edited from the data.frame/table
#     reactiveFormData$researcherFormData <- reactiveFormData$researcherFormData[-rowID, ]
#     
#     # reset data.frame's row.names and recalculate the Delete/Edit links
#     row.names(reactiveFormData$researcherFormData) <- NULL
#     reactiveFormData$researcherFormData <- addDeleteEditLink(reactiveFormData$researcherFormData, "researcherFormData")
#     
#     # Repopulate the form with the values of row to be edited
#     sapply(
#       addResearcherInputs,
#       function(x) {
#         updateTextInput(
#           session,
#           inputId = x,
#           value = editResearcher[, x]
#         )
#       }
#     )
#   }
# )
# 
# 
# # 4 Output ------------------------------------------------------------------
# output$researcherFormData <- 
#   renderDataTable({
#     datatable(reactiveFormData$researcherFormData[-3], escape = FALSE)
#   })
# 
# 
# 
# # 5 Add Employee Helper Objects and Functions -------------------------------
# 
# # Add employee form inputs
# addEmployeeInputs <- 
#   c("employeeUteid",
#     "employeeName",
#     "employeeEmail",
#     "degree",
#     "role"
#   )
# 
# # addEmployeeFormData variables
# addEmployeeFields <- 
#   c("Delete", 
#     "Edit",
#     "bdshID",
#     "employeeUteid",
#     "employeeName",
#     "employeeEmail",
#     "degree",
#     "role"
#   )
# 
# # variables that need to be removed from employeeFormData before adding to
# # database
# addEmployeeRemoveForDatabase <- 
#   c("Delete",
#     "Edit")
# 
# 
# # 6 Add Employee Reactives --------------------------------------------------
# 
# # 6.1 addEmployeeFormData reactive ------------------------------------------
# # make reactive data.frame for addEmployeeFormData
# reactiveFormData$employeeFormData <- 
#   setNames(data.frame(matrix(nrow = 0, ncol = 8)), addEmployeeFields)
# 
# # cleanEmployeeFormData reactive --------------------------------------------
# # reactive that cleans form data after it has been added to queue. Used in 2.2
# cleanEmployeeFormData <-
#   reactive({
#     employeeFormResponse <- 
#       sapply(
#         addEmployeeFields, 
#         function(x) {
#           # researcherID is handled by database. Delete/Edit are added when Add To
#           # Queue is pressed
#           if (x %in% c("Delete", "Edit", "bdshID")) {
#             NA
#           }
#           else if (input[[x]] == "") {
#             return(NA)
#           } else {
#             input[[x]]
#           }
#         }
#       )
#     employeeFormResponse
#   })
# 
# 
# # 6.3 checkDuplicateEmployee reactive ---------------------------------------
# # Checks if employee is already in database
# checkDuplicateEmployee <- reactive({
#   if (input[["employeeUteid"]] %in% reactiveData$employees$employeeUteid) {
#     TRUE
#   } else {
#     FALSE
#   }
# })
# 
# 
# 
# # 7 Add Employee Observers ------------------------------------------------
# 
# # 7.1 Add To Queue Button ---------------------------------------------------
# # This controls what happens when the add to queue button on the add employee
# # tab is pressed
# observeEvent(
#   input$submitAddEmployee, {
#     # Check if input is a duplicate if so return error in UI otherwise proceed
#     if (checkDuplicateEmployee()) {
#       output$checkDuplicateEmployee <- 
#         renderText(
#           "Warning: The employee UTeid you input already exisit in the employees table")
#     } else {
#       # Applies the cleanEmployeeFormData reactive and converts it to data.frame
#       employeeFormResponse <- as.data.frame(t(cleanEmployeeFormData()), stringsAsFactors = FALSE)
#       
#       # Adds employeeFormResponses to the employeeFormData reactive
#       reactiveFormData$employeeFormData <- rbind(reactiveFormData$employeeFormData, employeeFormResponse)
#       
#       # adds the Delete/Edit links to employeeFormData
#       reactiveFormData$employeeFormData <- addDeleteEditLink(reactiveFormData$employeeFormData, "employeeFormData")
#       
#       # Resets the addEmployee form inputs to defaults
#       sapply(
#         addEmployeeInputs,
#         function(x) {
#           reset(x)
#         }
#       )
#     }
#   }
# )
# 
# 
# # 7.2 Save To Database button -----------------------------------------------
# observeEvent(
#   input$employeeToDatabase, {
#     # remove variables that are not saved to database (Peoples Names,
#     # delete/edit links, values/labels variables)
#     employeeFormData <-
#       reactiveFormData$employeeFormData[, !(names(reactiveFormData$employeeFormData) %in% addEmployeeRemoveForDatabase)]
#     
#     # Write table to database
#     dbWriteTable(BDSHProjects, "employees", employeeFormData, append = TRUE)
#     
#     # Clear reactive data.frame after added to database
#     reactiveFormData$employeeFormData <- reactiveFormData$employeeFormData[c(), ]
#   }
# )
# 
# 
# # 7.3 Table Link Delete Row -------------------------------------------------
# # This controls what happens when the delete buttons on the employee form
# # datatable are pressed
# observeEvent(
#   input$employeeFormDataDelete, {
#     # identify row to be deleted
#     rowID <- parseDeleteEvent(input$employeeFormDataDelete)
#     
#     # delete row from data.frame
#     reactiveFormData$employeeFormData <- reactiveFormData$employeeFormData[-rowID, ]
#     
#     # reset data.frame's row.names and recalculate the Delete/Edit links
#     row.names(reactiveFormData$employeeFormData) <- NULL
#     reactiveFormData$employeeFormData <- addDeleteEditLink(reactiveFormData$employeeFormData, "employeeFormData")
#   }
# )
# 
# 
# # 7.4 Table Links Edit Row --------------------------------------------------
# # # This controls what happens when the edit buttons on the employee form
# # datatable are pressed
# observeEvent(
#   input$employeeFormDataEdit, {
#     # identify row to be edited
#     rowID <- parseDeleteEvent(input$employeeFormDataEdit)
#     
#     # Grab row to be edited
#     editEmployee <- reactiveFormData$employeeFormData[rowID, ]
#     
#     # Remove the row to be edited from the data.frame/table
#     reactiveFormData$employeeFormData <- reactiveFormData$employeeFormData[-rowID, ]
#     
#     # reset data.frame's row.names and recalculate the Delete/Edit links
#     row.names(reactiveFormData$employeeFormData) <- NULL
#     reactiveFormData$employeeFormData <- addDeleteEditLink(reactiveFormData$employeeFormData, "employeeFormData")
#     
#     # Repopulate the form with the values of row to be edited
#     sapply(
#       addEmployeeInputs,
#       function(x) {
#         updateTextInput(
#           session,
#           inputId = x,
#           value = editEmployee[, x]
#         )
#       }
#     )
#   }
# )
# 
# 
# 
# # 8 Output ------------------------------------------------------------------
# output$employeeFormData <-
#   renderDataTable(
#     datatable(reactiveFormData$employeeFormData[-3], escape = FALSE)
#   )