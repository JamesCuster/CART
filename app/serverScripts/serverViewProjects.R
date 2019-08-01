# Inital load of the projects table

output$viewProjects <- 
  renderDataTable({
    datatable(
      projects,
      rownames = FALSE
    )
  })

# update view projects when new data is loaded. Reload is triggered by the
# `refresh` reactiveValues defined in server.r
observeEvent(
  refresh$viewProjects == TRUE, {
    
    # Refresh datatable
    output$viewProjects <- 
      renderDataTable({
        datatable(
          projects,
          rownames = FALSE
        )
      })
    
    # reset the viewProjects reactive
    refresh$viewProjects <- FALSE
  }
)