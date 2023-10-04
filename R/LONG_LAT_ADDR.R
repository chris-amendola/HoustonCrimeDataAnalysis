library(glue)

# Create a unique address to MAP-coords key

raw<-unique(setDT(multi_year)[ year>=2022 & !(is.na(MapLatitude)) & !(is.na(MapLongitude))
                              ,.( MapLongitude
                                 ,MapLatitude
                                 ,StreetNo
                                 ,StreetName
                                 ,StreetType
                                 ,Suffix)])

lat_min<-min(raw$MapLatitude)
lat_max<-max(raw$MapLatitude)
lon_min<-min(raw$MapLongitude)
lon_max<-max(raw$MapLongitude)

lat_range<-lat_max-lat_min
lon_range<-lon_max-lon_min

print(glue('Latitude - MIN:{lat_min} MAX:{lat_max} RANGE:{lat_range}'))
print(glue('Longitude - MIN:{lon_min} MAX:{lon_max} Range:{lon_range}'))