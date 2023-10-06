library(gt)

setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/August2023')

bas_yr='2019'
pri_yr='2022'
cur_yr='2023'
latest_mon='08'

base_end_dt<-eom(latest_mon,bas_yr)

pri_end_dt<-eom(latest_mon,pri_yr)

cur_end_dt<-eom(latest_mon,cur_yr)

incidents_ytd<-multi_year[ (NIBRSDescription %chin% violent_crimes),]%>%
              .[( RMSOccurrenceDate>=glue('{bas_yr}-01-01')
                  &RMSOccurrenceDate<=base_end_dt)
                |( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                   &RMSOccurrenceDate<=pri_end_dt)
                |( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                   &RMSOccurrenceDate<=cur_end_dt),]

#Aggregate
incidents_ytd_agg<-incidents_ytd[,.(OffenseCount=sum(OffenseCount))
                                 ,by=list(Beat,year)]
#Transpose Column per year
comp_ytds<-dcast( incidents_ytd_agg
                 ,Beat~year
                 ,value.var = c("OffenseCount"))

#Merge GeoJson to DataTable
##This filters to mappable beats from data.
beats_tab<-setDT(beats)
final<-comp_ytds[beats_tab,on=.(Beat=Beats)]

#Handle Numeric NAs
final[is.na(`2019`), `2019`:= 0]
final[is.na(`2022`), `2022`:= 0]
final[is.na(`2023`), `2023`:= 0]
#Differnces
final$diff_prior<-final$'2023'-final$'2022'
final$diff_base<-final$'2023'-final$'2019'
final$crime_density<-final$`2023`/final$Area_sq_mi

#POPUP
final$popup<-paste("<b>HPD Beat: </b>", final$Beat, "<br>", 
                       "<br>", "<b>Change from Last Year: </b>", final$diff_prior,
                       "<br>", "<b>Change from 2019: </b>", final$diff_base,
                       "<br>", "<b>Offense Count 2019: </b>", final$'2019',
                       "<br>", "<b>Offense Count 2022: </b>", final$'2022',
                       "<br>", "<b>Offense Count 2023: </b>", final$'2023')

#SIMPLE REPORT
rep_data<-final[,c('Beat','diff_base','diff_prior')]
rep_data[diff_base==0,base_chg:='Zero']
rep_data[diff_base>0,base_chg:='Up']
rep_data[diff_base<0,base_chg:='Down']

rep_data[diff_prior==0,prior_chg:='Zero']
rep_data[diff_prior>0,prior_chg:='Up']
rep_data[diff_prior<0,prior_chg:='Down']

rep_data_base_agg<-rep_data[,.(Freq=.N,Count=sum(diff_base)),by='base_chg' ]
rep_data_prior_agg<-rep_data[,.(Freq=.N,Count=sum(diff_prior)),by='prior_chg' ]

rep_data_prior_agg%>%gt()%>%tab_header(
  title='Beat Changes from Prior Year',
  subtitle='2022')%>%
  cols_label( prior_chg = md("**Change Direction**")
             ,Freq=md("**Count**")
             ,Count=md("**Offense Count**")) 

ggplot( data=rep_data_prior_agg
        ,aes( y=Freq
              ,x=prior_chg))+
  geom_bar( position="dodge"
            ,stat="identity")+
  ggtitle(glue("Beat Changes from Prior Year(2022)"))+
  labs(x="Direction of Change",y="Number of Beats")+
  theme_economist()

rep_data_base_agg%>%gt()%>%tab_header(
  title='Beat Changes from Base Year',
  subtitle='2019')%>%
  cols_label( base_chg=md("**ChangeDirection**")
             ,Freq=md("**Count**")
             ,Count=md("**Offense Count**")) 

ggplot( data=rep_data_base_agg
        ,aes( y=Freq
              ,x=base_chg))+
  geom_bar( position="dodge"
            ,stat="identity")+
  ggtitle(glue("Beat Changes from Base Year(2019)"))+
  theme_economist()

rep_data_prior_agg$Beat_Prec<-round((rep_data_prior_agg$Freq/sum(rep_data_prior_agg$Freq))*100.00,1)
print(sum(rep_data_prior_agg$Count))

