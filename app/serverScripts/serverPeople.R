
# controls the edit button being grayed out
observe({
  if (is.null(input[["researchers_rows_selected"]]) || input[["researchers_rows_selected"]] == "") {
    disable("editResearcher")
  }
  else {
    enable("editResearcher")
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



# Edit Researcher ------------------------------------------------------------
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
        rowId = 'researcherID'#,
        # select = list(
        #   style = 'os',
        #   items = 'row',
        #   selected = 2
        # )
      )
    ),
    server = TRUE
  )




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