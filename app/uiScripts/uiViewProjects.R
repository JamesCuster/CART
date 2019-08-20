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
  uiOutput("projectFilters"),
  # div(
  #   selectInput(
  #     inputId = "viewProjectsByStatus",
  #     label = "Project Status",
  #     choices = c("All", "Active", "Closed", "Dormant"),
  #     selected = "All"
  #   ),
  #   div(
  #     selectizeInput(
  #       inputId = "viewProjectsByEmployee",
  #       label = "BDSH Staff",
  #       choices = NULL,
  #       selected = "All",
  #       options = list(
  #         placeholder = "All",
  #         onInitialize = I("function() {this.setValue('All');}")
  #       )
  #     ),
  #     style = "margin-left: 20px;"
  #   ),
  #   div(
  #     selectizeInput(
  #       inputId = "viewProjectsByResearcher",
  #       label = "Reearcher",
  #       choices = NULL,
  #       selected = "All",
  #       options = list(
  #         placeholder = "All",
  #         onInitialize = I("function() {this.setValue('All');}")
  #       )
  #     ),
  #     style = "margin-left: 20px;"
  #   ),
  # 
  # 
  #   style = "display: flex; align-items: flex-start;"
  # ),


  # Projects Data
  dataTableOutput("projects", width = 300)
)