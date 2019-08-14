tabPanel(
  "View/Edit Raw Data",
  
  h1("Researchers"),
  
  dataTableOutput("editResearchers", width = 300)
  # actionButton(
  #   inputId = "editResearcherTable",
  #   label = "Edit Researcher Table"
  # ),
  # 
  # # Controls whether the editable or static table is displayed
  # conditionalPanel(
  #   condition = "input.editResearcherTable % 2 == 0",
  #   dataTableOutput("viewResearchers", width = 300)
  # ),
  # 
  # conditionalPanel(
  #   condition = "input.editResearcherTable % 2 == 1",
  #   dataTableOutput("editResearchers", width = 300)
  # )
  
)