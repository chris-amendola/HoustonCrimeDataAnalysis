## Overall Violent
crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
  .[,NIBRSDescription:='Violent']

viol_data<-setDT(crimes_filtered)

## Apply NCVS Weights
### NCVS_violent_wts['2023']<-mean(unlist(NCVS_violent_wts))
viol_data[, NCVS_wt:=(as.numeric(NCVS_violent_wts[as.character(year)]))]%>%
        .[,OC_wt:=NCVS_wt*OffenseCount]

colnames(viol_data)[colnames(viol_data)=="OffenseCount"] <-"Unweighted_OC"
colnames(viol_data)[colnames(viol_data)=="OC_wt"] <-"OffenseCount"

## Look at Raw Data
data<-viol_data[,.(OffenseCount=sum(Unweighted_OC)),by=(year_mon)]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']

ggplot(data=data, aes(x=year_mon, y=OffenseCount, group=1))+
  ggtitle(glue('Raw Data - UNWeighted '))+
  geom_line(color="darkblue", linewidth=1, alpha=0.9, linetype=1)+
  theme_economist()+
  theme(legend.key = element_rect(fill = "grey", colour = "black"))+
  theme(plot.title = element_text(hjust = 0.0))+
  ylab("Month Counts - Violent")

data<-viol_data[,.(OffenseCount=sum(OffenseCount)),by=(year_mon)]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']

ggplot(data=data, aes(x=year_mon, y=OffenseCount, group=1))+
       ggtitle(glue('Raw Data - NCVS Weighted'))+
       geom_line(color="darkblue", linewidth=1, alpha=0.9, linetype=1)+
       theme_economist()+
       theme(legend.key = element_rect(fill = "grey", colour = "black"))+
       theme(plot.title = element_text(hjust = 0.0))+
       ylab("Month Counts - Violent")


NIBRS_Trend( indata=viol_data
             ,'Violent Incidents')

NIBRS_YTD( indata=viol_data
           ,'Violent Incidents'
           ,latest_mon='07')


## Overall Property
crimes_filtered<-multi_year[NIBRSDescription %chin% property_crimes]%>%
  .[,NIBRSDescription:='Property']

prop_data<-setDT(crimes_filtered)

## Apply NCVS Weights
### NCVS_property_wts['2023']<-mean(unlist(NCVS_property_wts))
prop_data[, NCVS_wt:=(as.numeric(NCVS_property_wts[as.character(year)]))]%>%
        .[,OC_wt:=NCVS_wt*OffenseCount]

colnames(prop_data)[colnames(prop_data)=="OffenseCount"] <-"Unweighted_OC"
colnames(prop_data)[colnames(prop_data)=="OC_wt"] <-"OffenseCount"


NIBRS_Trend( indata=prop_data
             ,'Property Incidents')

NIBRS_YTD( indata=prop_data
           ,'Property Incidents'
           ,latest_mon='07')
