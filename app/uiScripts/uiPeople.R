tabPanel(
  "Add People",
  
  # Add Researcher ----------------------------------------------------------
  
  tags$h1("Researchers"),
  
  # Buttons to modify the Researchers table
  actionButton(
    "addResearcher",
    "Add"
  ),
  
  actionButton(
    "editResearcher",
    "Edit"
  ),
  
  tags$br(),
  tags$br(),
  
  dataTableOutput("researchers", width = 300),
  
  downloadButton("downloadResearchers", "Download Researchers"),
  
  
  
  # Add BDSH employee  ------------------------------------------------------
  
  tags$hr(style="border-color: black;"),
  tags$br(),
  
  tags$h1("BDSH Staff"),
  
  # Buttons to modify the Researchers table
  actionButton(
    "addEmployee",
    "Add"
  ),
  
  actionButton(
    "editEmployee",
    "Edit"
  ),
  
  tags$br(),
  tags$br(),
  
  dataTableOutput("employees"),
  
  downloadButton("downloadEmployees", "Download Employees")
)