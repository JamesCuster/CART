
shinyUI(
  fluidPage(
    
    tags$script("
        Shiny.addCustomMessageHandler('projectID', function(id) {
          Shiny.setInputValue('projectID', id);
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
    
    
    # CSS that adds a border below group headers for grouped choices in
    # selectizeInput headers
    tags$style(HTML(
      ".selectize-dropdown .optgroup-header {
        font-size: 14px;
        font-weight: bold; 
      }
      "
    )),
    
    tags$style(HTML(
      ".input-notes-table {
        margin-top: -13px;
        font-size: 13px;
      }
      
      .input-notes-table td:last-of-type {
        padding-left: 3px;
      }
      "
    )),
    
    # Title
    div(
      tags$h1("CART", style = "font-size: 100px; font-weight: 900; font-family: inherit; font-style: italic; z-index: 1"),
      img(src='gokart2.jpg', style = "height: 79px; margin-bottom: 19px; margin-left: -20px"),
      style = "display: flex; align-items: flex-end;"
    ),


    tabsetPanel(id = "tab",
      # Add tab panels for projects, time, and people ---------------------
      
      # Projects
      source(
        paste0(dirPath, "/app/uiScripts/uiProjects.r"),
        local = TRUE)$value,
      
      # Time
      source(
        paste0(dirPath, "/app/uiScripts/uiTime.r"),
        local = TRUE)$value,
      
      # People
      source(
        paste0(dirPath, "/app/uiScripts/uiPeople.r"), 
        local = TRUE)$value
    )
  )
)
