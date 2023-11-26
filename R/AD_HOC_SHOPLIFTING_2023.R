library(htmlwidgets)
setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/October2023')
z_poi<-function(current,historical){
  
  return(2*(sqrt(current)-sqrt(historical)))
  
}

eom<-function( month
               ,year
               ,base_day='28'){
  
  return(round_date(as.Date(ISOdate( year=year
                                     ,month=month
                                     ,day=base_day)),'month')-days(1))
}

pri_yr='2022'
cur_yr='2023'
latest_mon<-'10'

pri_end_dt<-eom(latest_mon,pri_yr)
cur_end_dt<-eom(latest_mon,cur_yr)

## Look at specific crime
icrime<-'Shoplifting'
crimes_filtered<-multi_year[NIBRSDescription==icrime]
print(icrime)
print(nrow(crimes_filtered))

print( NIBRS_YTD(indata=crimes_filtered
                 ,glue('{icrime}\nFigure 2')
                 ,latest_mon='10'))

print(NIBRS_Trend( indata=crimes_filtered
                   ,title=glue('Trend-line- {icrime}')
                   ,sub_title='Figure 1'
))

prem_data<-crimes_filtered[ ( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                             &RMSOccurrenceDate<=as.Date(cur_end_dt))
                           |( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                             &RMSOccurrenceDate<=as.Date(pri_end_dt)) 
                           ,.(Freq=sum(OffenseCount))
                           ,by=c('Premise','year')]%>%
           .[order(-Freq)]
prem_data$Year<-as.character(prem_data$year)

prem_yr<-dcast( prem_data
               ,Premise~Year
               ,value.var = "Freq")

prem_yr[is.na(prem_yr), ]<-0    

print(sum(prem_yr$`2022`))
print(sum(prem_yr$`2023`))

prem_yr$change<-prem_yr$`2023`-prem_yr$`2022`

print(sum(prem_yr$change))


addr<-crimes_filtered[ ( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                         &RMSOccurrenceDate<=as.Date(cur_end_dt))
                       |( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                          &RMSOccurrenceDate<=as.Date(pri_end_dt)) 
                       ,.(Freq=sum(OffenseCount))
                       ,by=c( 'StreetNo'
                              ,'StreetName'
                              ,'StreetType'
                              ,'Suffix'
                              ,'year'
                       )][order(StreetName,StreetType,Suffix,StreetNo)]

addr_yr<-dcast( addr
               ,StreetNo+StreetName+StreetType+Suffix~year
               ,value.var = "Freq")

addr_yr[is.na(addr_yr), ]<-0    

addr_yr$change<-addr_yr$`2023`-addr_yr$`2022`

addr_yr$z_poi<-z_poi(addr_yr$`2023`,addr_yr$`2022`)

## Mapping by Month
cur_year<-'2023'
ytd_months<-c('01','02','03','04','05','06','07','08','09','10')

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
              ,file=glue('Shoplift_Map_{imonth}.html')
              ,title=glue('Shoplift_Map_{imonth}'))
}

stop<-function(){
ggplot( prem_data
       ,aes( x=Premise
            ,y=Freq
            ,fill=Year)) +
  geom_bar(position="dodge",stat='identity') +
  theme_economist()+
  coord_flip()+
  theme(plot.title = element_text(hjust = 0.0))+
  ylab('Numbers of Incidents Reported')+
  xlab('Premise')+
  labs(title = "Counts of Incidents Reported by Year", tag = "1")

ggplot( prem_yr
        ,aes( x=Premise
              ,y=change
              )) +
  geom_bar(position="dodge",stat='identity') +
  theme_economist()+
  coord_flip()+
  theme(plot.title = element_text(hjust = 0.0))+
  ylab('Difference of Incidents Reported')+
  xlab('Premise')+
  labs(title = "Changes in Counts of Incidents Reported 2022 to 2023", tag = "1")
}



