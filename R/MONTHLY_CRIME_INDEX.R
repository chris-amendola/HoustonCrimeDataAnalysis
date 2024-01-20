setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/DEVEL')

agg_year<-multi_year[,.(OffenseCount=sum(OffenseCount))
                ,by=c('NIBRSDescription','year')]

lag_year<-agg_year[,Last_Year:=OffenseCount-lag( OffenseCount
                                     ,n=1
                                     ,order_by=year)
              ,by=c("NIBRSDescription")][year==2023]

agg_yrmon<-multi_year[,.(OffenseCount=sum(OffenseCount))
                     ,by=c('NIBRSDescription','year_mon')]

lag_yrmon<-agg_yrmon[,`:=`(Last_Month=OffenseCount-lag( OffenseCount
                                                       ,n=1
                                                       ,order_by=year_mon)
                           ,Month_Last_Year=OffenseCount-lag( OffenseCount
                                                             ,n=12
                                                             ,order_by=year_mon))
              ,by=c("NIBRSDescription")][year_mon>"2023-11-01"]

for (offense in all_desc$NIBRSDescription){
  print("--------------------------")
  print(lag_year[NIBRSDescription==offense])
  print(lag_yrmon[NIBRSDescription==offense])
  print("--------------------------")
}