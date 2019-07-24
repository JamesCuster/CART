tabPanel(
  "Add Time",
  # Need to figure out how to manage this...
  selectInput(
    "projectID", 
    "Select the project to add time to",
    projects$projectName
  ),
  selectInput(
    "workBy", 
    "BDSH Staff",
    people$name
  ),
  dateInput(
    "dateOfWork", 
    "Date that this work was completed"
  ),
  dateInput(
    "dateOfEntry", 
    "Date work was logged"
  ),
  textInput(
    "workTime", 
    "Time spend in hours (as number with decimals)"
  ),
  textInput(
    "workDescription", 
    "Brief description of work completed"
  ),
  
  actionButton(
    "submitAddTime", 
    "Submit"
  ),
  
  tags$br(),
  tags$br(),
  tags$h4("Time in the queue to be added to the database"),
  DT::dataTableOutput("timeFormResponses", width = 300),
  
  uiOutput("timeToDatabase")
)