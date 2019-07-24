tabPanel(
  "Add Time",
  
  tags$h1("Add Time To A Project"),
  
  selectizeInput(
    inputId = "TimeProjectID",
    label = "Select Project",
    choices = projects$projectName,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  selectizeInput(
    inputId = "workBy",
    label = "BDSH Staff",
    choices = people$name,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  dateInput(
    inputId = "dateOfWork", 
    label = "Work Completed On"
  ),
  
  dateInput(
    inputId = "dateOfEntry", 
    label = "Work Logged On"
  ),
  
  textInput(
    inputId = "workTime", 
    label = "Time spend in hours (as number with decimals)"
  ),
  
  textInput(
    inputId = "workDescription", 
    label = "Brief description of work completed"
  ),
  
  actionButton(
    inputId = "submitAddTime", 
    label = "Add To Queue"
  ),
  
  tags$br(),
  tags$br(),
  tags$h4("Time in the queue to be added to the database"),
  DT::dataTableOutput("timeFormResponses", width = 300),
  
  # creates button to submit data to database once a form is submitted
  actionButton(
    inputId = "timeToDatabase", 
    label = "Save To Database")
  
)