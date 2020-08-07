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
      rownames = FALSE,
      options = list(
        dom = '<"top"fl> t <"bottom"ip>',
        rowId = 'researcherID',
        order = list(0, 'desc')
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
             "selectizeInput",
             "selectizeInput"),
    stringsAsFactors = FALSE
  )

choicesResearcher <- reactive({
  x <- list()
  deptList <- 
    list(`Dell Medical School` = 
           list("Dell Pediatric Research Institute",
                "Diagnostic Medicine",
                "Health Social Work",
                "Internal Medicine",
                "Medical Education",
                "Neurology",
                "Neurosurgery",
                "Oncology",
                "Ophthalmology",
                "Pediatrics",
                "Population Health",
                "Psychiatry",
                "Surgery and Perioperative Care",
                "Women's Health",
                "Other Dell Medical School"),
         `Seton/Ascension` = 
           list("Seton/Ascension"),
         `UT` = 
           list("School of Social Work",
                "School of Nursing",
                "College of Pharmacy",
                "Other UT Austin",
                "Other UT System"),
         `Other` = 
           list("Other"))
  x[["primaryDept"]] <- deptList
  x[["secondaryDept"]]<- deptList
  x
})


# Data frame that contains input notes for researcher department. Call input
# notes table to render to html
ResearcherDeptNotes <- data.frame(`1` = c("Notes: ", "", ""), 
                  `2` = c("For Dell Med students and residents use Medical Education.", 
                          "For Seton/Ascension residents use Seton/Ascension.", 
                          "For other UT students use department of Dell Med Advisor."), 
                  stringsAsFactors = FALSE)



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
    choices <- choicesResearcher()
    fields <- 
      modalInputs(
        researcherInputs$ids, 
        researcherInputs$labels, 
        researcherInputs$type,
        choices = choices
      )
    # browser()
    fields$primaryDept$children <- list(fields$primaryDept$children,
                                        inputNotesTable(ResearcherDeptNotes))
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



# When an attempt to add a researcher is made, this function is run to check the
# new entry against the database to prevent duplication. Researcher UTeid, name,
# and email are all checked. If no duplication is found, a NULL value is
# returned, if a possible duplicate is found, then that entry(ies) are grabbed
# from the database to be displayed in a modal that is handled by the
# observeEvent below
checkDuplicateResearcher <- function(id, name, email) {
  # This function checks if `check` is in field
  # check is one of id, name, email
  # field is the corresponding field in the researchers table
  checkInField <- function(check, field) {
    if (check == "") {
      FALSE
    }
    else {
      any(check == field, na.rm = TRUE)
    }
  }
  
  # control logic to check for duplicate researcher. If no duplicate is found
  # FALSE is returned. If a duplicate is found, then progress to the next
  # section to find the duplication, and display modal for user to determine
  # next steps
  # checks if id input is duplicate
  if (checkInField(id, reactiveData$researchers$researcherUteid)) {
    duplication <- id
  }
  # trims any leading/trailing whitespace in id and checks if duplicate
  else if (checkInField(trimws(id), reactiveData$researchers$researcherUteid)) {
    duplication <- trimws(id)
  }
  # Checks if name input is duplicate 
  else if (checkInField(name, reactiveData$researchers$researcherName)) {
    duplication <- name
  }
  # trims any leading/trailing whitespace in name and checks if duplicate
  else if (checkInField(trimws(name), reactiveData$researchers$researcherName)) {
    duplication <- trimws(name)
  }
  # Checks if name input is duplicate 
  else if (checkInField(email, reactiveData$researchers$researcherEmail)) {
    duplication <- email
  }
  # trims any leading/trailing whitespace in name and checks if duplicate
  else if (checkInField(trimws(email), reactiveData$researchers$researcherEmail)) {
    duplication <- trimws(email)
  }
  # If no duplication is found, return FALSE
  else {
    return(NULL)
  }
  
  # If duplicate is found, get the duplicate row
  duplicationRow <- 
    reactiveData$researchers[rowSums(reactiveData$researchers == duplication, na.rm = TRUE) > 0, -6]
  
  return(duplicationRow)
}


# ObserveEvent for when insertResearcher is pressed on the Add Researcher Modal
observeEvent(
  input$insertResearcher, {
    # Remove the Add Researcher Modal
    removeModal()
    
    # Check if new entry is duplicate
    duplicate <- checkDuplicateResearcher(
      input$researcherUteid,
      input$researcherName,
      input$researcherEmail
    )
    
    # Create output datatable to display if there is a duplicate
    output$duplicateResearcher <- renderDataTable(
      duplicate,
      options = list(dom = 't')
      )
    
    # If there is a duplicate, then this control flow will display a modal which
    # shows the entry in the database that matches the new input and give the
    # option of canceling or proceeding with the addition. If no duplicate is
    # found then the new entry is added.
    if (!is.null(duplicate)) {
      showModal(
        modalDialog(
          size = "l",
          title = "Possible Researcher Duplicate",
          "Is this the researcher you are trying to add?",
          dataTableOutput("duplicateResearcher"),
          "If yes, the researcher already exists in the database. Please cancel addition.\n 
        If no, proceed with addition.",
          footer = 
            div(
              actionButton("continueAddResearcher", "Add Researcher"),
              actionButton("cancelAddResearcher", "Cancel Addition")
            )
        )
      )
    }
    else {
      insertCallback(researcherInputs$ids, "researchers")
    }
})


# This contols what happens if a duplicate researcher is found and the user
# presses the Add Researcher button on the Possible Duplicate Researcher modal
observeEvent(input$continueAddResearcher, {
  removeModal()
  insertCallback(researcherInputs$ids, "researchers")
})


# This contols what happens if a duplicate researcher is found and the user
# presses the Cancel Addition button on the Possible Duplicate Researcher modal
observeEvent(input$cancelAddResearcher, {
  removeModal()
})



# 2.3 Edit Researcher -----------------------------------------------------
# this object is used to preserve the row selected. It is assinged once a row is
# selected and the edit button is pressed. It is used in the renderDataTable
# call
researcherRowSelected <- NULL

observeEvent(
  input$editResearcher, {
    researcherRowSelected <<- input[["researchers_rows_selected"]]
    row <- input[["researchers_rows_selected"]]
    rowID <- reactiveData$researchers[row, "researcherID"]
    choices <- choicesResearcher()
    if(!is.null(row)) {
      if (row > 0) {
        fields <- 
          modalInputs(
            researcherInputs$ids, 
            researcherInputs$labels, 
            researcherInputs$type,
            reactiveData$researchers[reactiveData$researchers$researcherID == rowID, ],
            choices = choices
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
    rowID <- reactiveData$researchers[row, "researcherID"]
    updateCallback(
      researcherInputs$ids,
      rowID, 
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
    rowID <- reactiveData$employees[row, "bdshID"]
    if(!is.null(row)) {
      if (row > 0) {
        fields <- 
          modalInputs(
            employeeInputs$ids, 
            employeeInputs$labels, 
            employeeInputs$type,
            reactiveData$employees[reactiveData$employees$bdshID == rowID, ]
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
    rowID <- reactiveData$employees[row, "bdshID"]
    updateCallback(
      employeeInputs$ids,
      rowID, 
      "bdshID",
      "employees")
    removeModal()
  }
)