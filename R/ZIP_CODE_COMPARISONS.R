fbi_zips<-c('77077')


## Overall Violent
viol<-multi_year[NIBRSDescription %chin% violent_crimes]
prop<-multi_year[NIBRSDescription %chin% property_crimes]



vio_agg<-viol[ ZIPCode %in% fbi_zips & month(RMSOccurrenceDate)<8
                    ,.(Count=sum(OffenseCount))
                    ,by=c( 'ZIPCode'
                       ,'year')]

prp_agg<-prop[ ZIPCode %in% fbi_zips & month(RMSOccurrenceDate)<8
                     ,.(Count=sum(OffenseCount))
                     ,by=c( 'ZIPCode'
                            ,'year')]
