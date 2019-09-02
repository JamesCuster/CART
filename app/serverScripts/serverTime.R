
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
    filterViewTime()[, viewTimeDisplay],
    selection = list (
      mode = 'single',
      selected = timeRowSelected),
    rownames = FALSE,
    escape = FALSE,
    options = list(
      dom = '<"top"fl> t <"bottom"ip>',
      order = list(0, 'desc')
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


# time toggle function
# This function is used to write the conditionalPanel inputs required to be able
# to toggle between entering work as a number or as a category. This is a unique
# problem to the Time modal UI. Takes the output produced from modalInputs as
# argument
toggleTime <- function(fields) {
  timeFields <- div(
    # Controls when time as hours is displayed
    conditionalPanel(
      condition = "input.timeAsCat % 2 == 0",
      fields[["workTime"]],
      tags$footer("*Required", style="margin-top: -12px; font-size: 12px; padding-bottom: 8px;")
    ),
    
    # Controls when time as category is displayed
    conditionalPanel(
      condition = "input.timeAsCat % 2 == 1",
      fields[["workTimeCategory"]],
      tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;")
    ),
    
    # Button to toggle between time as hours/category
    fields[["timeAsCat"]],
    style = "display: flex; align-items: flex-start;"
  )
  l1 <- list(timeFields = timeFields)
  fields <- c(lapply(c("timeID",
                       "timeProjectID",
                       "workBy",
                       "dateOfWork",
                       "dateOfEntry"),
                     function(x) {fields[[x]]}),
              l1,
              lapply(c("workCategory",
                       "workDescription"),
                     function(x) {fields[[x]]})
  )
  fields
}

# This controls the button that controls toggling between time as numeric or
# category (it updates the text displayed in the button when clicked)
observeEvent(
  input$timeAsCat, {
    if (input$timeAsCat %% 2 == 0) {
      updateActionButton(
        session,
        inputId = "timeAsCat",
        label = "Enter As Category"
      )
    } else {
      updateActionButton(
        session,
        inputId = "timeAsCat",
        label = "Enter As Hours"
      )
    }
  })


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



# 2.2 Manipulate Time Data ------------------------------------------------

# 2.2.1 Add Time ----------------------------------------------------------
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
    fields <- toggleTime(fields)
    
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


# 2.2.2 Edit Time ---------------------------------------------------------
# this object is used to preserve the row selected. It is assinged once a row is
# selected and the edit button is pressed. It is used in the renderDataTable
# call
timeRowSelected <- NULL

observeEvent(
  input$editTime, {
    timeRowSelected <<- input[["time_rows_selected"]]
    choices <- choicesTime()
    row <- input[["time_rows_selected"]]
    if(!is.null(row)) {
      if (row > 0) {
        # remove the timeAscat toggleButton from list so both can be displayed
        # at the same time
        timeInputs <- timeInputs[timeInputs$ids != "timeAsCat", ]
        fields <- 
          modalInputs(
            timeInputs$ids, 
            timeInputs$labels, 
            timeInputs$type,
            reactiveData$time[row, ],
            choices = choices
          )
        
        showModal(
          modalDialog(
            title = "Edit Time",
            fields,
            footer = 
              div(
                modalButton("Cancel"),
                actionButton("updateTime", "Save")
              )
          )
        )
      }
    }
  }
)

observeEvent(
  input$updateTime, {
    row <- input[["time_rows_selected"]]
    updateCallback(
      timeInputs[!timeInputs$ids == "timeAsCat", "ids"], 
      reactiveData$time, 
      row, 
      "timeID",
      "time")
    removeModal()
  }
)



# 3 Fetch Merged Time Data ------------------------------------------------

# 3.1 Database Query ------------------------------------------------------
# This query request the database to get the time table and join with projects
# and employees
viewTimeQuery <- 
  "select t.timeID,
       t.timeProjectID,
       p.projectName,
       t.workBy,
       e.employeeName,
       e.employeeEmail,
       t.dateOfWork,
       t.dateOfEntry,
       t.workTime,
       t.workTimeCategory,
       t.workCategory,
       t.workDescription
from time t
left join projects p on t.timeProjectID = p.projectID
left join employees e on t.workBy = e.bdshID"


# 3.2 Fetch View Time Data --------------------------------------------
# This observer fetches the data for the reactiveData$viewTime reactive using the
# SQL query above whenever new time data is loaded from the database
observeEvent(
  reactiveData$time, {
    viewTimeQuery <- dbSendQuery(BDSHProjects, viewTimeQuery)
    reactiveData$viewTime <- dbFetch(viewTimeQuery)
    dbClearResult(viewTimeQuery)
  }
)



# 4 View Time Data --------------------------------------------------------

# 4.1 Helper Objects and Functions ----------------------------------------

# 4.1.1 Datatable Display Variables ---------------------------------------
viewTimeDisplay <- c("timeID",
                     "projectName",
                     "employeeName",
                     "employeeEmail",
                     "dateOfWork",
                     "dateOfEntry",
                     "workTime",
                     "workTimeCategory",
                     "workCategory",
                     "workDescription")

# 4.1.2 Filter Time Reactive ----------------------------------------------
# Reactive to filter projects data based on viewTimeByProject,
# viewTimeByEmployee, and viewTimeByDate
filterViewTime <- 
  reactive({
    # browser()
    if (!(is.null(input$viewTimeByProject) || 
          is.null(input$viewTimeByEmployee) || 
          is.null(input$viewTimeByDate))) {
      
      filtered <- reactiveData$viewTime %>% 
        {if (input$viewTimeByProject != "All") {
          filter(., timeProjectID == input$viewTimeByProject)
        }
          else {.}
        } %>% 
        {if (input$viewTimeByEmployee != "All") {
          filter(., workBy == input$viewTimeByEmployee)
        } 
          else {.}
        } %>% 
        {if (!is.na(input$viewTimeByDate[1])) {
          filter(., as.Date(dateOfWork) >= input$viewTimeByDate[1])
        }
          else {.}
        } %>% 
        {if (!is.na(input$viewTimeByDate[2])) {
          filter(., as.Date(dateOfWork) <= input$viewTimeByDate[2])
        }
          else {.}
        }
      return(filtered)
    }
  })


# 5 Download Time ---------------------------------------------------------

# 5.1 Download Time Modal -------------------------------------------------
observeEvent(
  input$downloadTimeData, {
    showModal(
      modalDialog(
        title = "Download Time Data",
        
        radioButtons(
          "timeDownloadSelection",
          "Select The Time Data You Want",
          c("Complete Data", "Filtered Data"),
          selected = "Complete Data"
        ),
        
        footer = 
          div(
            modalButton("Cancel"),
            downloadButton("downloadTime", "Download Time")
          )
      )
    )
  }
)


# 5.2 Collect Projects Download Data --------------------------------------
getDownloadTimeData <- reactive({
  if (input$timeDownloadSelection == "Filtered Data") {
    df <- filterViewTime()
  }
  else {
    df <- reactiveData$viewTime
  }
  df
})


# 5.3 Projects Download Handler -------------------------------------------
output$downloadTime <- downloadHandler(
  filename = function() {
    paste("time_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(getDownloadTimeData(),
              file,
              row.names = FALSE)
  }
)
