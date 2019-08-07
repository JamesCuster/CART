tabPanel(
  "Add Time",
  
  tags$h1("Add Time To A Project"),
  
  selectizeInput(
    inputId = "timeProjectID",
    label = "Select Project",
    choices = NULL,
    options = list(
      placeholder = NA,
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  selectizeInput(
    inputId = "workBy",
    label = "BDSH Staff",
    choices = NULL,
    options = list(
      placeholder = NA,
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  dateInput(
    inputId = "dateOfWork", 
    label = "Work Completed On"
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  dateInput(
    inputId = "dateOfEntry", 
    label = "Work Logged On"
  ),
  
  
  # These inputs are defined and modified in serverAddTime 1.6
  div(
    uiOutput('workTime'),
    actionButton(
      inputId = "timeAsCat",
      label = "Enter As Category",
      style = "margin-left: 20px; margin-top: 24px; height: 34px;"
    ),
    style = "display: flex; align-items: flex-start;"
  ),
  
  
  selectizeInput(
    inputId = "workCategory",
    label = "Work Category",
    choices = list(
      `Study Design` = c("Conceptualization", "Analysis Plan", "Power/Sample Size"),
      Analysis = c("Data Management", "Analysis", "Report/Manuscript"),
      `BDSH Other` = c("Professional Development", "Other")
    ),
    options = list(
      placeholder = NA,
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
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
  DT::dataTableOutput("timeFormData", width = 300),
  
  # creates button to submit data to database once a form is submitted
  actionButton(
    inputId = "timeToDatabase", 
    label = "Save To Database")
  
)