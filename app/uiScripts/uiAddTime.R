tabPanel(
  "Add Time",
  
  tags$h1("Add Time To A Project"),
  
  selectizeInput(
    inputId = "timeProjectID",
    label = "Select Project",
    choices = projects$projectName,
    options = list(
      placeholder = NA,
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  selectizeInput(
    inputId = "workBy",
    label = "BDSH Staff",
    choices = people$name,
    options = list(
      placeholder = NA,
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
  
  selectizeInput(
    inputId = "workTimeCategory",
    label = "Effort Category",
    choices = c("Small", "Medium", "Large"),
    options = list(
      placeholder = NA,
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  selectizeInput(
    inputId = "workCategory",
    label = "Work Category",
    choices = list(
      `Study Design` = c("Conceptualization", "Analysis Plan", "Power/Sample Size"),
      Analysis = c("Data Management", "Analysis", "Report/Manuscript")
    ),
    options = list(
      placeholder = NA,
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  withTags(
    div(
      h5(
        b("Work Description")
      ),
      textarea(
        id = "workDescription", 
        class = "form-control shiny-bound-input",
        style = "width: 300px; height: 102px"
      )
    )
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