tabPanel(
  
  "View Projects",
  
  # Filter Projects inputs

  
  
  fluidRow(
    column(
      3,
      selectInput(
        inputId = "viewProjectStatus", 
        label = "Project Status", 
        choices = c("Active", "Complete", "Inactive",  "Quiet")
      )
    ),
    column(
      3,
      selectInput(
        inputId = "viewProjectPerson", 
        label = "BDSH Staff",
        choices = c("Active", "Complete", "Inactive",  "Quiet")
      )
    )
  ),
  
  # Projects Data
  dataTableOutput("viewProjects", width = 300)
  
)