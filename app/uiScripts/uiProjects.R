tabPanel(
  
  "Projects",
  
  tags$h1("Projects"),
  
  # Buttons to modify the Researchers table
  actionButton(
    "addProject",
    "Add"
  ),
  
  actionButton(
    "editProject",
    "Edit"
  ),
  
  # Filter Projects inputs
  uiOutput("projectFilters"),

  # Projects Data
  dataTableOutput("projects", width = 300)
)