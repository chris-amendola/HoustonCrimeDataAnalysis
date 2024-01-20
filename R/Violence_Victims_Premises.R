library(htmlwidgets)
library(plyr)

z_poi<-function(current,historical){
  
  return(2*(sqrt(current)-sqrt(historical)))
  
}

setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/DEVEL')

## Overall Violent
crimes_filtered<-multi_year[ (NIBRSDescription %chin% violent_crimes)
                            &(year %in% c(2021,2022)) ]

crimes_filtered$Year<-factor(crimes_filtered$year)

crimes_filtered$Premise_Misc<-revalue( crimes_filtered$Premise
                                      ,c( "Rest Area"="Misc"
                                         ,"Camp/Campground"="Misc"))

agg_YR<-crimes_filtered[,.(count=sum(OffenseCount))
                        ,by=c('Year')]

agg_yr_prem<-crimes_filtered[,.(Freq=sum(OffenseCount))
                     ,by=c('Year','Premise_Misc')]

merge<-agg_YR[agg_yr_prem,on=c('Year')]%>%
            .[,Prop:=(Freq/count)]

ggplot(merge,aes( x=Premise_Misc
               ,y=Prop
               ,fill=Year))+ 
  geom_bar(position="dodge", stat="identity")+
  theme( axis.text.x=element_text(angle=90))

ggplot(merge,aes( x=Premise_Misc
                  ,y=Freq
                  ,fill=Year))+ 
  geom_bar(position="dodge", stat="identity")+
  theme( axis.text.x=element_text(angle=90))
 
# CAST WIDE
dt<-dcast( merge
          ,Premise_Misc~Year
          ,value.var=c("Freq","Prop","count"))
dt[is.na(dt)] <- 0

#Z Poisson
z_poi<-function(current,historical){
  
  return(2*(sqrt(current)-sqrt(historical)))
  
}
dt[Premise_Misc=='Residence, Home (Includes Apartment)']

z_poi(11325,12200)

## Goodness of FIT???
exp_prp<-dt$Prop_2021
obs_cts<-dt$Freq_2022

chisq.test(x=obs_cts, p=exp_prp)

exp_cts<-exp_prp*merge[Year==2021,.(sum(Freq))][[1]]

((obs_cts-exp_cts)^2)/exp_cts


         