library(FITfileR)
library(leaflet)
library(dplyr)

data_f <- readFitFile("Running_2022-02-03T11_50_54.fit")

e <- records(data_f) %>% 
  bind_rows() %>% 
  arrange(timestamp) 

e_df<-as.data.frame(e)

coords <- e %>% 
  select(position_long, position_lat)


m <- coords %>% 
  as.matrix() %>%
  leaflet(  ) %>%
  addTiles() %>%
  addPolylines( )
    
m




par(mfrow=c(5,1),mar = c(4,4,0.1,0))

mcad<-mean(na.omit(e$cadence))
mspe<-mean(na.omit(e$speed))*3.6


plot(e$timestamp,e$heart_rate,xlab="",ylab="HR",t="l",lwd=2)
#plot(e$timestamp,e$distance,xlab="",ylab="Dist.",t="l",lwd=2)
plot(e$timestamp,e$altitude,xlab="",ylab="Alt.",t="l",lwd=2)
plot(e$timestamp,e$cadence,xlab="",ylab="Cad.",t="l",lwd=2,ylim=c(mcad-0.1*mcad,mcad+0.1*mcad))
plot(e$timestamp,e$speed*3.6,xlab="",ylab="Speed",t="l",lwd=2,ylim=c(mspe-0.2*mspe,mspe+0.2*mspe))
plot(e$timestamp,e$vertical_speed*3.6,xlab="Time",ylab="Vert. Speed",t="l",lwd=2)

