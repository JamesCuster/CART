
shinyUI(
  fluidPage(
    # This is JavaScript which will reset the form inputs after adding to queue
    tags$script("
        Shiny.addCustomMessageHandler('resetValue', function(variableName) {
        Shiny.onInputChange(variableName, null);
        });
      "),
    

    tabsetPanel(
      # Add tab panels (add project/time, view (project/time) -------------------
      
      # addProject
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/uiScripts/uiAddProject.r", 
        local = TRUE)$value,
      
      # addTime
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/uiScripts/uiAddTime.r", 
        local = TRUE)$value,
      
      # addPeople
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/uiScripts/uiAddPeople.r", 
        local = TRUE)$value,
      
      # viewProjects
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/uiScripts/uiViewProjects.r", 
        local = TRUE)$value,
      
      # viewTime
      source(
        "C:/Users/jmc6538/Desktop/BDSHProjectTracking/app/uiScripts/uiViewTime.r", 
        local = TRUE)$value
    )
  )
)