# MAPPING
#Prep Final
final<- sf::st_as_sf(final)
#Get Bounds for custom bins
min_bin<-min(final$diff_prior,na.rm=TRUE)
max_bin<-max(final$diff_prior,na.rm=TRUE)

c_bins=c( min_bin
         ,(min_bin%/%3)*2
         ,min_bin%/%3
         ,0
         ,max_bin%/%3
         ,(max_bin%/%3)*2
         ,max_bin)

# Creating a color palette, with custom bins, based on difference from prior year
pal <- colorBin( "RdYlBu"
                ,domain=final$diff_prior
                ,c_bins
                ,pretty = FALSE
                ,reverse=TRUE)

change<-leaflet() %>%
  addTiles()%>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(provider = "Esri.WorldStreetMap",group = "World StreetMap") %>%
  addProviderTiles(provider = "Esri.WorldImagery",group = "World Imagery") %>%
  addLayersControl(
    baseGroups = c("OSM (default)","World StreetMap", "World Imagery"),
    options = layersControlOptions(collapsed = FALSE))%>%
  addPolygons(data = final, 
              fillColor = ~pal(final$diff_prior), 
              fillOpacity = 0.7, 
              weight = 1.0, 
              smoothFactor = 0.2, 
              popup = ~popup) %>%
  addLegend(pal = pal, 
            values = final$diff_prior, 
            position = "bottomright", 
            title = "YTD Changes in Violent Crime Counts")

saveWidget( change
            ,selfcontained=TRUE  
            ,file=glue('Violent_Change_{latest_mon}.html')
            ,title=glue('Violent_Change_{latest_mon}'))

## BASE
min_bin<-min(final$diff_base,na.rm=TRUE)
max_bin<-max(final$diff_base,na.rm=TRUE)

c_bins=c( min_bin
          ,(min_bin%/%3)*2
          ,min_bin%/%3
          ,0
          ,max_bin%/%3
          ,(max_bin%/%3)*2
          ,max_bin)

pal <- colorBin( "RdYlBu"
                 ,domain=final$diff_base
                 ,c_bins
                 ,pretty = FALSE
                 ,reverse=TRUE)

change_base<-leaflet() %>%
  addTiles()%>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(provider = "Esri.WorldStreetMap",group = "World StreetMap") %>%
  addProviderTiles(provider = "Esri.WorldImagery",group = "World Imagery") %>%
  addLayersControl(
    baseGroups = c("OSM (default)","World StreetMap", "World Imagery"),
    options = layersControlOptions(collapsed = FALSE))%>%
  addPolygons(data = final, 
              fillColor = ~pal(final$diff_base), 
              fillOpacity = 0.7, 
              weight = 1.0, 
              smoothFactor = 0.2, 
              popup = ~popup) %>%
  addLegend(pal = pal, 
            values = final$diff_base, 
            position = "bottomright", 
            title = "YTD Changes in Violent Crime Counts 2019")

saveWidget( change_base
            ,selfcontained=TRUE  
            ,file=glue('Violent_Change_Base_{latest_mon}.html')
            ,title=glue('Violent_Change_Base_{latest_mon}'))

## DENSITY
pal <- colorQuantile( palette="RdYlBu"
                    ,domain=final$crime_density
                    ,n=10
                    ,reverse=TRUE)

dense<-leaflet() %>%
  addTiles()%>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(provider = "Esri.WorldStreetMap",group = "World StreetMap") %>%
  addProviderTiles(provider = "Esri.WorldImagery",group = "World Imagery") %>%
  addLayersControl(
    baseGroups = c("OSM (default)","World StreetMap", "World Imagery"),
    options = layersControlOptions(collapsed = FALSE))%>%
  addPolygons(data = final, 
              fillColor = ~pal(final$crime_density), 
              fillOpacity = 0.7, 
              weight = 1.0, 
              smoothFactor = 0.2, 
              popup = ~popup) %>%
  addLegend(pal = pal, 
            values = final$crime_density, 
            position = "bottomright", 
            title = "Violent Crime Density(#/Square Mile)")

saveWidget( dense
            ,selfcontained=TRUE  
            ,file=glue('Violent_Density_{latest_mon}.html')
            ,title=glue('Violent_Density_{latest_mon}'))