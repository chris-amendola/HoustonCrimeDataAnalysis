library(htmlwidgets)
setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/July2023')

## Overall Violent
crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
  .[,NIBRSDescription:='Violent']

NIBRS_Trend( indata=crimes_filtered
            ,'Violent Incidents')

ggsave( glue('Violent_Trend_{label_month}{label_year}.png')
       ,height=4
       ,width=8)

NIBRS_YTD( indata= crimes_filtered
           ,'Violent Incidents'
           ,latest_mon='07')

ggsave( glue('Violent_YTD_{label_month}{label_year}.png')
        ,height=4
        ,width=8)

crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]

## Individual Crimes
for (icrime in violent_crimes) {
  print(icrime)
  crimes_filtered<-multi_year[NIBRSDescription==icrime]
  print(nrow(crimes_filtered) )
  
  print( NIBRS_Trend(indata=crimes_filtered
        ,icrime))
  ggsave( glue('{icrime}_Trend_{label_month}{label_year}.png')
          ,height=4
          ,width=8)
  
  print( NIBRS_YTD(indata=crimes_filtered
        ,icrime))
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
ytd_months<-c('01','02','03','04','05','06','07')

for (imonth in ytd_months) {
  print(imonth)
  data_pre<-multi_year[ (NIBRSDescription %chin% violent_crimes)
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
            ,file=glue('Violent_Map_{imonth}.html')
            ,title=glue('Violent_Map_{imonth}'))
}

block<-function(){
for (ibeat in beats$Beats){
  beat_data<-crimes_filtered[Beat==ibeat]
  if (nrow(beat_data)>0){
    print(ibeat)
    print(nrow(beat_data))
    print(NIBRS_YTD( indata=beat_data
                ,glue('Violent Incidents\nBeat: {ibeat}')))
  } else{
    print('NO ROWS!')
    print(ibeat)
  }
}}
         

 
