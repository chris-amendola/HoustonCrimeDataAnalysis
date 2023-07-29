data_pre<-multi_year[ (NIBRSDescription=='Weapon law violations')
                     &(RMSOccurrenceDate>='2023-01-01')
                     &(RMSOccurrenceDate<='2023-06-30'),]

mon<-data_pre%>%
     group_by(year_mon)%>%
     summarise(Freq=sum(OffenseCount))

print(paste('Average 2023 Monthly: ',mean(mon$Freq)))