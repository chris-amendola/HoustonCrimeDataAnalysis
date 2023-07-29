pre_test<-function(){

  data_pre<-multi_year[  (NIBRSDescription %chin% violent_crimes)
                        &(RMSOccurrenceDate>='2023-06-01')
                       ,]%>%
            .[ (!is.na(MapLongitude))
              |(!is.na(MapLatitude))]%>%
        st_as_sf( coords=c("MapLongitude","MapLatitude")
                 ,crs=4326
                 ,remove=FALSE)
  
  datax<-st_join( data_pre
                 ,districts
                 ,join = st_within)
}
#pre_test()

geo_plot<-function(data=data){
  
  pal <- colorFactor(
    palette = c('darkred', 'blue', 'darkgreen', 'purple'),
    domain = data$NIBRSDescription
  )
  
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
  
  lmap<-data%>%leaflet()%>% 
    addTiles()%>%
    addTiles(group = "OSM (default)") %>%
    addProviderTiles(provider = "Esri.WorldStreetMap",group = "World StreetMap") %>%
    addProviderTiles(provider = "Esri.WorldImagery",group = "World Imagery") %>%
    # addProviderTiles(provider = "NASAGIBS.ViirsEarthAtNight2012",group = "Nighttime Imagery") %>%
    addPolygons( data=districts
                 ,fill=T
                 ,color="grey"
                 ,opacity=1
                 ,weight=2)%>%
    addCircleMarkers( lng = ~MapLongitude
                     ,lat = ~MapLatitude
                     ,popup=~popup
                     ,color=~pal(NIBRSDescription)
                     ,radius=5
                     #,clusterOptions=markerClusterOptions()
                     ) %>%
    addLayersControl(
      baseGroups = c("OSM (default)","World StreetMap", "World Imagery"),
      options = layersControlOptions(collapsed = FALSE))%>%
    addLegend( "bottomright"
              ,pal=pal
              ,values=~NIBRSDescription,
              title = "Incident Type",
              opacity = 1
    )
  return(lmap)
    
}
#geo_plot(datax)