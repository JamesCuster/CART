tabPanel(
  
  "View Projects",
  
  # Filter Projects inputs

  div(
    selectInput(
      inputId = "viewProjectsByStatus", 
      label = "Project Status", 
      choices = c("All", "Active", "Complete", "Inactive",  "Quiet")
    ),
    div(
      selectizeInput(
        inputId = "viewProjectsByEmployee",
        label = "BDSH Staff",
        choices = sort(employees$employeeName),
        options = list(
          placeholder = NA,
          onInitialize = I("function() {this.setValue('');}")
        ),
      ),
      style = "margin-left: 20px;"
    ),
    style = "display: flex; align-items: flex-start;"
  ),
  
  
  # Projects Data
  dataTableOutput("viewProjects", width = 300)
)