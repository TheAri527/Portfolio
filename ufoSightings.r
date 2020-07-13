####################
## Adam Imran      #
## ANLY 503        #
## July 2020       #
####################

## AI: Inspiration sought from documentation: https://rstudio.github.io/leaflet/morefeatures.html

### AI: import necessary packages #####
library(tigris)
library(leaflet)
library(htmlwidgets)
########################################

## AI: Import data and clean ############################
ufo = read.csv("UFO_complete.csv")
summary(ufo$longitude)
ufo$latitude <- as.numeric(as.character(ufo$latitude))
ufo <- ufo[complete.cases(ufo),]
#########################################################

## AI: Format popup data for leaflet map.################
popup_UFO <- paste0("<strong>Date: </strong>",
                        ufo$datetime,
                        "<br><strong>City: </strong>",
                        ufo$city,
                        "<br><strong>Shape: </strong>",
                        ufo$shape)
#########################################################

## AI: Construct leaflet map ############################
gmap2 <- leaflet() %>% addTiles() %>%
  addMarkers(data=ufo,
             popup = popup_UFO,
             clusterOptions = markerClusterOptions(),
             clusterId = "UfoCluster") %>%
  setView(lat = 20, lng = 0, zoom = 1) %>%
  addEasyButton(easyButton(
    states = list(
      easyButtonState(
        stateName="unfrozen-markers",
        icon="ion-toggle",
        title="Freeze Clusters",
        onClick = JS("
          function(btn, map) {
            var clusterManager =
              map.layerManager.getLayer('cluster', 'quakesCluster');
            clusterManager.freezeAtZoom();
            btn.state('frozen-markers');
          }")
      ),
      easyButtonState(
        stateName="frozen-markers",
        icon="ion-toggle-filled",
        title="UnFreeze Clusters",
        onClick = JS("
          function(btn, map) {
            var clusterManager =
              map.layerManager.getLayer('cluster', 'quakesCluster');
            clusterManager.unfreeze();
            btn.state('unfrozen-markers');
          }")
      )
    )
  ))
#########################################################

## AI: Save the map with all values unchecked as default ####
saveWidget(gmap2, file = "ufosightings.html")
##############################################################