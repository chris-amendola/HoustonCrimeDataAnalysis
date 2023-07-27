parks<-st_read(glue("{support_dir}COH_PARKS_(City_of_Houston).geojson"))%>%
  filter(Name=='MEMORIAL PARK')

incidents<-multi_year[ (NIBRSDescription=='Theft from motor vehicle'),]%>%
    .[RMSOccurrenceDate>='2022-01-01']%>%
    .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))]%>%
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)

mem_incid<-st_join( incidents
                            ,parks
                            ,join=st_within)%>%
  filter(Name=='MEMORIAL PARK')

mem_incid<-setDT(mem_incid)

incid_yrmon<-mem_incid[,.(OffenseCount=sum(OffenseCount)),by=(year_mon)]

incid_yrmon[,.(mon_mean=mean(OffenseCount))]

ggplot( data=incid_yrmon
        ,aes( x=year_mon
              ,y=OffenseCount)
              ) +
  geom_bar(stat='identity')+
  xlab(label='Month (2023)')+
  labs(
    title = "Houston Crime Data Analysis",
    subtitle = "Theft-From Autos - Memorial Park",
    caption = "Caption"
  )

geo_plot(data=mem_incid[as.Date(year_mon)=='2023-01-01'])
geo_plot(data=mem_incid[as.Date(year_mon)=='2023-02-01'])
geo_plot(data=mem_incid[as.Date(year_mon)=='2023-03-01'])
