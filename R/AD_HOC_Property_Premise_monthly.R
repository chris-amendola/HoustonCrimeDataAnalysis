crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]

for (icrime in property_crimes) {
  #icrime<-'Motor vehicle theft '
  #Premise Eval by month 
  prem<-crimes_filtered[ ,.(Freq=sum(OffenseCount))
                         ,by=c('Premise','year_mon')]
  
  cur<-ggplot( prem
         ,aes( x=year_mon
              ,y=Freq
              ,color=Premise)
              )+
    geom_line( linewidth = 1.5
              ,show.legend = FALSE)+
    theme_economist()
  
  print(cur)
  
  if(1==2){
  prem%>%ggplot()+
    geom_area(aes( year_mon
                   ,Freq
                   ,group=Premise
                   ,fill=Premise)
              , stat = 'identity')+
    theme_economist()
  }
}