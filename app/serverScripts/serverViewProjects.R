

output$viewProjects <- 
  renderDataTable({
    datatable(
      projects,
      rownames = FALSE
    )
  })

