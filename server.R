options(shiny.maxRequestSize=30*1024^2)


library()


con <- DBI::dbConnect(RPostgres::Postgres(),
                      host   = "postgres",
                      dbname = "shiny",
                      user      = "postgres",
                      password  = "postgres",
                      port     = 5432)


users = DBI::dbReadTable(con, "users")




library(FITfileR)
library(leaflet)
library(dplyr)
library(tools)
library(stringr)
library(openxlsx)
library(trackeR)



server <- function(input, output) {

  credentials <- shinyauthr::loginServer(
    id = "login",
    data = users,
    user_col = username,
    pwd_col = password,
    log_out = reactive(logout_init())
  )

  # Logout to hide
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  output$sidebarpanel <- renderUI({

    # Show only when authenticated
    req(credentials()$user_auth)


    fileInput("file", h3("Data file input"))
    #div(style="display: inline-block;vertical-align:top; width: 33%;", textInput("C","Enter C", "0.1"))
    div(style="display: inline-block;vertical-align:top; width: 16%;",    checkboxInput('kmh','km/h',FALSE),)
    downloadButton("downloadData", "Download")

  })
  output$fileInput <- renderUI({
    req(credentials()$user_auth)
    fileInput("file", h3("Data file input"))
  })

  output$div <- renderUI({
    req(credentials()$user_auth)
    div(style="display: inline-block;vertical-align:top; width: 16%;",    checkboxInput('kmh','km/h',FALSE),)
  })

  # Plot
  output$distPlot <- renderPlot({

    # Show plot only when authenticated
    req(credentials()$user_auth)

    if(!is.null(input$obs)) {
      hist(rnorm(input$obs))
    }

  })





#C <- reactive ({ as.numeric(input$C) })

#constant
coef <- 3.6
  
#output$verb <- renderPrint({ mydata() })

mydata<- reactive({
req(credentials()$user_auth)
x<-req(input$file)
x<-x$name
ext<-strsplit(x, split="\\.")[[1]][length(strsplit(x, split="\\.")[[1]])]

if (tolower(ext)=="fit"){
data_f <- readFitFile(input$file$datapath)

e <- records(data_f) %>% 
  bind_rows() %>% 
  arrange(timestamp) 

e_df<-as.data.frame(e)
} # od fit

if (tolower(ext)=="fit"){
data_f <- readFitFile(input$file$datapath)

e <- records(data_f) %>% 
  bind_rows() %>% 
  arrange(timestamp) 

e_df<-as.data.frame(e)
} # od fit


if (tolower(ext)=="tcx"){
e <- readTCX(input$file$datapath)

e_df<-e[colSums(!is.na(e)) > 0.1*length(e[,1])]

ti<-str_detect(colnames(e_df), "time")
k<-dim(e_df)[2]

for (i in 1:k){
	if (ti[i]==FALSE){
		e_df[,i]<-(approxfun(1:length(e_df[,i]),e_df[,i])(1:length(e_df[,i])))
	}
}
} # od tcx

if (tolower(ext)=="gpx"){
e <- readGPX(input$file$datapath)

e_df<-e[colSums(!is.na(e)) > 0.1*length(e[,1])]

ti<-str_detect(colnames(e_df), "time")
k<-dim(e_df)[2]

for (i in 1:k){
	if (ti[i]==FALSE){
		e_df[,i]<-(approxfun(1:length(e_df[,i]),e_df[,i])(1:length(e_df[,i])))
	}
}
} # od gpx



e_df

}) #mydata



###map
output$mymap <- renderLeaflet({
req(credentials()$user_auth)
e_df<-mydata()

cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")

coords <- e_df %>% 
  select(cols[lo], cols[la])

m <- coords %>% 
  as.matrix() %>%
  leaflet(  ) %>%
  addTiles() %>%
  addPolylines( )    
m


})

output$Fit_plot <- renderPlot({
  req(credentials()$user_auth)
e_df<-mydata()

cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")
ti<-str_detect(colnames(e_df), "time")
sp<-str_detect(colnames(e_df), "speed")
di<-str_detect(colnames(e_df), "dist")

if (sum(sp)==0){
len<-length(e_df[,ti])
speed<-rep(NA,len)
speed[2:len]<-e_df[2:(len),ti]-e_df[1:(len-1),ti]
speed[speed==0]<-NA
speed[2:len]<-e_df[2:(len),di]-e_df[1:(len-1),di]
e_df$speed<-speed
cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")
ti<-str_detect(colnames(e_df), "time")
di<-str_detect(colnames(e_df), "dist")
sp<-str_detect(colnames(e_df), "speed")
di<-str_detect(colnames(e_df), "dist")
}



if (input$kmh==TRUE)
{
e_df[sp]<-e_df[sp]*3.6
}

all<-rep(TRUE,length(cols))
sel<-as.logical(all-ti-lo-la)
sel_v<-which(sel)
len<-length(sel_v)

par(mfrow=c(len,1),mar = c(4,4,0.1,0))
for (i in sel_v[1:(length(sel_v)-1)]){
plot(e_df[ti],e_df[,i],xlab="",ylab=cols[i],t="l",lwd=2,cex.lab=1.4)
}
plot(e_df[ti],e_df[,sel_v[len]],xlab="Time",ylab=cols[sel_v[len]],t="l",lwd=2,cex.lab=1.4)

})

#output$verb <- renderPrint({ summary(mydata()) })

#output$Fit_table <- renderTable({mydata()},digits = 4)


output$Box_plot <- renderPlot({
  req(credentials()$user_auth)
e_df<-mydata()

cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")
ti<-str_detect(colnames(e_df), "time")
sp<-str_detect(colnames(e_df), "speed")
di<-str_detect(colnames(e_df), "dist")

if (sum(sp)==0){
len<-length(e_df[,ti])
speed<-rep(NA,len)
speed[2:len]<-e_df[2:(len),ti]-e_df[1:(len-1),ti]
speed[speed==0]<-NA
speed[2:len]<-e_df[2:(len),di]-e_df[1:(len-1),di]
e_df$speed<-speed
cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")
ti<-str_detect(colnames(e_df), "time")
di<-str_detect(colnames(e_df), "dist")
sp<-str_detect(colnames(e_df), "speed")
di<-str_detect(colnames(e_df), "dist")
}


if (input$kmh==TRUE)
{
e_df[sp]<-e_df[sp]*3.6
}

all<-rep(TRUE,length(cols))
sel<-as.logical(all-ti-lo-la)
sel_v<-which(sel)
len<-length(sel_v)

par(mfrow=c(2,ceiling(len/2)),mar = c(0.6,2,2,1))
for (i in sel_v[1:(length(sel_v)-1)]){
boxplot(e_df[,i],main=cols[i],cex.axis=1.2)
}
boxplot(e_df[,sel_v[len]],main=cols[sel_v[len]],cex.axis=1.2)

})


output$downloadData <- downloadHandler(

    filename = function() {
      paste0(tools::file_path_sans_ext(input$file),".xlsx")
    },

    content = function(file) {
      write.xlsx(mydata(), file)
    }
)


}










