agg<-multi_year[,.(Freq=sum(OffenseCount))
                ,by=c('year','Premise','NIBRSDescription')]

ggplot( agg
       ,aes( x=year
            ,y=Freq
            ,fill=Premise))+geom_bar(stat="identity")+facet_grid(NIBRSDescription ~ .)

