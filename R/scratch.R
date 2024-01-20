crime_list<-c('Theft from motor vehicle')

## Overall Property
crimes_filtered<-multi_year[NIBRSDescription %chin% crime_list]

crimes_filtered[,.(Freq=sum(OffenseCount)),by=c('year')]
