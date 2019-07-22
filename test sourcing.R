tabPanel(
  "View Projects",
  textInput(
    "projectID", 
    "Select the project to add time to"
  ),
  
  textInput(
    "worker", 
    "UTEID"
  ),
  
  dateInput(
    "dateOfWork", 
    "Date that this work was completed"
  ),
  
  dateInput(
    "dateOfEntry", 
    "Date work was logged"
  ),
  
  textInput(
    "workTime", 
    "Time spend in hours (as number with decimals"
  ),
  
  textInput(
    "workDescription", 
    "Brief description of work completed"
  ),
  
  actionButton(
    "submitAddProject", 
    "Submit"
  )
)
