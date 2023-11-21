library(gt)

range<-500

#4955 BEECHNUT STREET

location<-multi_year[(  StreetName=='BEECHNUT' 
                            & StreetType=='ST'
                            & StreetNo==4955
                            & year==2023)]

min(location$MapLatitude ,na.rm=TRUE)
max(location$MapLatitude ,na.rm=TRUE)

min(location$MapLongitude ,na.rm=TRUE)
max(location$MapLongitude ,na.rm=TRUE)
#-----------#

#-- Look for nearby --#
# Get long and lat for the address
loci_lat<-mean(location$MapLatitude ,na.rm=TRUE)
loci_lon<-mean(location$MapLongitude ,na.rm=TRUE)
# Set Manual
#-loci_lat<-29.685243003232415
#-loci_lon<- -95.47805340848808

# Get degrees for distance around the location coords
lat_range<-range/111111
lon_range<-(range/111111)#*(cos((loci_lat*3.1415926)/180))
#If your displacements aren't too great (less than a few kilometers) and you're not right at the 
#poles, use the quick and dirty estimate that 111,111 meters (111.111 km) in the y direction is 1 
#degree (of latitude) and 111,111 * cos(latitude) meters in the x direction is 1 degree (of 
#longitude).

#  10 degrees = 10 * pi / 180 radians


box_lon_min<-loci_lon-lon_range
box_lon_max<-loci_lon+lon_range

box_lat_min<-loci_lat-lat_range
box_lat_max<-loci_lat+lat_range


# GET ALL in area
area<-multi_year[(  MapLongitude>=box_lon_min 
                  & MapLongitude<=box_lon_max
                  & MapLatitude>=box_lat_min
                  & MapLatitude<=box_lat_max
                  & year==2023)]

area_sum<-area[,.(OffenseCount=sum(OffenseCount),IncidentCount=.N)
                       ,by=c('NIBRSDescription')]

# Check Locations on a map
plot_map<-area[ (!is.na(MapLongitude))
   |(!is.na(MapLatitude))]%>%
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)

datax<-st_join( plot_map
                ,districts
                ,join = st_within)

geo_plot(datax)

# Tabular Report
area_sum%>%gt()%>%tab_header(
  title=glue('HPD Incident Reports 2023 (January-September)'),
  subtitle=glue('{sum(area_sum$IncidentCount)} Incidents - {sum(area_sum$OffenseCount)} Offenses'))#%>%
  #cols_label( base_chg=md("**ChangeDirection**")
  #            ,Freq=md("**Count**")
  #            ,Count=md("**Offense Count**")) 

#SAVE A CSV
