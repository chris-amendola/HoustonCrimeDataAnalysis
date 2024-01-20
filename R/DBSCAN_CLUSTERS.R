library(fpc)
library(dbscan)
library(factoextra)

crimes<-c('Robbery')

crimes_filtered<-multi_year[ (NIBRSDescription %chin% crimes)
                            &(year>2022)
                            ,.(MapLongitude,MapLatitude,NIBRSDescription,year_mon)]%>%
  .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))]

print(table(is.na(crimes_filtered)))

print(round(table(is.na(crimes_filtered))[2]/sum(table(is.na(crimes_filtered)))*100,2))

#Look at vars with missing
summary(crimes_filtered)

library(leaflet)
library(htmlwidgets)
#limits of longitude and lat
lln<-min(crimes_filtered$MapLongitude)
uln<-max(crimes_filtered$MapLongitude)
llat<-min(crimes_filtered$MapLatitude)
ulat<-max(crimes_filtered$MapLatitude)
#Centers of longitude and lats
centlon<-(lln+uln)/2
centlat<-(llat+ulat)/2

sbt<-crimes_filtered
mp<-leaflet(sbt) %>%
  setView(centlon,centlat,zoom = 4) %>%
  addProviderTiles("OpenStreetMap") %>%
  addCircleMarkers(lng = sbt$MapLongitude,
                   lat = sbt$MapLatitude,
                   popup = sbt$NIBRSDescription,
                   fillColor = "Black",
                   fillOpacity = 1,
                   radius = 2,
                   stroke = F)
mp

locs<-crimes_filtered[,.(MapLongitude,MapLatitude)]

#Scale the data points.
locs.scaled<-scale( locs
                   ,center=T
                   ,scale=T)
head(locs.scaled)
## LOOP THIS and optimize?
db<-dbscan( locs.scaled
           ,eps=.13
           ,minPts=40)
db

fviz_cluster( db
             ,locs.scaled
             ,stand=F
             ,ellipse=T
             ,geom = "point")

kNNdistplot( locs.scaled
            ,k=12)

abline( h=.15
       ,lty=2
       ,col=rainbow(1)
       ,main="eps optimal value")