tabPanel(
  "Add Project",
  # fields in the database. Don't think I need projectID, autopopulated in DB
  # textInput("projectID", "projectID"),
  textInput(
    "projectName", 
    "Name of Project"
  ),
  
  selectInput(
    "bdshLead", 
    "BDSH Project Lead",
    people$name
  ),

  selectInput(
    "bdshSecondary", 
    "BDSH Project Secondary",
    people$name
  ),
  
  selectInput(
    "projectPI", 
    "Project Primary Investigator",
    researchers$name
  ),
  
# # button to add new researcher
#   conditionalPanel(
#     condition = "input.projectPI != 'Add Researcher'",
#   
#   actionButton(
#     "submitNewResearcher", 
#     "Input new researcher data"
#   )),
# 
# # ui update to happen when add new researcher button is pressed.
#   uiOutput("submitNewResearcher"),
  
  textInput(
    "projectPIEmail", 
    "Primary Investigators Email"
  ),
  
  textInput(
    "projectSupport1", 
    "Project Support Staff 1"
  ),
  
  textInput(
    "projectSupport1Email", 
    "Project Support Staff 1 - Email"
  ),
  
  textInput(
    "projectSupport2", 
    "Project Support Staff 2"
  ),
  
  textInput(
    "projectSupport2Email", 
    "Project Support Staff 2 - Email"
  ),
  
  textInput(
    "projectSupport3", 
    "Project Support Staff 3"
  ),
  
  textInput(
    "projectSupport3Email", 
    "Project Support Staff 3 - Email"
  ),
  
  textInput(
    "projectSupport4", 
    "Project Support Staff 4"
  ),
  
  textInput(
    "projectSupport4Email", 
    "Project Support Staff 4 - Email"
  ),

# This extra code allows for the text input box size to be customized.
  withTags(
    div(
      h5(
        b("Brief Description of Project")
      ),
      
      textarea(
        id = "projectDescription", 
        class = "form-control shiny-bound-input",
        style = "width: 300px; height: 102px"
      )
    )
  ),
  
  selectInput(
    "projectStatus", 
    "Status of Project",
    c("Active", "Quite", "Inactive", "Complete")
  ),
  
  dateInput(
    "projectDueDate", 
    "Due Date of Project"
  ),
  
  actionButton(
    "submitAddProject", 
    "Submit"
  ),

  tags$br(),
  tags$br(),
  tags$h4("These Projects are in the queue to be added to the database"),
  DT::dataTableOutput("projectFormResponses", width = 300),
  
  # Once data is submitted through the form, this button appears to submit to
  # database
  uiOutput("projectToDatabase")
)