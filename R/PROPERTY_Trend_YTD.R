
## Overall Property
crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]%>%
  .[,NIBRSDescription:='Index Property Crimes']

NIBRS_Trend(indata=crimes_filtered,'Index Property Crimes')
ggsave( glue('Property_Trend_{label_month}{label_year}.png')
        ,height=4
        ,width=8)

NIBRS_YTD(indata=crimes_filtered,'Index Property Crimes',latest_mon='08')
ggsave( glue('Index_Property_YTD_{label_month}{label_year}.png')
        ,height=4
        ,width=8)

crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]

## Individual Crimes
for (icrime in property_crimes) {
  print(icrime)
  crimes_filtered<-multi_year[NIBRSDescription==icrime]
  print(nrow(crimes_filtered) )
  
  print(NIBRS_Trend( indata=crimes_filtered
                    ,icrime))
  ggsave( glue('{icrime}_Trend_{label_month}{label_year}.png')
          ,height=4
          ,width=8)
  print(NIBRS_YTD( indata=crimes_filtered
                  ,icrime,latest_mon='08'))
  ggsave( glue('{icrime}_YTD_{label_month}{label_year}.png')
          ,height=4
          ,width=8) 
  
  #Premise Eval Latest Year
  prem<-crimes_filtered[year=='2023',.(Freq=sum(OffenseCount)),by=Premise]
  prem_plot<-ggplot( data=prem
                     ,aes( y=Freq
                           ,x=Premise
                     ))+
    geom_bar( position="dodge"
              ,stat="identity")+
    scale_x_discrete(guide = guide_axis(angle=90))+
    ggtitle(glue("{icrime}: Premise Distribution"))
  print(prem_plot)
  ggsave( glue('{icrime}_Premise_{label_month}{label_year}.png')
          ,height=4
          ,width=8)
}

## Mapping by Month
cur_year<-'2023'
ytd_months<-c('01','02','03','04','05','06','07','08')

for (icrime in property_crimes) {
  print(icrime)
  for (imonth in ytd_months) {
    print(imonth)
    data_pre<-multi_year[ (NIBRSDescription==icrime)
                          &(RMSOccurrenceDate>=glue('2023-{imonth}-01'))
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
                ,file=glue('{icrime}_Map_{imonth}.html')
                ,title=glue('{icrime}_Map_{imonth}'))
  }
}  