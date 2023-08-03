#BURG_by_Hour
# 9 to 5 (9 to 16) vs 9 to 5 (21 to 4)
crimes_filtered<-multi_year[ (NIBRSDescription=='Burglary, Breaking and Entering')
                            &(RMSOccurrenceDate>='2022-01-01' & RMSOccurrenceDate>='2022-12-31')]

crimes_filtered[,.(freq=sum(OffenseCount))
                ,by=RMSOccurrenceHour]

atwork<-(crimes_filtered$RMSOccurrenceHour>=9&crimes_filtered$RMSOccurrenceHour<=16) 
athome<-( (crimes_filtered$RMSOccurrenceHour>=21&crimes_filtered$RMSOccurrenceHour<=24)
         |(crimes_filtered$RMSOccurrenceHour>=0&crimes_filtered$RMSOccurrenceHour<=4)
         ) 
crimes_filtered$cat<-'-'
crimes_filtered[, cat := fifelse(atwork, '9to5',crimes_filtered$cat)]
crimes_filtered[, cat := fifelse(athome, '5to9',crimes_filtered$cat)]

test<-crimes_filtered[,.(freq=sum(OffenseCount))
                ,by=c('RMSOccurrenceHour','cat')]

plotit<-crimes_filtered[,.(freq=sum(OffenseCount))
                ,by=c('cat')]

ggplot( data=test
        ,aes( x=RMSOccurrenceHour
              ,y=freq))+
  geom_bar(stat="identity")

ggplot( data=plotit
        ,aes( x=cat
              ,y=freq))+
  geom_bar(stat="identity")