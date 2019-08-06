tabPanel(
  
  "View People",
  
  tags$h1("View Researchers"),
  
  dataTableOutput("viewResearchers", width = 300),
  
  tags$br(),
  tags$hr(style="border-color: black;"),
  
  tags$h1("View BDSH Staff"),
  
  dataTableOutput("viewEmployees", width = 300)
)