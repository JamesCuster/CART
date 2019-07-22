library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    # This is a script which will reset the form inputs after it has been submitted
    tags$script("
        Shiny.addCustomMessageHandler('resetValue', function(variableName) {
        Shiny.onInputChange(variableName, null);
        });
      "),
    

    tabsetPanel(
# Add tab panels (add project/time, view (project/time) -------------------
      # Add Project Panel
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/uiPages/addProject.r", 
        local = TRUE)$value,
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/uiPages/addTime.r", 
        local = TRUE)$value,
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/uiPages/viewProjects.r", 
        local = TRUE)$value,
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/uiPages/viewTime.r", 
        local = TRUE)$value
    )
  )
)
