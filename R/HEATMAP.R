
library(leaflet.extras)

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

nibrs_heat<-function(data=data,rad=15){
  
  pal <- colorFactor(
    palette = c('orange', 'blue', 'green', 'purple'),
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
  
  data%>%leaflet()%>% 
    addTiles()%>%
    addTiles(group = "OSM (default)") %>%
    addHeatmap( lng=~MapLongitude
               ,lat=~MapLatitude
               #,intensity=~OffenseCount
               ,blur=10
               ,minOpacity=0.05
               ,max=0.5
               ,radius=rad
               ,cellSize=5)%>%
    addPolygons( data=districts
                 ,fill=T
                 ,color="grey"
                 ,opacity=1
                 ,weight=2) 
}
nibrs_heat(datax,rad=7)
nibrs_heat(datax,rad=10)