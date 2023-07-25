loc_plot<-function( curr_month
                   ,sup_dir=''
                   ,geo_data=districts){}

data_pre<-multi_year[  (NIBRSDescription %chin% violent_crimes)
                      &(RMSOccurrenceDate>='2023-06-01')
                     ,]%>%
          .[ (!is.na(MapLongitude))
            |(!is.na(MapLatitude))]%>%
      st_as_sf( coords=c("MapLongitude","MapLatitude")
               ,crs=4326
               ,remove=FALSE)  

data<-st_join( data_pre
              ,districts
              ,join = st_within)

data$Address<-paste( data$StreetNo
                    ,' '
                    ,data$StreetName
                    ,' '
                    ,data$StreetType
                    ,' '
                    ,data$Suffix)

data$popup<-paste("<b>Incident #: </b>", data$Incident, "<br>", 
                  "<br>", "<b>Description: </b>", data$NIBRSDescription,
                  "<br>", "<b>Date: </b>", data$RMSOccurrenceDate,
                  "<br>", "<b>Time: </b>", data$RMSOccurrenceHour,
                  "<br>", "<b>Council District: </b>",data$DISTRICT,
                  "<br>", "<b>HPD Beat: </b>", data$Beat,
                  "<br>", "<b>Address: </b>", data$Address,
                  "<br>", "<b>Longitude: </b>", data$MapLongitude,
                  "<br>", "<b>Latitude: </b>", data$MapLatitude)

data%>%leaflet()%>% 
  addTiles()%>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(provider = "Esri.WorldStreetMap",group = "World StreetMap") %>%
  addProviderTiles(provider = "Esri.WorldImagery",group = "World Imagery") %>%
  # addProviderTiles(provider = "NASAGIBS.ViirsEarthAtNight2012",group = "Nighttime Imagery") %>%
  addMarkers( lng = ~MapLongitude
             ,lat = ~MapLatitude
             ,popup=data$popup
             ,clusterOptions=markerClusterOptions()) %>%
  addLayersControl(
    baseGroups = c("OSM (default)","World StreetMap", "World Imagery"),
    options = layersControlOptions(collapsed = FALSE))%>%
  addPolygons( data=districts
              ,fill=T
              ,color="grey"
              ,opacity=1
              ,weight=2) 