
#credentials <- data.frame(
#  user = c("ankieta"), # mandatory
#  password = c("ankieta2021"), # mandatory
#  admin = c(TRUE),
#  comment = "Simple and secure authentification mechanism
#  for single ‘Shiny’ applications.",
#  stringsAsFactors = FALSE
#)

library(FITfileR)
library(leaflet)
library(dplyr)
library(tools)
library(stringr)
library(openxlsx)

server <- function(input, output) {

#C <- reactive ({ as.numeric(input$C) })  

#constant
coef <- 3.6
  
#output$verb <- renderPrint({ mydata() })

mydata<- reactive({
x<-req(input$file)

data_f <- readFitFile("Running_2022-02-03T11_50_54.fit")

e <- records(data_f) %>% 
  bind_rows() %>% 
  arrange(timestamp) 

e_df<-as.data.frame(e)

e_df

}) #mydata

output$Fit_plot <- renderPlot({

e_df<-mydata()

cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")
ti<-str_detect(colnames(e_df), "time")

#if (input$kmh==TRUE)

all<-rep(TRUE,length(cols))
sel<-as.logical(all-ti-lo-la)
sel_v<-which(sel)
len<-length(sel_v)

par(mfrow=c(len,1),mar = c(4,4,0.1,0))
for (i in sel_v[1:(length(sel_v)-1)]){
plot(e_df[ti],e_df[,i],xlab="",ylab=cols[i],t="l",lwd=2)
}
plot(e_df[ti],e_df[,sel_v[len]],xlab="Time",ylab=cols[sel_v[len]],t="l",lwd=2)




})

#output$verb <- renderPrint({ mydata() })

#output$Fit_table <- renderTable({mydata()},digits = 4)


output$downloadData <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$file),".xlsx")
    },

    content = function(file) {
      write.xlsx(mydata(), file)
    }
)


}












