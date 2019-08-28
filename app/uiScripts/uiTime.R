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
  
  # Filter time inputs
  uiOutput("timeFilters"),
  
  tags$br(),
  tags$br(),
  
  dataTableOutput("time", width = 300),
  
  actionButton(
    "downloadTimeData",
    "Download Time"
  )
)