library(ggrepel)
z_poi<-function(current,historical){
  
  return(2*(sqrt(current)-sqrt(historical)))
  
}

crimes_filtered<-multi_year[NIBRSDescription=='Shoplifting']

icrime<-'Shoplifting'

NIBRS_Trend(indata=crimes_filtered,'Shoplifting')
NIBRS_YTD(indata=crimes_filtered,'Shoplifting',latest_mon='10')

z_poi(10135,8702)

#Premise Eval Latest Years
prem22<-crimes_filtered[ year=='2022'
                        ,.(Freq22=sum(OffenseCount))
                        ,by=Premise]
prem22$prop22<-prem22$Freq22/sum(prem22$Freq22)

prem_plot22<-ggplot( data=prem22
                   ,aes( y=prop22
                         ,x=Premise
                   ))+
  geom_bar( position="dodge"
            ,stat="identity")+
  scale_x_discrete(guide = guide_axis(angle=90))+
  ggtitle(glue("{icrime} 2022: Premise Distribution"))
print(prem_plot22)

prem23<-crimes_filtered[ year=='2023'
                        ,.(Freq23=sum(OffenseCount))
                        ,by=Premise]
prem23$prop23<-prem23$Freq23/sum(prem23$Freq23)

prem_plot23<-ggplot( data=prem23
                     ,aes( y=prop23
                           ,x=Premise
                     ))+
  geom_bar( position="dodge"
            ,stat="identity")+
  scale_x_discrete(guide = guide_axis(angle=90))+
  ggtitle(glue("{icrime} 2023: Premise Distribution"))
print(prem_plot23)
# Compare 2022 to 2023 - ?by proportion
prem22[prem23,on=c("Premise")]


#Layer Plot - Premise
shop_prem<-crimes_filtered[ ,.(Freq=sum(OffenseCount))
                           ,by=c('Premise','year_mon')]%>%
           .[order(Premise,year_mon)]%>%
  .[,Rolling_12_Month:=frollapply(Freq,12,mean),]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']

shop_prem[is.na(shop_prem)] <- 0

cur<-ggplot( shop_prem
             ,aes( x=year_mon
                   ,y=Rolling_12_Month
                   ))+
  geom_line( linewidth = 1.5
             ,show.legend = FALSE
             ,aes(color=Premise))+
  labs(x="Year",y="Number of Incidents")+ 
  ggtitle("Shopilifting Incidents by Year-Month for Premise Type")+
  geom_label_repel( data = shop_prem %>% filter(year_mon == max(year_mon))
                   ,aes(label = Premise),
                   nudge_x = 1,
                   na.rm = TRUE)+
  theme_economist()

print(cur)

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
                          ,'year')]
                          #,'Premise')]

print('Offense Count: ')
print(sum(dd_agg$FREQ))
print('Distinct Addresses:')
nrow(dd_agg)