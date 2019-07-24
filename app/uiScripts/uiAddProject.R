tabPanel(
  "Add Project",
  # fields in the database. Don't think I need projectID, autopopulated in DB
  # textInput("projectID", "projectID"),
  textInput(
    inputId = "projectName", 
    label = "Project Name"
  ),
  
  selectInput(
    inputId = "bdshLead", 
    label = "BDSH Project Lead",
    choices = people$name
  ),

  selectInput(
    inputId = "bdshSecondary", 
    label = "BDSH Project Secondary",
    choices = people$name
  ),
  
  selectInput(
    inputId = "projectPI", 
    label = "Project Primary Investigator",
    choices = researchers$name
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
    inputId = "projectSupport1", 
    label = "Project Support Staff 1"
  ),
  
  textInput(
    inputId = "projectSupport2", 
    label = "Project Support Staff 2"
  ),
  
  textInput(
    inputId = "projectSupport3", 
    label = "Project Support Staff 3"
  ),
  
  textInput(
    inputId = "projectSupport4", 
    label = "Project Support Staff 4"
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
    inputId = "projectStatus", 
    label = "Status of Project",
    choices = c("Active", "Quite", "Inactive", "Complete")
  ),
  
  dateInput(
    inputId = "projectDueDate", 
    label = "Due Date of Project"
  ),
  
  actionButton(
    inputId = "submitAddProject", 
    label = "Add To Queue"
  ),

  tags$br(),
  tags$br(),
  tags$h4("These Projects are in the queue to be added to the database"),
  DT::dataTableOutput("projectFormResponses", width = 300),
  
  # Once data is submitted through the form, this button appears to submit to
  # database
  actionButton(
    inputId = "projectToDatabase", 
    label = "Save To Database")
)