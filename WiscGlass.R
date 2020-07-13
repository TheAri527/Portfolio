####################
# Adam Imran       #
# ANLY 503         #
# July 2020        #
####################

####### AI: Code Modified from  Dr. Ami Gates

### AI: import necessary packages #####
library(leaflet)
library(sp)
library(mapproj)
library(maps)
library(mapdata)
library(maptools)
library(htmlwidgets)
library(magrittr)
library(XML)
library(plyr)
library(rgdal)
library(WDI)
library(raster)
library(noncensus)
library(stringr)
library(tidyr)
library(tigris)
library(rgeos)
library(ggplot2)
library(scales)
library(sqldf)
###########################################

## AI: Import and clean the Glass data set ########
Glass = read_csv("Glass.csv")
Glass$Type = as.factor(Glass$Type)
###################################################

## AI: Subset the different Types#########################
Distributor = sqldf("select * from Glass where Type is 'Distributor'")
Manufacturer = sqldf("select * from Glass where Type is 'Manufacturer'")
Plant = sqldf("select * from Glass where Type is 'Plant'")
Service = sqldf("select * from Glass where Type is 'Service Company'")
##########################################################

## AI: Import and clean the education######################
Education = read.csv("Wisc_Education.csv")
Education = Education[,c(1,2,8)]
colnames(Education) <- c("GEOID", "Name", "education")
Education <- as.data.frame(gsub("[[:punct:]]", "", as.matrix(Education)))
summary(Education)
Education$education <- as.numeric(as.character(Education$education))
Education$education = Education$education/100
##########################################################

## AI: Import the tigris states dataset####################
us.map <- tigris::states(cb = TRUE, year = 2019)
###########################################################

## AI: Merge the tigris data with  education #############
EducationMapB <- merge(us.map, Education, by=c("GEOID"))
###########################################################

## AI: Format popup data for leaflet map.##################
popup_dat <- paste0("<strong>County: </strong>",
                    EducationMapB$NAME,
                    "<br><strong>Finishing College (%): </strong>",
                    EducationMapB$education)

popup_Distributor <- paste0("<strong>Name: </strong>",
                     Distributor$Name,
                     "<br><strong>Description: </strong>",
                     Distributor$Description)

popup_Manufacturer <- paste0("<strong>Name: </strong>",
                      Manufacturer$Name,
                      "<br><strong>Description: </strong>",
                      Manufacturer$Description)

popup_Plant <- paste0("<strong>Name: </strong>",
                      Plant$Name,
                      "<br><strong>Description: </strong>",
                      Plant$Description)

popup_Service <- paste0("<strong>Name: </strong>",
                      Service$Name,
                      "<br><strong>Description: </strong>",
                      Service$Description)
###########################################################

## AI: Colorbin ###########################################
pal <- colorBin("magma", reverse = TRUE,domain = 0:55,bins = 12)
###########################################################

## AI: Construct leaflet map ##############################
gmap2 <- leaflet(data = EducationMapB) %>%
  # Base groups
  addTiles() %>%
  addProviderTiles(providers$MtbMap) %>%
  setView(lng = -89.4626, lat = 44.8391, zoom = 6) %>% 
  #AI: Changed the rate value to % graduated college
  addPolygons(fillColor = ~pal(education), 
              fillOpacity = 3, 
              color = "#BDBDC3", 
              weight = 1,
              popup = popup_dat,
              smoothFactor = 0.1,
              #AI: Editeed the group 
              group="College Educated (%)") %>%
  addLegend("bottomleft",pal = pal, values = ~education, title = "% Finished College",opacity = 1) %>%
  addMarkers(data = Distributor, lat=~Latitude, lng = ~Longitude, popup = popup_Distributor, group = "Distributor") %>%
  addMarkers(data = Manufacturer, lat=~Latitude, lng = ~Longitude, popup = popup_Manufacturer, group = "Manufacturer") %>%
  addMarkers(data = Plant, lat=~Latitude, lng = ~Longitude, popup = popup_Plant, group = "Plant") %>%
  addMarkers(data = Service , lat=~Latitude, lng = ~Longitude, popup = popup_Service, group = "Services") %>%
  
  addLayersControl(
    #Base group label
    baseGroups = c("College Educated (%)"),
    
    overlayGroups = c("Distributor", "Manufacturer", "Plant", "Services"),
    
    options = layersControlOptions(collapsed = FALSE)
  )

## AI: Save the map with all values unchecked as default ######
saveWidget(gmap2 %>%
             hideGroup("Distributor") %>%
             hideGroup("Manufacturer") %>%
             hideGroup("Plant") %>%
             hideGroup("Services"), file = "wisc_glass.html")
##############################################################

