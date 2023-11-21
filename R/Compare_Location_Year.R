library(gt)

range<-2000

location<-multi_year[(  StreetName=='WESTHEIMER' 
                            & StreetType=='RD'
                            & StreetNo==5085 
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
area_base<-multi_year[(  MapLongitude>=box_lon_min 
                       & MapLongitude<=box_lon_max
                       & MapLatitude>=box_lat_min
                       & MapLatitude<=box_lat_max
                       &( RMSOccurrenceDate>=glue('2022-01-01')
                         &RMSOccurrenceDate<=eom(to_dt_month,2022)))]

area_comp<-multi_year[(  MapLongitude>=box_lon_min 
                       & MapLongitude<=box_lon_max
                       & MapLatitude>=box_lat_min
                       & MapLatitude<=box_lat_max
                       &( RMSOccurrenceDate>=glue('2023-01-01')
                         &RMSOccurrenceDate<=eom(to_dt_month,2023)))]


base_sum<-area_base[,.(OffenseCount_Base=sum(OffenseCount),IncidentCount_Base=.N)
                       ,by=c('NIBRSDescription')]

comp_sum<-area_comp[,.(OffenseCount_Comp=sum(OffenseCount),IncidentCount_Comp=.N)
               ,by=c('NIBRSDescription')]

combine<-base_sum[comp_sum,on=c('NIBRSDescription')]

setnafill( combine
          ,cols=c('IncidentCount_Comp','IncidentCount_Base','OffenseCount_Comp','OffenseCount_Base')
          ,fill = 0)

combine$IncidentCount_change<-combine$IncidentCount_Comp-combine$IncidentCount_Base
combine$OffenseCount_change<-combine$OffenseCount_Comp-combine$OffenseCount_Base

print(sum(combine$IncidentCount_change))
print(sum(combine$OffenseCount_change)) 

print(sum(combine$IncidentCount_Base))
print(sum(combine$OffenseCount_Base))

if(1==1){
# Check Locations on a map
plot_map<-area_base[ (!is.na(MapLongitude))
   |(!is.na(MapLatitude))]%>%
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)

datax<-st_join( plot_map
                ,districts
                ,join = st_within)

geo_plot(datax)
}
