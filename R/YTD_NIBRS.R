library(zoo)
library(ggplot2)
theme_update(plot.title = element_text(hjust = 0.5))

group_dims<-c('NIBRSDescription','Overall')

violent_crimes<-c('Aggravated Assault'
                  ,'Forcible rape'
                  ,'Robbery'
                  ,'Murder, non-negligent')
bas_yr='2019'
pri_yr='2022'
cur_yr='2023'

latest_mon='06'

crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
  .[,NIBRSDescription:='Violent']

#2019
base_end_dt<-round_date(as.Date(ISOdate( year=bas_yr
                             ,month=latest_mon
                             ,day='28')),'month')-days(1)

bas_agg<-crimes_filtered[ (RMSOccurrenceDate>=glue('{bas_yr}-01-01')
                           &RMSOccurrenceDate<=base_end_dt)
                         ,.(OffenseCount=sum(OffenseCount))
                         ,by=group_dims]

#2022
pri_end_dt<-round_date(as.Date(ISOdate( year=pri_yr
                                         ,month=latest_mon
                                         ,day='28')),'month')-days(1)

pri_agg<-crimes_filtered[ (RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                           &RMSOccurrenceDate<=pri_end_dt)
                          ,.(OffenseCount=sum(OffenseCount))
                          ,by=group_dims]

setnames(pri_agg, "OffenseCount", glue("OffenseCount_{pri_yr}"))

#2023
cur_end_dt<-round_date(as.Date(ISOdate( year=cur_yr
                                        ,month=latest_mon
                                        ,day='28')),'month')-days(1)

cur_agg<-crimes_filtered[ (RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                           &RMSOccurrenceDate<=cur_end_dt)
                          ,.(OffenseCount=sum(OffenseCount))
                          ,by=group_dims]
setnames(cur_agg, "OffenseCount", glue("OffenseCount_{cur_yr}"))

#Assemble for comparison
comp_ytds<-bas_agg[pri_agg,on=group_dims]%>%
          .[cur_agg,on=group_dims]
                          
