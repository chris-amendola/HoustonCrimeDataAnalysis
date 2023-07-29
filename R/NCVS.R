library(readr)

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