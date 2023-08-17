property_crimes<-c('Theft of motor vehicle parts or accessory')

# Filter
crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]

agg<-crimes_filtered[,.(Freq=sum(OffenseCount))
                     ,by=c('NIBRSDescription','year_mon')]%>%
  .[,Rolling_12_Month:=frollapply(Freq,12,mean),by=c('NIBRSDescription')]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']

agg_wide<-dcast( agg
                ,year_mon~NIBRSDescription
                ,value.var='Rolling_12_Month')

ggplot(agg,aes(x=year_mon,y=Rolling_12_Month,color=NIBRSDescription))+
  geom_line(size = 1.5)+
  theme_economist()
  
