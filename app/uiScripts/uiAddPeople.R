tabPanel(
  "Add People",
  
  
  # Add Researcher ----------------------------------------------------------
  
  tags$h1("Add New Researcher"),
  
  textInput(
    inputId = "researcherUteid",
    label = "Researcher's UT EID"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "researcherName",
    label = "Researcher's Name"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "researcherEmail",
    label = "Researchers Email"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "primaryDept",
    label = "Primary Department"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
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
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "employeeName",
    label = "BDSH Employee's Name"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "employeeEmail",
    label = "BDSH Employee's Email"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "degree",
    label = "BDSH Employee's Degree" 
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  textInput(
    inputId = "role",
    label = "BDSH Employee's Role"
  ),
  tags$footer("*Required", style="color: red; margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
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