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
        choices = NULL,
        options = list(
          placeholder = "All",
          onInitialize = I("function() {this.setValue('All');}")
        )
      ),
      style = "margin-left: 20px;"
    ),
    div(
      selectizeInput(
        inputId = "viewProjectsByResearcher",
        label = "Reearcher",
        choices = NULL,
        options = list(
          placeholder = "All",
          onInitialize = I("function() {this.setValue('All');}")
        )
      ),
      style = "margin-left: 20px;"
    ),
    
    
    style = "display: flex; align-items: flex-start;"
  ),
  
  
  # Projects Data
  dataTableOutput("viewProjects", width = 300)
)

