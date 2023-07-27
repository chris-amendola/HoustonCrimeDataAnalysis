# install the kohonen package
#install.packages("kohonen")

# load the kohonen package
library("kohonen")

crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
                .[ (RMSOccurrenceDate>='2023-06-01')
                  &(RMSOccurrenceDate<='2023-06-30')]%>%
                .[ (!is.na(MapLongitude))
                  |(!is.na(MapLatitude))]

coords<-scale(crimes_filtered[,.(MapLongitude,MapLatitude)])

grid<-somgrid( xdim=5
              ,ydim=5
              ,topo="hexagonal")

model<-som( coords
           ,grid=grid
           ,rlen=100
           ,alpha=c(0.05,0.01))

names(model)
testa<-as.data.frame(model$codes)

clus_coords<-cbind(as.data.frame(model$unit.classif),coords)
combined<-cbind(crimes_filtered,clus_coords)

names(combined)<-make.names( names(combined)
                            ,unique=TRUE)

centers<-combined%>%group_by(`model.unit.classif`)%>%summarize( MapLongitude=mean(MapLongitude)
                                                               ,MapLatitude=mean(MapLatitude))

centers%>%leaflet()%>% 
  addTiles()%>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(provider = "Esri.WorldStreetMap",group = "World StreetMap") %>%
  addProviderTiles(provider = "Esri.WorldImagery",group = "World Imagery") %>%
  # addProviderTiles(provider = "NASAGIBS.ViirsEarthAtNight2012",group = "Nighttime Imagery") %>%
  addCircleMarkers( lng = ~MapLongitude
                    ,lat = ~MapLatitude
                    ,clusterOptions=markerClusterOptions()
                    ,label=~`model.unit.classif`
                    ) %>%
  addLayersControl(
    baseGroups = c("OSM (default)","World StreetMap", "World Imagery"),
    options = layersControlOptions(collapsed = FALSE))%>%
  addPolygons( data=districts
               ,fill=T
               ,color="grey"
               ,opacity=1
               ,weight=2) 

#geo_plot(data=centers)

