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

editResearchers <- reactive({
    reactiveData$researchers
  }
)

output$editResearchers <- 
  renderDataTable(
    datatable(
      editResearchers(),
      selection = "single"
    )
  )