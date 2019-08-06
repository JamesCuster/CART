tabPanel(
  # tab title
  "Add Project",
  
  # page title
  tags$h1("Input New Project"),
  
  # fields in the database. Don't think I need projectID, autopopulated in DB
  # textInput("projectID", "projectID"),
  textInput(
    inputId = "projectName", 
    label = "Project Name"
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  selectizeInput(
    inputId = "bdshLead",
    label = "BDSH Lead",
    choices = sort(employees$employeeName),
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  textOutput("test"),
  
  selectizeInput(
    inputId = "bdshSecondary",
    label = "BDSH Secondary",
    choices = sort(employees$employeeName),
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  
  selectizeInput(
    inputId = "projectPI",
    label = "Primary Investigator",
    choices = NULL,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  selectizeInput(
    inputId = "projectSupport1",
    label = "Support Staff 1",
    choices = NULL,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  
  selectizeInput(
    inputId = "projectSupport2",
    label = "Support Staff 2",
    choices = NULL,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  
  selectizeInput(
    inputId = "projectSupport3",
    label = "Support Staff 3",
    choices = NULL,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  
  selectizeInput(
    inputId = "projectSupport4",
    label = "Support Staff 4",
    choices = NULL,
    options = list(
      placeholder = "",
      onInitialize = I("function() {this.setValue('');}")
    )
  ),
  
  # This extra code allows for the text input box size to be customized.
  withTags(
    div(
      h5(
        b("Brief Description")
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
    label = "Status",
    choices = c("Active", "Complete", "Inactive",  "Quiet")
  ),
  tags$footer("*Required", style="margin-top: -16px; font-size: 12px; padding-bottom: 8px;"),
  
  
  dateInput(
    inputId = "projectDueDate", 
    label = "Due Date"
  ),
  
  
  actionButton(
    inputId = "submitAddProject", 
    label = "Add To Queue"
  ),

  tags$br(),
  tags$br(),
  tags$h4("These Projects are in the queue to be added to the database"),
  DT::dataTableOutput("projectFormData", width = 300),
  
  # Once data is submitted through the form, this button appears to submit to
  # database
  actionButton(
    inputId = "projectToDatabase", 
    label = "Save To Database")
)




# button to add new researcher
#   conditionalPanel(
#     condition = "input.projectPI != 'Add Researcher'",
#   
#   actionButton(
#     "submitNewResearcher", 
#     "Input new researcher data"
#   )),
# 
# ui update to happen when add new researcher button is pressed.
#   uiOutput("submitNewResearcher")
