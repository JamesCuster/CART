tabPanel(
  
  "View People",

  # View Researchers --------------------------------------------------------
  tags$h1("View Researchers"),
  
  dataTableOutput("viewResearchers", width = 300),
  
  downloadButton("downloadResearchers", "Download Researchers"),
  
  tags$br(),
  tags$hr(style="border-color: black;"),
  
  
  # View Employees ----------------------------------------------------------
  tags$h1("View BDSH Staff"),
  
  dataTableOutput("viewEmployees", width = 300),
  
  downloadButton("downloadEmployees", "Download Employees"),
  tags$br("")
)