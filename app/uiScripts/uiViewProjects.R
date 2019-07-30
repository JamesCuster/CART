tabPanel(
  
  "View Projects",
  
  # Filter Projects inputs
  fluidRow(
    box(
      width = 12, 
      title = "Filter Projects By",
      splitLayout(
        selectInput(
          inputId = "viewProjectStatus", 
          label = "Project Status", 
          choices = c("Active", "Complete", "Inactive",  "Quiet")
        ),
        selectInput(
          inputId = "viewProjectPerson", 
          label = "BDSH Staff",
          choices = c("Active", "Complete", "Inactive",  "Quiet")
        )
      )
    )
  ),
  
  # Projects Data
  dataTableOutput("viewProjects", width = 300)
  
)