require(shiny)
folder_address = '.'

x <- system("ipconfig", intern=TRUE)
z <- x[grep("IPv4", x)]
ip <- gsub(".*? ([[:digit:]])", "\\1", z)
print(paste0("the Shiny Web application runs on: http://", ip, ":1234/"))

runApp(folder_address, launch.browser=TRUE, port = 1234, host = ip)

output <- renderText({
  # Test if file is selected
  if (!is.null(input$file$datapath)) {
      # Extract file name (additionally remove file extension using sub)
      return(sub(".xlsx$", "", basename(input$file$name)))
  } else {
      return(NULL)
  }
})


ui <- fluidPage(
  titlePanel('CdA'),
   sidebarLayout(
    sidebarPanel(
    
      fileInput("file", h3("Data file input")),
    
	mainPanel(
      plotOutput("CdA_plot",width = "100%", height = "800px"),
      tableOutput("CdA_table")
    )
  )
)