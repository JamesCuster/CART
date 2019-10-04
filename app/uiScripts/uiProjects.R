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
    # Choices updated in serverProject.R
  div(
    selectizeInput(
      inputId = "viewProjectsByStatus",
      label = "Project Status",
      choices = "All"
    ),
    div(
      selectizeInput(
        inputId = "viewProjectsByEmployee",
        label = "BDSH Staff",
        choices = "All"
      ),
      style = "margin-left: 20px;"
    ),
    div(
      selectizeInput(
        inputId = "viewProjectsByResearcher",
        label = "Reearcher",
        choices = "All"
      ),
      style = "margin-left: 20px;"
    ),
    style = "display: flex; align-items: flex-start;"
  ),

  # Projects Data
  dataTableOutput("projects"),
  
  # Download Project Data
  actionButton(
    "downloadProjectData",
    "Download Projects"
  )
)