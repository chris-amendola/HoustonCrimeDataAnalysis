eom<-function( month
              ,year
              ,base_day='28'){
  
  return(round_date(as.Date(ISOdate( year=year
                              ,month=month
                              ,day=base_day)),'month')-days(1))
}

m='06'
y='2019'
t<-eom(m,y)
eom(m,y)
eom('06','2019')

NIBRS_YTD<- function( indata
                     ,title1='title1'  
                     ,bas_yr='2019'
                     ,pri_yr='2022'
                     ,cur_yr='2023'
                     ,latest_mon='06') {

    #2019
    base_end_dt<-eom(latest_mon,bas_yr)
    
    bas_agg<-indata[ (RMSOccurrenceDate>=glue('{bas_yr}-01-01')
                               &RMSOccurrenceDate<=as.Date(base_end_dt))
                             ,.(OffenseCount=sum(OffenseCount))
                             ,by=group_dims]
    
    #2022
    pri_end_dt<-eom(latest_mon,pri_yr)
    
    pri_agg<-indata[ (RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                               &RMSOccurrenceDate<=as.Date(pri_end_dt))
                              ,.(OffenseCount=sum(OffenseCount))
                              ,by=group_dims]
    
    #2023
    cur_end_dt<-eom(latest_mon,cur_yr)
    
    cur_agg<-indata[ (RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                               &RMSOccurrenceDate<=as.Date(cur_end_dt))
                              ,.(OffenseCount=sum(OffenseCount))
                              ,by=group_dims]
    
    #Prep for Plotting
    bas_agg[,'Year':=bas_yr]
    pri_agg[,'Year':=pri_yr]
    cur_agg[,'Year':=cur_yr]
    
    plot_prep<- rbindlist(list(bas_agg,pri_agg,cur_agg))  
    
    return(ggplot( data=plot_prep
           ,aes( y=OffenseCount
                ,x=Year
                ,fill=Year))+
      geom_bar( position="dodge"
               ,stat="identity")+
      ggtitle(glue("Year-To-Date - {title1}"))+
      theme_economist()+
      scale_fill_manual(values=c('darkblue', 'darkgreen', 'darkred')))
}

#NIBRS_YTD(crimes_filtered)

#Prepare for comparison
#setnames(bas_agg, "OffenseCount", glue("OffenseCount_bas"))
#setnames(pri_agg, "OffenseCount", glue("OffenseCount_pri"))
#setnames(cur_agg, "OffenseCount", glue("OffenseCount_cur"))

#comp_ytds<-bas_agg[pri_agg,on=group_dims]%>%
#  .[cur_agg,on=group_dims]

#comp_ytds[,'diff_pri':=OffenseCount_cur-OffenseCount_pri]
#comp_ytds[,'diff_bas':=OffenseCount_cur-OffenseCount_bas]

#comp_ytds[,'perc_pri':=diff_pri/OffenseCount_cur]
#comp_ytds[,'perc_bas':=diff_bas/OffenseCount_pri] 

#setnames( comp_ytds
#          ,c("OffenseCount_bas","OffenseCount_pri","OffenseCount_cur")
#          ,c( glue("OffenseCount_{bas_yr}")#
#              ,glue("OffenseCount_{pri_yr}")
#              ,glue("OffenseCount_{cur_yr}")))
