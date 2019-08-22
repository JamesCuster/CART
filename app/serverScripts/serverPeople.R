# 1 UI Components ---------------------------------------------------------

# controls the edit button being grayed out
observe({
  # researchers
  if (is.null(input[["researchers_rows_selected"]]) || input[["researchers_rows_selected"]] == "") {
    disable("editResearcher")
  }
  else {
    enable("editResearcher")
  }
  
  # Employees
  if (is.null(input[["employees_rows_selected"]]) || input[["employees_rows_selected"]] == "") {
    disable("editEmployee")
  }
  else {
    enable("editEmployee")
  }
})


# 1.1 Researchers Datatable -----------------------------------------------
output$researchers <- 
  renderDataTable(
    datatable(
      reactiveData$researchers,
      selection = list(
        mode = 'single',
        selected = researcherRowSelected
      ), 
      extensions = "Select",
      rownames=FALSE,
      options = list(
        dom = '<"top"fl> t <"bottom"ip>',
        rowId = 'researcherID'
      )
    ),
    server = TRUE
  )


# 1.2 Researchers download ------------------------------------------------
output$downloadResearchers <- downloadHandler(
  filename = function() {
    paste("researchers_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(reactiveData$researchers, 
              file, 
              row.names = FALSE)
  }
)


# 1.3 employees Datatable -------------------------------------------------
output$employees <- 
  renderDataTable(
    datatable(
      reactiveData$employees,
      selection = list(
        mode = 'single', 
        selected = employeeRowSelected),
      rownames = FALSE,
      options = list(
        dom = '<"top"fl> t <"bottom"ip>'
      )
    ),
    server=TRUE
  )


# 1.4 Employees download --------------------------------------------------
output$downloadEmployees <- downloadHandler(
  filename = function() {
    paste("employees_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(reactiveData$employees,
              file,
              row.names = FALSE)
  }
)



# 2 Manipulate Researcher/Employee Data -----------------------------------

# 2.1 Helper Objects And Functions ----------------------------------------

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


# this data.frame stores information about what inputs are used for employees
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



# 2.2 Add Researcher ------------------------------------------------------
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
            modalButton("Cancel"),
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



# 2.3 Edit Researcher -----------------------------------------------------
# this object is used to preserve the row selected. It is assinged once a row is
# selected and the edit button is pressed. It is used in the renderDataTable
# call
researcherRowSelected <- NULL

observeEvent(
  input$editResearcher, {
    researcherRowSelected <<- input[["researchers_rows_selected"]]
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



# 2.4 Add Employee --------------------------------------------------------
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



# 2.5 Edit Employee -------------------------------------------------------
# this object is used to preserve the row selected. It is assinged once a row is
# selected and the edit button is pressed. It is used in the renderDataTable
# call
employeeRowSelected <- NULL

observeEvent(
  input$editEmployee, {
    employeeRowSelected <<- input[["employees_rows_selected"]]
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