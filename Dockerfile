FROM r-base

RUN R -e "install.packages('FITfileR');install.packages('leaflet');install.packages('dplyr');install.packages('tools');install.packages('stringr');install.packages('openxlsx');install.packages('trackeR');"
RUN R -e "install.packages('shiny');install.packages('shinymanager');"
RUN apt update && apt install libssl-dev gdal-bin proj-bin libgdal-dev libproj-dev -y
RUN R -e "install.packages('shinymanager');install.packages('leaflet');"
RUN R -e "if(!requireNamespace(\"remotes\")) {install.packages(\"remotes\");};remotes::install_github(\"grimbough/FITfileR\");"
WORKDIR /www
COPY . .
CMD R -e "shiny::runApp('/www', 8080, host='0.0.0.0')"