tabPanel(
  
  "View Projects",
  
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
  
  actionButton(
    "removeProject",
    "Delete"
  ),
  
  
  # Filter Projects inputs
  div(
    selectInput(
      inputId = "viewProjectsByStatus",
      label = "Project Status",
      choices = "All",
      selected = "All"
    ),
    div(
      selectizeInput(
        inputId = "viewProjectsByEmployee",
        label = "BDSH Staff",
        choices = "All",
        selected = "All",
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
        choices = "All",
        selected = "All",
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