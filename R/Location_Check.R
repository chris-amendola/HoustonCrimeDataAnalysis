library(gt)
setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/October2023')

range<-805

#4955 BEECHNUT STREET 
#4807 Pin Oak Park, Houston, TX 77081
#5331 Beverly Hill St
location_desc<-'Chateaux Dijon Apartments'

location<-multi_year[(  StreetName=='BEVERLY HILL' 
                            & StreetType=='ST'
                            & StreetNo==5331
                            & year==2023)]

min(location$MapLatitude ,na.rm=TRUE)
max(location$MapLatitude ,na.rm=TRUE)

min(location$MapLongitude ,na.rm=TRUE)
max(location$MapLongitude ,na.rm=TRUE)
#-----------#
# Need to convert this to a function
#-- Look for nearby --#
# Get long and lat for the address
loci_lat<-mean(location$MapLatitude ,na.rm=TRUE)
loci_lon<-mean(location$MapLongitude ,na.rm=TRUE)
# Set Manual
# Greens Point Mall
# 29.94626, -95.41173
# Galleria Mall
# 29.740042315395527, -95.46427358096552
#-------#
# 29.xxxx
#loci_lat<-29.740042315395527
# -95.xxxx
#loci_lon<--95.46427358096552

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
area_sum[order(-IncidentCount)]%>%gt()%>%tab_header(
  title=html(glue("HPD Incident Reports 2023 (January-October)<br>{location_desc} (Square Mile)")),
  subtitle=glue('{sum(area_sum$IncidentCount)} Incidents - {sum(area_sum$OffenseCount)} Offenses'))%>%
  gtsave("ADDR_REPORT.png", expand = 10)
