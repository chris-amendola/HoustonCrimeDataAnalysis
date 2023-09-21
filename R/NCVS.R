library(readr)


#NCVS Analysis
NCVS_Reporting<-read_csv("C:/Users/chris/Downloads/Percent of violent crime excluding simple assault victimizations by reporting to the police, 1993 to 2021.csv"
                         ,skip = 1)%>%
                filter( (Year>2011)
                       &(Year<2022)
                       &(`Reporting to the police`=='Yes'))

ggplot( data=NCVS_Reporting
        ,aes( x=Year
              ,y=`Percent of violent crimes excluding simple assaults`
              ,group=1)) + geom_bar(stat='Identity') +geom_line()
  
  geom_bar(stat='identity')+
  xlab(label='Month (2023)')+
  labs(
    title = "Houston Crime Data Analysis",
    subtitle = "Theft-From Autos - Memorial Park",
    caption = "Caption"
  )
  
# Total Incident Counts by month  
data<-setDT(multi_year)

plot_it<-data[,.(freq=.N)
              ,by=c('year_mon')]

plot_it[,.( min=min(freq)
           ,max=max(freq)
           ,avg=mean(freq)
           ,sd=sd(freq)
           ,n=.N)]


ggplot( data=plot_it
        ,aes( x=year_mon
              ,y=freq)) + 
  geom_line(stat='Identity')+
  ylim(0,max(plot_it$freq))+
  stat_smooth()+
  ggtitle('Total Incident Counts by month')

# Violent Incident Counts by month  
data<-setDT(multi_year)

plot_it<-data[NIBRSDescription %in% violent_crimes
              ,.(freq=.N)
              ,by=c('year_mon')]

plot_it[,.( min=min(freq)
            ,max=max(freq)
            ,avg=mean(freq)
            ,sd=sd(freq)
            ,n=.N)]


ggplot( data=plot_it
        ,aes( x=year_mon
              ,y=freq)) + 
  geom_line(stat='Identity')+
  ylim(0,max(plot_it$freq))+
  stat_smooth()+
  ggtitle('Violent Incident Counts by month')

# Property Incident Counts by month  
data<-setDT(multi_year)

plot_it<-data[NIBRSDescription %in% property_crimes
              ,.(freq=.N)
              ,by=c('year_mon')]

plot_it[,.( min=min(freq)
            ,max=max(freq)
            ,avg=mean(freq)
            ,sd=sd(freq)
            ,n=.N)]

plot_it[,.( min=min(freq)
            ,max=max(freq)
            ,avg=mean(freq)
            ,sd=sd(freq)
            ,n=.N)]


ggplot( data=plot_it
        ,aes( x=year_mon
              ,y=freq)) + 
  geom_line(stat='Identity')+
  ylim(0,max(plot_it$freq))+
  stat_smooth()+
  ggtitle('Property Incident Counts by month')
