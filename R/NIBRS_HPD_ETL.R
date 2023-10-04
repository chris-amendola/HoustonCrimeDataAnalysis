library("readxl")
library("glue")
library("tidyverse")
library("data.table")
library("zoo")
library("ggplot2")
library("ggthemes")
library("leaflet")
library('sf')
library('dplyr')
library('htmlwidgets')

setwd('C:/Users/chris/Documents/GitHub/HoustonCrimeDataAnalysis/R')

source('NIBRS_Trendx.R')
source('YTD_NIBRS.R')
source('GEOPLOT.R')

sf_use_s2(FALSE)

where_the_data_is<-'C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/HPD_NIBRS/'
support_dir<-'C:/Users/chris/Documents/GitHub/HoustonCrimeDataAnalysis/DATA/Support/'

NCVS_violent_wts<-list( `2019`=2.15
                       ,`2020`=2.03 
                       ,`2021`=1.92
                       ,`2022`=2.08
)

NCVS_violent_wts['2023']<-mean(unlist(NCVS_violent_wts))

NCVS_property_wts<-list( `2019`=3.33
                        ,`2020`=3.94
                        ,`2021`=2.30
                        ,`2022`=4.20
)
NCVS_property_wts['2023']<-mean(unlist(NCVS_property_wts))


label_year<-'2023'
label_month<-'08'
to_dt_month<-'08'


districts<-st_read(glue("{support_dir}COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson"))%>%
  filter(!is.na(DISTRICT) )

beats<-st_read(glue("{support_dir}COH_POLICE_BEATS.geojson"))

bydim<-'Overall'
group_dims<-c('NIBRSDescription',bydim)

violent_crimes<-c('Aggravated Assault'
                  ,'Forcible rape'
                  ,'Robbery'
                  ,'Murder, non-negligent')

property_crimes<-c( 'Motor vehicle theft'
                    ,'Theft from motor vehicle'
                    ,'Theft of motor vehicle parts or accessory'
                    ,'Burglary, Breaking and Entering'
                    ,'All other larceny'
                    ,'Arson')

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

year4<-read_excel(glue('{where_the_data_is}NIBRSPublicViewAug23.xlsx'))

min(year4$RMSOccurrenceDate)
max(year4$RMSOccurrenceDate)

## MULTI YEAR
multi_year<-rbind(baseline,year1,year2,year3,year4)%>%
            mutate(year_mon=floor_date(RMSOccurrenceDate,'month'))

multi_year$year<-year(multi_year$RMSOccurrenceDate)
multi_year$Overall<-'OverAll'

all_desc<-multi_year%>%group_by(NIBRSDescription)%>%summarize(Freq=sum(OffenseCount))
all_prem<-multi_year%>%group_by(Premise)%>%summarize(Freq=sum(OffenseCount))
all_beat<-multi_year%>%group_by(Beat)%>%summarize(Freq=sum(OffenseCount))

setDT(multi_year)

YTD_VOLUMES<-multi_year[ (NIBRSDescription %chin% violent_crimes),]%>%
  .[ ( RMSOccurrenceDate>=glue('2019-01-01')
      &RMSOccurrenceDate<=eom(to_dt_month,2019))
    |( RMSOccurrenceDate>=glue('2020-01-01')
      &RMSOccurrenceDate<=eom(to_dt_month,2020))
    |( RMSOccurrenceDate>=glue('2021-01-01')
      &RMSOccurrenceDate<=eom(to_dt_month,2021))
    |( RMSOccurrenceDate>=glue('2022-01-01')
      &RMSOccurrenceDate<=eom(to_dt_month,2022))
    |( RMSOccurrenceDate>=glue('2023-01-01')
       &RMSOccurrenceDate<=eom(to_dt_month,2023)),]

ETL_VALIDATE<-function(){
  
  qa_year_mon<-multi_year%>%
               group_by(year_mon)%>%
               summarize(Row_Count=n())%>%
               filter()
  
  qa_year_mon$year_mon<-as.Date(qa_year_mon$year_mon)
  str(qa_year_mon)
  
  ggplot( data=qa_year_mon
          ,aes( x=year_mon
                ,y=Row_Count))+
    geom_bar(stat="identity")+
    scale_x_date( breaks = date_breaks("months")
                 ,labels = date_format("%b-%Y")
                 ,expand = c(.01, .01))+
    theme(axis.text.x = element_text( angle = 90
                                     ,vjust = 0.5
                                     ,hjust=1))+
    #  Labelling as desired
    labs(
      title = "Row-Counts By Year-Month"
      #,subtitle = "SUB"
      #,caption = "Caption"
    )
  
  qa_year<-multi_year%>%
           group_by(year)%>%
           summarize(Row_Count=n())
  
  ggplot( data=qa_year
          ,aes( x=year
                ,y=Row_Count))+
    geom_bar(stat="identity")

    qa_year_by_year_mon<-multi_year%>%group_by(year_mon,year)%>%summarize(freq=n())
    
    YTD_VOLUMES<-multi_year[ (NIBRSDescription %chin% violent_crimes),]%>%
      .[ ( RMSOccurrenceDate>=glue('2019-01-01')
           &RMSOccurrenceDate<=eom(to_dt_month,2019))
         |( RMSOccurrenceDate>=glue('2020-01-01')
            &RMSOccurrenceDate<=eom(to_dt_month,2020))
         |( RMSOccurrenceDate>=glue('2021-01-01')
            &RMSOccurrenceDate<=eom(to_dt_month,2021))
         |( RMSOccurrenceDate>=glue('2022-01-01')
            &RMSOccurrenceDate<=eom(to_dt_month,2022))
         |( RMSOccurrenceDate>=glue('2023-01-01')
            &RMSOccurrenceDate<=eom(to_dt_month,2023)),]
    
    year_vol<-YTD_VOLUMES%>%group_by(year)%>%summarize(freq=n())
    ggplot( data=year_vol
            ,aes( x=year
                  ,y=freq))+
      geom_bar(stat="identity")
    }

