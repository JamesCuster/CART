# 1 View Researchers --------------------------------------------------------

# 1.1 Output - Researchers Datatable ----------------------------------------
# creates the datatable output to view researchers
  output$viewResearchers <- 
    renderDataTable(
      reactiveData$researchers[, !(names(reactiveData$researchers) %in% c("value", "label"))],
      rownames = FALSE
    )


# 1.2 Download Reseachers Table ---------------------------------------------
# handles the actions when Download Researchers button is pressed
output$downloadResearchers <- downloadHandler(
  filename = function() {
    paste("researchers_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(reactiveData$researchers[, !(names(reactiveData$researchers) %in% c("value", "label"))], 
              file, 
              row.names = FALSE)
  }
)



# 2 View Employees ----------------------------------------------------------

# 2.1 Output - Employees Datatable ------------------------------------------
# creates the datatable output to view employees
  output$viewEmployees <- 
    renderDataTable(
      reactiveData$employees[, !(names(reactiveData$employees) %in% c("value", "label"))],
      rownames = FALSE
    )


# 2.2 Download Employees Table ---------------------------------------------
# handles the actions when Download Employees button is pressed
output$downloadEmployees <- downloadHandler(
  filename = function() {
    paste("employees_", Sys.Date(), ".csv", sep = "")
  },
  content = function(file) {
    write.csv(reactiveData$employees[, !(names(reactiveData$employees) %in% c("value", "label"))],
              file,
              row.names = FALSE)
  }
)