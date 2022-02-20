
library(leaflet)


data_f <- readFitFile("Running_2022-02-03T11_50_54.fit")

e <- records(data_f) %>% 
  bind_rows() %>% 
  arrange(timestamp) 

e

coords <- e %>% 
  select(position_long, position_lat)


m <- coords %>% 
  as.matrix() %>%
  leaflet(  ) %>%
  addTiles() %>%
  addPolylines( )
    
m