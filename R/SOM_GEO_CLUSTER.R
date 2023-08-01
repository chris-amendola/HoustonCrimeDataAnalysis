# install the kohonen package
#install.packages("kohonen")

# load the kohonen package
library("kohonen")
library('RColorBrewer')
set.seed(3141) 


crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
                .[ (RMSOccurrenceDate>='2023-06-01')
                  &(RMSOccurrenceDate<='2023-06-30')]%>%
                .[ (!is.na(MapLongitude))
                  |(!is.na(MapLatitude))]

coords<-scale(crimes_filtered[,.(MapLongitude,MapLatitude)])

grid<-somgrid( xdim=4
              ,ydim=4
              ,topo="hexagonal")

model<-som( coords
           ,grid=grid
           ,rlen=100
           ,alpha=c(0.05,0.01))

names(model)
testa<-as.data.frame(model$codes)

clus_coords<-cbind(as.data.frame(model$unit.classif),coords)
combined<-cbind(crimes_filtered,clus_coords)
# make palette
colorcount=25
getPalette=colorRampPalette(brewer.pal(9,'Set1'))
circ_pal<-colorFactor( palette=getPalette(16)
                       ,domain=combined$model.unit.classif)

names(combined)<-make.names( names(combined)
                            ,unique=TRUE)

centers<-combined%>%
         group_by(`model.unit.classif`)%>%
         summarize( MapLongitude=mean(MapLongitude)
                   ,MapLatitude=mean(MapLatitude)
                   ,N=sum(OffenseCount))

centers$label<-paste("<b>Cluster #: </b>", centers$model.unit.classif, "<br>", 
                     "<br>", "<b>N: </b>", centers$N,
                     "<br>", "<b>Longitude: </b>", centers$MapLongitude,
                     "<br>", "<b>Latitude: </b>", centers$MapLatitude)

centers%>%leaflet()%>% 
  addTiles()%>%
  addTiles(group="OSM (default)") %>%
  addProviderTiles( provider="Esri.WorldStreetMap"
                   ,group = "World StreetMap") %>%
  addProviderTiles( provider="Esri.WorldImagery"
                   ,group="World Imagery") %>%
  addPolygons( data=districts
               ,fill=T
               ,color="grey"
               ,opacity=1
               ,weight=2)%>% 
  addMarkers( lng = ~MapLongitude 
                    ,lat=~MapLatitude
                    ,popup=~label
                    ) %>%
  addCircleMarkers( data=combined
                   ,lng = ~MapLongitude 
                   ,lat=~MapLatitude
                   ,color=~circ_pal(model.unit.classif)
                   ,radius=5
                   ,)%>%
  addLayersControl(
    baseGroups = c( "OSM (default)"
                  ,"World StreetMap"
                  ,"World Imagery"),
    options = layersControlOptions(collapsed = FALSE))

