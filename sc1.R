library(FITfileR)
library(leaflet)
library(dplyr)
library(stringr)
library(trackeR)


#data_f <- readFitFile("Running_2022-02-03T11_50_54.fit")

#e <- records(data_f) %>% 
#  bind_rows() %>% 
#  arrange(timestamp) 

e_df<-df[colSums(!is.na(df)) > 0.9]


e<-readGPX("suuntoapp-Running-2022-02-04T12-33-32Z-track.gpx")

e_df<-e[colSums(!is.na(e)) > 0.1*length(e[,1])]

cols<-colnames(e_df)
lo<-str_detect(colnames(e_df), "long")
la<-str_detect(colnames(e_df), "lat")
ti<-str_detect(colnames(e_df), "time")
di<-str_detect(colnames(e_df), "dist")
coords <- e_df %>% 
  select(cols[lo], cols[la])


m <- coords %>% 
  as.matrix() %>%
  leaflet(  ) %>%
  addTiles() %>%
  addPolylines( )    
m

ti<-str_detect(colnames(e_df), "time")
di<-str_detect(colnames(e_df), "dist")

k<-dim(e_df)[2]
for (i in 1:k){
if (ti[i]==FALSE){
e_df[,i]<-(approxfun(1:length(e_df[,i]),e_df[,i])(1:length(e_df[,i])))

}
}

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



all<-rep(TRUE,length(cols))

sel<-as.logical(all-ti-lo-la)

sel_v<-which(sel)

len<-length(sel_v)

par(mfrow=c(len,1),mar = c(4,4,0.1,0.1))
for (i in sel_v[1:(length(sel_v)-1)]){
plot(e_df[ti],e_df[,i],xlab="",ylab=cols[i],t="l",lwd=2)
}
plot(e_df[ti],e_df[,sel_v[len]],xlab="Time",ylab=cols[sel_v[len]],t="l",lwd=2)


par(mfrow=c(2,ceiling(len/2)),mar = c(0.6,2,2,1))
for (i in sel_v[1:(length(sel_v)-1)]){
boxplot(e_df[,i],main=cols[i],cex.axis=1.2)
}
boxplot(e_df[,sel_v[len]],main=cols[sel_v[len]],cex.axis=1.2)




par(mfrow=c(5,1),mar = c(4,4,0.1,0))

mcad<-mean(na.omit(e$cadence))
mspe<-mean(na.omit(e$speed))*3.6


plot(e$timestamp,e$heart_rate,xlab="",ylab="HR",t="l",lwd=2)
#plot(e$timestamp,e$distance,xlab="",ylab="Dist.",t="l",lwd=2)
plot(e$timestamp,e$altitude,xlab="",ylab="Alt.",t="l",lwd=2)
plot(e$timestamp,e$cadence,xlab="",ylab="Cad.",t="l",lwd=2,ylim=c(mcad-0.1*mcad,mcad+0.1*mcad))
plot(e$timestamp,e$speed*3.6,xlab="",ylab="Speed",t="l",lwd=2,ylim=c(mspe-0.2*mspe,mspe+0.2*mspe))
plot(e$timestamp,e$vertical_speed*3.6,xlab="Time",ylab="Vert. Speed",t="l",lwd=2)

