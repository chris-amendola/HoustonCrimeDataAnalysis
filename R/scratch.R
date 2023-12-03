multi_year[ NIBRSDescription=='Murder, non-negligent'
           ,.(Count=sum(OffenseCount))
           ,by=c('year')]