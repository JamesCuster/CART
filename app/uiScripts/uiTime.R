tabPanel(
  "Time",
  
  tags$h1("Time"),
  
  # Buttons to modify time table
  actionButton(
    "addTime",
    "Add"
  ),
  
  actionButton(
    "editTime",
    "Edit"
  ),
  
  actionButton(
    "deleteTime",
    "Delete"
  ),
  
  div(
    selectizeInput(
      inputId = "viewTimeByProject",
      label = "Project",
      choices = "All",
      width = 400
    ),
    
    
    div(
      selectizeInput(
        inputId = "viewTimeByEmployee",
        label = "BDSH Staff",
        choices = "All"
      ),
      style = "margin-left: 20px;"
    ),
    
    div(
      dateRangeInput(
        inputId = "viewTimeByDate",
        label = "Date Range",
        start = "2019-06-01",
        end = NULL
      ),
      style = "margin-left: 20px;"
    ),
    style = "display: flex; align-itme: flex-start"
  ),
    
  # Filter time inputs
  #uiOutput("timeFilters"),
  
  tags$br(),
  tags$br(),
  
  dataTableOutput("time"),
  
  actionButton(
    "downloadTimeData",
    "Download Time"
  )
)