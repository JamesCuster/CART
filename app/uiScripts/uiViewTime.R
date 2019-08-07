tabPanel(
  "View Time",
  
  # Filter time inputs
  div(
    # By Project
    selectizeInput(
      inputId = "viewTimeByProject",
      label = "Project",
      choices = NULL,
      options = list(
        placeholder = "All",
        onInitialize = I("function() {this.setValue('All');}")
      )
    ),
    
    # By employee
    div(
      selectizeInput(
        inputId = "viewTimeByEmployee",
        label = "BDSH Staff",
        choices = NULL,
        options = list(
          placeholder = "All",
          onInitialize = I("function() {this.setValue('All');}")
        )
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
  ),
  
  # Time Data
  dataTableOutput("viewTime", width = 300)
)