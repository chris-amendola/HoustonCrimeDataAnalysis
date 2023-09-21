 crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]

crimes_filtered[,.(freq=sum(OffenseCount)),by=c('year','NIBRSDescription')] 
