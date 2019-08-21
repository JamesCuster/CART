
shinyUI(
  fluidPage(
    # This is JavaScript which will reset the form inputs after adding to queue
    # used in each of the Add To Queue observeEvent
    tags$script("
        Shiny.addCustomMessageHandler('resetValue', function(variableName) {
        Shiny.onInputChange(variableName, null);
        });
      "),
    
    # initializes the shinyjs package
    useShinyjs(),
    
    # CSS for the viewProjects modals
    tags$style(HTML("
      .modalVariableNames {
        font-size: 15px;
        font-weight: bold;
      }
    
    .modalVariableContent {
        margin-bottom: 10px;
      }
    ")),
    
    
    # CSS used to control search and "show X entries" in datatables
    tags$style(HTML(
      ".top {
        display: flex;
        justify-content: space-between;
        width: 800px;
      }
      
      .dataTables_wrapper
      .dataTables_filter {
        float: none;
      }
      
      .dataTables_wrapper
      .dataTables_length {
        float: none;
      }
      
      .bottom{
        width: 500px;
      }"
    )),

    
    # Title
    div(
      tags$h1("C", style = "font-size: 72px; font-weight: 900; font-family: inherit;"),
      tags$h6("uster", style = "font-size: 10px; margin-bottom: 20px; margin-left: -6px;"),
      tags$h1("A", style = "font-size: 72px; font-weight: 900; font-family: inherit;"),
      tags$h6("ctive", style = "font-size: 10px; margin-bottom: 20px;"),
      tags$h1("R", style = "font-size: 72px; font-weight: 900; font-family: inherit; margin-left: -3px;"),
      tags$h6("esource", style = "font-size: 10px; margin-bottom: 20px;"),
      tags$h1("T", style = "font-size: 72px; font-weight: 900; font-family: inherit; margin-left: -16px;"),
      tags$h6("racker", style = "font-size: 10px; margin-bottom: 20px; margin-left: -16px;"),
      style = "display: flex; align-items: flex-end;"
    ),

    # div(
    #   tags$h1("C", style = "font-size: 72px; font-weight: 900; font-family: inherit;"),
    #   tags$h6("uster", style = "font-size: 10px; margin-bottom: 20px; margin-left: -6px;"),
    #   tags$h1("R", style = "font-size: 72px; font-weight: 900; font-family: inherit; margin-left: -3px;"),
    #   tags$h6("esource", style = "font-size: 10px; margin-bottom: 20px;"),
    #   tags$h1("A", style = "font-size: 72px; font-weight: 900; font-family: inherit;"),
    #   tags$h6("ctivity", style = "font-size: 10px; margin-bottom: 20px;"),
    #   tags$h1("P", style = "font-size: 72px; font-weight: 900; font-family: inherit; margin-left: -16px;"),
    #   tags$h6("rogress", style = "font-size: 10px; margin-bottom: 20px; margin-left: -16px;"),
    #   style = "display: flex; align-items: flex-end;"
    # ),


    tabsetPanel(id = "tab",
      
      # Add tab panels (add project/time, view (project/time) -------------------
      
      # # addProject
      # source(
      #   paste0(dirPath, "/app/uiScripts/uiAddProject.r"), 
      #   local = TRUE)$value,
      # 
      # addTime
      source(
        paste0(dirPath, "/app/uiScripts/uiTime.r"),
        local = TRUE)$value,

      # viewProjects
      source(
        paste0(dirPath, "/app/uiScripts/uiProjects.r"),
        local = TRUE)$value,
      
      # addPeople
      source(
        paste0(dirPath, "/app/uiScripts/uiPeople.r"), 
        local = TRUE)$value#,
      
      # # viewTime
      # source(
      #   paste0(dirPath, "/app/uiScripts/uiViewTime.r"), 
      #   local = TRUE)$value,
      # 
      # # viewPeople
      # source(
      #   paste0(dirPath, "/app/uiScripts/uiViewPeople.r"), 
      #   local = TRUE)$value
    )
  )
)
