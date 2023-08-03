pre<-setDT(combined)

# Recode Premise
pre[,prem_oth:=ifelse( Premise %in% c( 'Residence, Home (Includes Apartment)'
                                      ,'Parking Lot, Garage'
                                      ,'Highway, Road, Street, Alley')
                      ,Premise
                      ,'Other')]

clus_n<-setDT(centers[,c('model.unit.classif','N')])              

#NIBRS Cat
cluster_desc<-pre[,.(Freq=sum(OffenseCount))
                  ,by=c('NIBRSDescription','model.unit.classif')]

clus_fin<-clus_n[cluster_desc,on=.(model.unit.classif)]

clus_fin$percent<-(clus_fin$Freq/clus_fin$N)*100.00

ggplot( data=clus_fin
        ,aes( y=percent
              ,x=NIBRSDescription
              ,group=model.unit.classif))+
  geom_bar( position="dodge"
            ,stat="identity")+facet_wrap(~model.unit.classif)

#NIBRS Premise Unfiltered
cluster_prem<-pre[,.(Freq=sum(OffenseCount))
                  ,by=c('Premise','model.unit.classif')]

clus_fin<-clus_n[cluster_prem,on=.(model.unit.classif)]

clus_fin$percent<-(clus_fin$Freq/clus_fin$N)*100.00

ggplot( data=clus_fin
        ,aes( y=percent
              ,x=Premise
              ,group=model.unit.classif))+
  geom_bar( position="dodge"
            ,stat="identity")+facet_wrap(~model.unit.classif)

prem_xtab<-dcast( clus_fin
                 ,model.unit.classif~Premise
                 ,value.var = c("percent"))

#NIBRS Premise Recat
cluster_prem<-pre[,.(Freq=sum(OffenseCount))
                  ,by=c('prem_oth','model.unit.classif')]

clus_fin<-clus_n[ cluster_prem
                 ,on=.(model.unit.classif)]

clus_fin$percent<-(clus_fin$Freq/clus_fin$N)*100.00

ggplot( data=clus_fin
        ,aes( y=percent
              ,x=prem_oth
              ,group=model.unit.classif))+
  geom_bar( position="dodge"
            ,stat="identity")+facet_wrap(~model.unit.classif)

prem_xtab<-dcast( clus_fin
                  ,model.unit.classif~prem_oth
                  ,value.var = c("percent"))