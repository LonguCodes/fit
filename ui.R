
library(shinyauthr)
library(shinymanager)
library(shiny)
library(leaflet)


user_base <- data.frame(
  user = c("ankieta"), # mandatory
  password = c("ankieta2021"), # mandatory 
  admin = c(TRUE),
  comment = "Simple and secure authentification mechanism 
  for single ‘Shiny’ applications.",
  stringsAsFactors = FALSE 
)



# Define UI for app that draws a histogram ----
ui <- fluidPage(

  # App title ----
  titlePanel("Fit!"),
  
 

  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    

    # Sidebar panel for inputs ----
    sidebarPanel(

      # logout button
      div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
      
      # login section
      shinyauthr::loginUI(id = "login"),
      
      
      uiOutput('fileInput'),
      uiOutput('div'),
      # Sidebar to show user info after login
      uiOutput("sidebarpanel"), 
      
	  ),
    # Main panel for displaying outputs ----
    mainPanel(

      leafletOutput("mymap",width = "100%", height = "800px"),
	hr(),
      plotOutput("Fit_plot",width = "100%", height = "800px"),
	hr(),
	plotOutput("Box_plot",width = "100%", height = "800px"),
	hr(),
	
	
#	verbatimTextOutput("verb"),
      #tableOutput("Fit_table")

    )
  )
)


#secure ui
#ui <- secure_app(ui)




