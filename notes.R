
# playing with datatable preserving location on reload --------------------


# **1.2 Projects Datatable --------------------------------------------------
output$projects <- renderDataTable({
  browser()
  req(filterViewProjects())
  displayTable <- filterViewProjects()
  # if (is.null(projectRowSelected)) {
  #   startPage <- 0
  # } else {
  #   rowReverse <- nrow(displayTable) - projectRowSelected
  #   startPage <- rowReverse %/% 10
  # # # }
  startPage <- ifelse(is.null(startPage), 0,
                      (startPage %/% 10) * 10)
  datatable(
    displayTable[, viewProjectsDisplay],
    selection = list(
      mode = 'single',
      selected = projectRowSelected
    ), 
    rownames = FALSE,
    escape = FALSE,
    options = list(
      dom = '<"top"fl> t <"bottom"ip>',
      # order = list(1, 'desc'),
      displayStart = startPage
    )
  )},
  server=TRUE)


# **2.2.2 Edit Project ------------------------------------------------------
# this object is used to preserve the row selected. It is assinged once a row is
# selected and the edit button is pressed. It is used in the renderDataTable
# call
projectRowSelected <- NULL
startPage <- NULL
observeEvent(input[["projects_rows_selected"]] | input[["projects_rows_current"]], {
  projectRowSelected <<- input[["projects_rows_selected"]]
  startPage <<- input$projects_rows_current[1]
})


# **4.2.2 Filter Projects Reactive ------------------------------------------
  # This was modified to change where the datatable sorting occurs. Happens in
  # this reactive versus in the data.table

# Reactive to filter projects data based on viewProjectsByStatus,
# viewProjectsByEmployee, and viewProjectsByResearcher
filterViewProjects <-
  reactive({
    # If reactiveData$viewProjects has not been created yet, this allows the
    # reactive to be skipped
    if (is.null(reactiveData$viewProjects)) {
      return()
    }
    if (!(is.null(input$viewProjectsByStatus) ||
          is.null(input$viewProjectsByEmployee) ||
          is.null(input$viewProjectsByResearcher))) {
      
      filtered <- reactiveData$viewProjects %>%
        # Status filter
        {if (input$viewProjectsByStatus != "All") {
          filter(., projectStatus == input$viewProjectsByStatus)
        }
          else {.}
        } %>%
        # Employee filter
        {if (input$viewProjectsByEmployee != "All") {
          filter(.,
                 bdshLead == input$viewProjectsByEmployee |
                   bdshSecondary == input$viewProjectsByEmployee)
        }
          else {.}
        } %>%
        # Researcher filter
        {if (input$viewProjectsByResearcher != "All") {
          filter(., projectPI == input$viewProjectsByResearcher |
                   projectSupport1 == input$viewProjectsByResearcher |
                   projectSupport2 == input$viewProjectsByResearcher |
                   projectSupport3 == input$viewProjectsByResearcher |
                   projectSupport4 == input$viewProjectsByResearcher)
        }
          else {.}}
      
      # add View Details link
      filtered <- addViewDetails(filtered, "viewProjects")
      filtered <- arrange(filtered, desc(projectID))
      return(filtered)
    }
    else {
      # add View Details link
      filtered <- addViewDetails(reactiveData$viewProjects, "viewProjects")
      filtered <- arrange(filtered, desc(projectID))
      return(filtered)
    }
  })



# How to add notes below an input ----------------------------------------------
# Add extra text to projectFunded input 
fields$projectFunded$children <- 
  list(fields$projectFunded$children,
       div("If this project was unfunded and became funded, do not 
                   change this field to funded as this would change all unfunded 
                   time entered to funded time. If you need to track funded time 
                   for this project, please create a new project entry in CART. 
                   If you just need to indicate that the project became funded, 
                   please do so in the Project Status below.",
           style = "margin-top: -15px;"))