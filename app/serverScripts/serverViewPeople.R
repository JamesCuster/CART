output$viewResearchers <- 
  renderDataTable(
    researchers[, !(names(researchers) %in% c("value", "label"))],
    rownames = FALSE
  )

output$downloadResearchers <- downloadHandler(
  filename = function() {
    paste("researchers_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(researchers[, !(names(researchers) %in% c("value", "label"))], 
              file, 
              row.names = FALSE)
  }
)

output$viewEmployees <- 
  renderDataTable(
    employees[, !(names(employees) %in% c("value", "label"))],
    rownames = FALSE
  )

output$downloadEmployees <- downloadHandler(
  filename = function() {
    paste("employees_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(employees[, !(names(employees) %in% c("value", "label"))],
              file,
              row.names = FALSE)
  }
)