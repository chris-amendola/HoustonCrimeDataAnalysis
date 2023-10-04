## Overall Categories
viol<-multi_year[NIBRSDescription %chin% violent_crimes]
prop<-multi_year[NIBRSDescription %chin% property_crimes]

#Trim zip to length 5
viol[,ZIP5:=substr(ZIPCode,1,5)]
prop[,ZIP5:=substr(ZIPCode,1,5)]

## By Zipcode Look
v_agg<-viol[,.(Count=sum(OffenseCount))
            ,by=c( 'ZIP5'
                  ,'year')]

v_tab<-dcast( v_agg 
             ,ZIP5 ~ year
             ,value.var=c("Count"))

p_agg<-prop[,.(Count=sum(OffenseCount))
            ,by=c( 'ZIP5'
                   ,'year')]

p_tab<-dcast( p_agg 
              ,ZIP5 ~ year
              ,value.var=c("Count"))
