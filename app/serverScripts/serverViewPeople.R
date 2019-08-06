observe({
  output$viewResearchers <- 
    renderDataTable(
      reactiveData$researchers[, !(names(researchers) %in% c("value", "label"))],
      rownames = FALSE
    )
})


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

observe({
  output$viewEmployees <- 
    renderDataTable(
      reactiveData$employees[, !(names(employees) %in% c("value", "label"))],
      rownames = FALSE
    )
})


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