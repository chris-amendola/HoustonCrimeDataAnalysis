library("readxl")
library("glue")
library("tidyverse")
library("data.table")
library("ggthemes")

theme_update(plot.title = element_text(hjust = 0.5))

where_the_data_is<-'C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/HPD_NIBRS/'

bydim<-'Overall'
group_dims<-c('NIBRSDescription',bydim)

violent_crimes<-c('Aggravated Assault'
                  ,'Forcible rape'
                  ,'Robbery'
                  ,'Murder, non-negligent')

baseline<-read_excel(glue('{where_the_data_is}2019_NIBRSPublicView.Jan1-Dec31.xlsx'))%>% 
          rename( OffenseCount=`Offense\r\nCount`
                 ,RMSOccurrenceDate=`Occurrence\r\nDate`
                 ,ZIPCode=`ZIP Code`
                 ,StreetType=`Street\r\nType`
                 ,RMSOccurrenceHour=`Occurrence\r\nHour`
                 ,NIBRSClass=`NIBRS\r\nClass`
                 ,StreetNo=`Block Range`)
baseline$MapLongitude<-NA
baseline$MapLatitude<-NA

min(baseline$RMSOccurrenceDate)
max(baseline$RMSOccurrenceDate)

year1<-read_excel(glue('{where_the_data_is}NIBRSPublicView.Jan1-Dec31-2020.xlsx'))%>% 
       rename( OffenseCount=`Offense\r\nCount`
              ,RMSOccurrenceDate=`Occurrence\r\nDate`
              ,ZIPCode=`ZIP Code`
              ,StreetType=`Street\r\nType`
              ,RMSOccurrenceHour=`Occurrence\r\nHour`
              ,NIBRSClass=`NIBRS\r\nClass`
              ,StreetNo=`Block Range`)
year1$MapLongitude<-NA
year1$MapLatitude<-NA

min(year1$RMSOccurrenceDate)
max(year1$RMSOccurrenceDate)

year2<-read_excel(glue('{where_the_data_is}NIBRSPublicViewDec21.xlsx'))
year2$MapLongitude<-NA
year2$MapLatitude<-NA

min(year2$RMSOccurrenceDate)
max(year2$RMSOccurrenceDate)

year3<-read_excel(glue('{where_the_data_is}NIBRSPublicViewDec22.xlsx'))

min(year3$RMSOccurrenceDate)
max(year3$RMSOccurrenceDate)

year4<-read_excel(glue('{where_the_data_is}NIBRSPublicViewJun23.xlsx'))

min(year4$RMSOccurrenceDate)
max(year4$RMSOccurrenceDate)

multi_year<-rbind(baseline,year1,year2,year3,year4)%>%
            mutate(year_mon=floor_date(RMSOccurrenceDate,'month'))

multi_year$year<-year(multi_year$RMSOccurrenceDate)
multi_year$Overall<-'OverAll'

setDT(multi_year)

qa_year_mon<-multi_year%>%group_by(year_mon)%>%summarize(freq=n())

qa_year<-multi_year%>%group_by(year)%>%summarize(freq=n())

qa_year_by_year_mon<-multi_year%>%group_by(year_mon,year)%>%summarize(freq=n())
