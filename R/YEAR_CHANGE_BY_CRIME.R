
agg<-multi_year[NIBRSDescription %in% violent_crimes,.(OffenseCount=sum(OffenseCount))
                ,by=c('year')]

lag<-agg[,lag:=OffenseCount-lag( OffenseCount
              ,n=1
              ,order_by=year)][year>2019]
 

title1<-'Stuff'
ggplot( data=lag
        ,aes( y=lag
              ,x=year
              ))+
  geom_bar( position="dodge"
            ,stat="identity")+
  ggtitle(glue("Year-To-Date - {title1}"))+
  theme_economist()+
  geom_text(
    aes(label = lag),
    colour = "blue", size = 3,
    vjust = 1.5, position = position_dodge(.9)
  )