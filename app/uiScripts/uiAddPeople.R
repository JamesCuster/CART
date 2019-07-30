tabPanel(
  "Add People",
  
  
  # Add Researcher ----------------------------------------------------------
  
  tags$h1("Add New Researcher"),
  
  textInput(
    inputId = "researcherUteid",
    label = "Researcher's UT EID"
  ),
  
  textInput(
    inputId = "researcherName",
    label = "Researcher's Name"
  ),
  
  textInput(
    inputId = "researcherEmail",
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
  DT::dataTableOutput("researcherFormData", width = 300),
  
  actionButton(
    inputId = "researcherToDatabase", 
    label = "Save To Database"
  ),
  
  

  # Add BDSH employee  ------------------------------------------------------
  
  tags$hr(style="border-color: black;"),
  tags$br(),
  
  tags$h1("Add New BDSH Staff"),
  
  textInput(
    inputId = "employeeUteid",
    label = "BDSH Employee's UT EID"
  ),
  
  textInput(
    inputId = "employeeName",
    label = "BDSH Employee's Name"
  ),
  
  textInput(
    inputId = "employeeEmail",
    label = "BDSH Employee's Email"
  ),
  
  textInput(
    inputId = "degree",
    label = "BDSH Employee's Degree" 
  ),
  
  textInput(
    inputId = "role",
    label = "BDSH Employee's Role"
  ),
  
  actionButton(
    inputId = "submitAddEmployee", 
    label = "Add To Queue"
  ),
  
  tags$br(),
  tags$br(),
  tags$h4("BDSH Employees in the queue to be added to the database"),
  DT::dataTableOutput("employeeFormData", width = 300),
  
  
  
  actionButton(
    inputId = "employeeToDatabase", 
    label = "Save To Database")
)