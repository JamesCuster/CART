tabPanel(
  "Add People",
  
  #### Add Researcher
  
  tags$h1("Add New Researcher"),
  
  textInput(
    inputId = "uteid",
    label = "Researcher's UT EID"
  ),
  
  textInput(
    inputId = "name",
    label = "Researcher's Name"
  ),
  
  textInput(
    inputId = "email",
    label = "Researchers Email"
  ),
  
  textInput(
    inputId = "primaryDept",
    label = "Primary Department"
  ),
  
  textInput(
    inputId = "secondaryDept",
    label = "Secondary Department"
  ),
  
  
  actionButton(
    inputId = "submitAddResearcher", 
    label = "Add To Queue"
  ),
  
  tags$br(),
  tags$br(),
  tags$h4("Researchers in the queue to be added to the database"),
  DT::dataTableOutput("researcherFormResponses", width = 300),
  
  actionButton(
    inputId = "researcherToDatabase", 
    label = "Save To Database"
  ),
  
  
  ##### Add BDSH employee
  
  tags$hr(style="border-color: black;"),
  tags$br(),
  
  tags$h1("Add New BDSH Staff"),
  
  textInput(
    inputId = "uteid",
    label = "BDSH Employee's UT EID"
  ),
  
  textInput(
    inputId = "name",
    label = "BDSH Employee's Name"
  ),
  
  textInput(
    inputId = "email",
    label = "BDSH Employee's Email"
  ),
  
  textInput(
    inputId = "degree",
    label = "BDSH Employee's" 
  ),
  
  textInput(
    inputId = "role",
    label = "BDSH Employee's Role"
  ),
  
  actionButton(
    inputId = "submitAddBDSH", 
    label = "Add To Queue"
  ),
  
  tags$br(),
  tags$br(),
  tags$h4("BDSH Employees in the queue to be added to the database"),
  DT::dataTableOutput("employeeFormResponses", width = 300),
  
  
  
  actionButton(
    inputId = "bdshToDatabase", 
    label = "Save To Database")
)