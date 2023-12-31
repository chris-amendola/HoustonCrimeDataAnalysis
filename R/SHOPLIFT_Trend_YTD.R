crimes_filtered<-multi_year[NIBRSDescription=='Shoplifting']

icrime<-'Shoplifting'

NIBRS_Trend(indata=crimes_filtered,'Shoplifting')
NIBRS_YTD(indata=crimes_filtered,'Shoplifting')

#Premise Eval Latest Year
prem<-crimes_filtered[year=='2022',.(Freq=sum(OffenseCount)),by=Premise]
prem_plot<-ggplot( data=prem
                   ,aes( y=Freq
                         ,x=Premise
                   ))+
  geom_bar( position="dodge"
            ,stat="identity")+
  scale_x_discrete(guide = guide_axis(angle=90))+
  ggtitle(glue("{icrime}: Premise Distribution"))
print(prem_plot)

#Time Plot
hour<-crimes_filtered[year=='2022',.(Freq=sum(OffenseCount)),by=RMSOccurrenceHour]
hour_plot<-ggplot( data=hour
                   ,aes( y=Freq
                        ,x=RMSOccurrenceHour
                   ))+
  geom_bar( position="dodge"
           ,stat="identity")+
  scale_x_continuous(n.breaks=25) +
  ggtitle(glue("{icrime}: Hour Distribution"))
print(hour_plot)

## Mapping by Month
cur_year<-'2022'
ytd_months<-c('01','02','03','04','05','06','07','08','09','10','11','12')

for (imonth in ytd_months) {
  print(imonth)
  data_pre<-multi_year[ (NIBRSDescription=='Shoplifting')
                        &(RMSOccurrenceDate>=glue('2022-{imonth}-01'))
                        &(RMSOccurrenceDate<=eom(imonth,cur_year)),]%>%
    .[ (!is.na(MapLongitude))
       |(!is.na(MapLatitude))]%>%
    st_as_sf( coords=c("MapLongitude","MapLatitude")
              ,crs=4326
              ,remove=FALSE)
  
  datax<-st_join( data_pre
                  ,districts
                  ,join = st_within)
  saveWidget( geo_plot(datax)
              ,selfcontained=TRUE  
              ,file=glue('Shoplift_Map_{imonth}.html')
              ,title=glue('Shoplift_Map_{imonth}'))
}

dd_agg<-crimes_filtered[year==2022,.(FREQ=sum(OffenseCount))
                   ,by=c( 'StreetNo'
                          ,'StreetName'
                          ,'StreetType'
                          ,'year'
                          ,'Premise')]

print('Offense Count: ')
print(sum(dd_agg$FREQ))
print('Distinct Addresses:')
nrow(dd_agg)