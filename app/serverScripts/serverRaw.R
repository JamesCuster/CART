# editResearcher <- reactiveData$researchers
# 
# output$editResearchers <- 
#   renderDataTable({
#     datatable(
#       editResearchers,
#       rownames = FALSE,
#       editable = TRUE
#     )
#   })

editResearchers <- eventReactive(
  input$tab == "View/Edit Raw Data", {
    reactiveData$researchers
  }
)

output$editResearchers <- 
  renderDataTable(editResearchers())