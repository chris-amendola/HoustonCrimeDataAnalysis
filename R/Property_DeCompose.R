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
  
agg%>%ggplot()+
geom_area(aes( year_mon
              ,Rolling_12_Month
              ,group=NIBRSDescription
              ,fill=NIBRSDescription)
          , stat = 'identity')+
  theme_economist()


#ggplot( agg_wide
#        ,aes(x=year_mon))+ 
#  geom_line(aes(y=Arson), color = "darkorange", linetype="twodash") + 
#  geom_line(aes(y=`Motor vehicle theft`), color="black", linetype="twodash")+ 
#  geom_line(aes(y=`All other larceny`), color="blue", linetype="twodash")+
#  geom_line(aes(y=`Burglary, Breaking and Entering`), color="red", linetype="twodash")+
#  geom_line(aes(y=`Theft from motor vehicle`), color="purple", linetype="twodash")+
#  geom_line(aes(y=`Theft of motor vehicle parts or accessory`), color="darkgreen"
#            , linetype="twodash")