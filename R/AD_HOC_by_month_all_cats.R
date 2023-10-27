library(Kendall)

tests<-data.table()

## Individual Crimes
for (icrime in all_desc$NIBRSDescription) {
  
  print(icrime)
  crimes_filtered<-multi_year[NIBRSDescription==icrime]
  count<-nrow(crimes_filtered)
  print(count)

  #plot_prep<-crimes_filtered[ ,.(OffenseCount=sum(OffenseCount))
  #                 ,by=year_mon]
  
  plot_prep<-crimes_filtered[ ,.(nrows=.N)
                              ,by=year_mon]
  
  itest<-MannKendall(plot_prep$nrows)
  itest<-append(itest,list(Crime=icrime))
  itest$tau<-round(itest$tau,3)
  itest$sl<-round(itest$sl,3)
  
  tests<-rbind(tests,itest)
  
  series_max<-max(plot_prep$nrows)+(.05*max(plot_prep$nrows))
  series_mean<-mean(plot_prep$nrows)
  series_sd<-sd(plot_prep$nrows)
  
  plot_prep$z<-(plot_prep$nrows-series_mean)/series_sd
  plot_prep$change1<-plot_prep$nrows-lag(plot_prep$nrows,n=1)
  
  
  print(glue('{series_mean} {series_sd}'))
  
  print(ggplot(plot_prep, aes(x=year_mon, y=nrows)) +
          geom_point() +
          geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
          theme_economist()+ylim(0,series_max)+
          theme(plot.title = element_text(hjust = 0.0))+
          ylab('Incidents')+
          xlab('Year-Month')+
          labs(title =glue("Counts of {icrime} Incidents Reported by Year-Month", tag = "1"))+
          annotate('text'
                   ,x=as.POSIXct('2023-01-01')
                   ,y=max(plot_prep$nrows)
                   ,label=glue("tau={itest['tau']} \n  p={itest['sl']}"))       
        )
  

  if(1==2){ 
    
   print(ggplot( data=plot_prep
                  ,aes( y=z
                        ,x=year_mon
                  ))+
            geom_bar( position="dodge"
                      ,stat="identity")+
            ggtitle(glue("SDs - {icrime}"))+
            theme_economist())
    
    
    print(ggplot( data=plot_prep
                  ,aes( y=change1
                        ,x=year_mon
                  ))+
            geom_bar( position="dodge"
                      ,stat="identity")+
            ggtitle(glue("Month Change - {icrime}"))+
            theme_economist()+
            geom_text(
              aes(label=change1),
              colour="white", size = 3,
              vjust=1.5,position=position_dodge(.9)
            )+  
            scale_fill_manual(values=c('darkblue', 'darkgreen', 'darkred')))  
  
  print(ggplot( data=plot_prep
          ,aes( y=nrows
                ,x=year_mon
                ))+
    geom_bar( position="dodge"
              ,stat="identity")+
    ggtitle(glue("Year-To-Date - {icrime}"))+
    theme_economist()+
    geom_text(
      aes(label = nrows),
      colour = "white", size = 3,
      vjust = 1.5, position = position_dodge(.9)
    )+  
    scale_fill_manual(values=c('darkblue', 'darkgreen', 'darkred')))

  }
}  
