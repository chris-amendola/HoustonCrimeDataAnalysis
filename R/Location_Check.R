find_crimes<-c('Drug, narcotic violations')

drill_down<-multi_year[ (NIBRSDescription %chin% find_crimes)]

dd_agg<-drill_down[,.(FREQ=sum(OffenseCount))
                   ,by=c( 'StreetNo'
                          ,'StreetName'
                          ,'StreetType'
                          ,'year')]
