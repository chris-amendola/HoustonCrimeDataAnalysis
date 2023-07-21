library(zoo)
library(ggplot2)
 
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

#2023
cur_end_dt<-round_date(as.Date(ISOdate( year=cur_yr
                                        ,month=latest_mon
                                        ,day='28')),'month')-days(1)

cur_agg<-crimes_filtered[ (RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                           &RMSOccurrenceDate<=cur_end_dt)
                          ,.(OffenseCount=sum(OffenseCount))
                          ,by=group_dims]

#Prepare for comparison
setnames(bas_agg, "OffenseCount", glue("OffenseCount_bas"))
setnames(pri_agg, "OffenseCount", glue("OffenseCount_pri"))
setnames(cur_agg, "OffenseCount", glue("OffenseCount_cur"))

comp_ytds<-bas_agg[pri_agg,on=group_dims]%>%
          .[cur_agg,on=group_dims]
              
comp_ytds[,'diff_pri':=OffenseCount_cur-OffenseCount_pri]
comp_ytds[,'diff_bas':=OffenseCount_cur-OffenseCount_bas]

comp_ytds[,'perc_pri':=diff_pri/OffenseCount_cur]
comp_ytds[,'perc_bas':=diff_bas/OffenseCount_pri] 

setnames( comp_ytds
         ,c("OffenseCount_bas","OffenseCount_pri","OffenseCount_cur")
         ,c( glue("OffenseCount_{bas_yr}")
            ,glue("OffenseCount_{pri_yr}")
            ,glue("OffenseCount_{cur_yr}")))

#Prep for Plotting
bas_agg[,'Year':=bas_yr]
pri_agg[,'Year':=pri_yr]
cur_agg[,'Year':=cur_yr]

plot_prep<- rbindlist(list(bas_agg,pri_agg,cur_agg))  

ggplot( data=plot_prep
       ,aes( y=OffenseCount
            ,x=Year
            ,fill=Year))+
  geom_bar( position="dodge"
           ,stat="identity")
