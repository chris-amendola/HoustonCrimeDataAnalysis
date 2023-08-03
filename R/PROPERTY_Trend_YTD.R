property_crimes<-c( 'Motor vehicle theft'
                   ,'Theft from motor vehicle'
                   ,'Theft of motor vehicle parts or accessory'
                   ,'Burglary, Breaking and Entering'
                   ,'Shoplifting'
)

## Overall Violent
crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]%>%
  .[,NIBRSDescription:='Property']

NIBRS_Trend(indata=crimes_filtered,'Property')
NIBRS_YTD(indata=crimes_filtered,'Property')

crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]

## Individual Crimes
for (icrime in property_crimes) {
  print(icrime)
  crimes_filtered<-multi_year[NIBRSDescription==icrime]
  print(nrow(crimes_filtered) )
  
  print(NIBRS_Trend(indata=crimes_filtered,icrime))
  print(NIBRS_YTD(indata=crimes_filtered,icrime))
  
  #Premise Eval Latest Year
  prem<-crimes_filtered[year=='2023',.(Freq=sum(OffenseCount)),by=Premise]
  prem_plot<-ggplot( data=prem
                     ,aes( y=Freq
                           ,x=Premise
                     ))+
    geom_bar( position="dodge"
              ,stat="identity")+
    scale_x_discrete(guide = guide_axis(angle=90))+
    ggtitle(glue("{icrime}: Premise Distribution"))
  print(prem_plot)
}