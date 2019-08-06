output$viewResearchers <- 
  renderDataTable(
    researchers[, !(names(researchers) %in% c("value", "label"))],
    rownames = FALSE
  )



output$viewEmployees <- 
  renderDataTable(
    employees[, !(names(employees) %in% c("value", "label"))],
    rownames = FALSE
  )