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

## AI: Import and clean the Mines data set ################
Mines = read.csv("Mines.csv", header = T)
Mines = Mines[-length(Mines)]
summary(Mines$Type)
summary(Mines)
Mines$Longitude <- as.numeric(as.character(Mines$Longitude))
Mines <- Mines[complete.cases(Mines),]
###########################################################

## AI: Subset the different Metals#########################
Coal = sqldf("select * from Mines where Type is 'Coal'")
Copper = sqldf("select * from Mines where Type is 'Copper'")
Diamond = sqldf("select * from Mines where Type is 'Diamond'")
Gold = sqldf("select * from Mines where Type is 'Gold'")
Iron = sqldf("select * from Mines where Type is 'Iron'")
Lithium = sqldf("select * from Mines where Type is 'Lithium'")
Manganese = sqldf("select * from Mines where Type is 'Manganese'")
###########################################################

## AI: Import and clean the poplation#######################
population = read.csv("nst-est2019-01.csv")
population = population[,c(1,13)]
colnames(population) <- c("NAME", "Population")
population <- as.data.frame(gsub("[[:punct:]]", "", as.matrix(population)))
population$Population <- as.integer(as.character(population$Population))
population$Population <- population$Population/1000000
###########################################################

## AI: Import the tigris states dataset####################
us.map <- tigris::states(cb = TRUE, year = 2019)
###########################################################

## AI: Merge the tigris data with  Population #############
PopulationMapB <- merge(us.map, population, by=c("NAME"))
###########################################################

## AI: Format popup data for leaflet map.##################
popup_dat <- paste0("<strong>State: </strong>",
                    PopulationMapB$NAME,
                    "<br><strong>Population (mills): </strong>",
                    PopulationMapB$Population)

popup_coal <- paste0("<strong>Mine Name: </strong>",
                     Coal$Name,
                     "<br><strong>Mine Type: </strong>",
                     Coal$Type)

popup_copper <- paste0("<strong>Mine Name: </strong>",
                     Copper$Name,
                     "<br><strong>Mine Type: </strong>",
                     Copper$Type)

popup_diamond <- paste0("<strong>Mine Name: </strong>",
                       Diamond$Name,
                       "<br><strong>Mine Type: </strong>",
                       Diamond$Type)

popup_gold <- paste0("<strong>Mine Name: </strong>",
                     Gold$Name,
                     "<br><strong>Mine Type: </strong>",
                     Gold$Type)

popup_iron<- paste0("<strong>Mine Name: </strong>",
                     Iron$Name,
                     "<br><strong>Mine Type: </strong>",
                     Iron$Type)

popup_lithium<- paste0("<strong>Mine Name: </strong>",
                    Lithium$Name,
                    "<br><strong>Mine Type: </strong>",
                    Lithium$Type)

popup_mananese <- paste0("<strong>Mine Name: </strong>",
                         Manganese$Name,
                         "<br><strong>Mine Type: </strong>",
                         Manganese$Type)
###########################################################

## AI: Colorbin ###########################################
pal <- colorBin("RdYlBu", reverse = TRUE,domain = 0:40,bins = 12)
###########################################################

## AI: Construct leaflet map ##############################
gmap2 <- leaflet(data = PopulationMapB) %>%
  # Base groups
  addTiles() %>%
  addProviderTiles(providers$Stamen.Watercolor) %>%
  setView(lng = -105, lat = 40, zoom = 2.5) %>% 
  #AI: Changed the value of population by million
  addPolygons(fillColor = ~pal(Population), 
              fillOpacity = 3, 
              color = "#BDBDC3", 
              weight = 1,
              popup = popup_dat,
              smoothFactor = 0.1,
              #AI: Edited the group 
              group="Population (in Mill)") %>%
  addLegend("bottomleft",pal = pal, values = ~Population, title = "Population (in Mill)",opacity = 1) %>%
  addMarkers(data = Coal, lat=~Latitude, lng = ~Longitude, popup = popup_coal, group = "Coal") %>%
  addMarkers(data = Copper, lat=~Latitude, lng = ~Longitude, popup = popup_copper, group = "Copper") %>%
  addMarkers(data = Diamond, lat=~Latitude, lng = ~Longitude, popup = popup_diamond, group = "Diamond") %>%
  addMarkers(data = Gold, lat=~Latitude, lng = ~Longitude, popup = popup_gold, group = "Gold") %>%
  addMarkers(data = Iron, lat=~Latitude, lng = ~Longitude, popup = popup_iron, group = "Iron") %>%
  addMarkers(data = Lithium, lat=~Latitude, lng = ~Longitude, popup = popup_lithium, group = "Lithium") %>%
  addMarkers(data = Manganese, lat=~Latitude, lng = ~Longitude, popup = popup_mananese, group = "Manganese") %>%
  
  addLayersControl(
    #Base group label
    baseGroups = c("Population (in Mill)"),
    overlayGroups = c("Coal", "Copper", "Diamond", "Gold", "Iron", "Lithium", "Manganese"),
    options = layersControlOptions(collapsed = FALSE)
  )

## AI: Save the map with all values unchecked as default ######
saveWidget(gmap2 %>%
  hideGroup("Coal") %>%
  hideGroup("Copper") %>%
  hideGroup("Diamond") %>%
  hideGroup("Gold") %>%
  hideGroup("Iron") %>%
  hideGroup("Lithium") %>%
  hideGroup("Manganese"), file = "pop_mining.html")
##############################################################