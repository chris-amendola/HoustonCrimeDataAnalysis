setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/DEVEL')

pacman::p_load( 
                 DBI
                ,glue
                ,data.table
                ,ggplot2
                ,ggthemes
                ,tidyverse
                ,magrittr )

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

where_the_data_is<-'C:/Users/chris/Documents/Houston_Crime_Data_Analysis/DATA'
db_name<-'HPD_NIBRS'

inc_db<- dbConnect( RSQLite::SQLite()
                    ,glue('{where_the_data_is}/{db_name}')
                    ,extended_types = TRUE)

multi_year<-setDT(dbReadTable(inc_db, 'multi_year'))

dbDisconnect(inc_db)

