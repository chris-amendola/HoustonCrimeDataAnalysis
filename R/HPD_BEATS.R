setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/July2023')

bas_yr='2019'
pri_yr='2022'
cur_yr='2023'
latest_mon='06'

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

#Differnces
comp_ytds$diff_prior<-comp_ytds$'2023'-comp_ytds$'2022'
comp_ytds$diff_base<-comp_ytds$'2023'-comp_ytds$'2019'
##Handle Nulls
comp_ytds[is.na(diff_prior),diff_prior:=0]
comp_ytds[is.na(diff_base),diff_base:=0]

#POPUP
comp_ytds$popup<-paste("<b>HPD Beat: </b>", comp_ytds$Beat, "<br>", 
                       "<br>", "<b>Change from Last Year: </b>", comp_ytds$diff_prior,
                       "<br>", "<b>Change from 2019: </b>", comp_ytds$diff_base,
                       "<br>", "<b>Offense Count 2019: </b>", comp_ytds$'2019',
                       "<br>", "<b>Offense Count 2022: </b>", comp_ytds$'2022',
                       "<br>", "<b>Offense Count 2023: </b>", comp_ytds$'2023')

#Merge GeoJson to DataTable
##This filters to mappable beats from data.
beats_tab<-setDT(beats)
final<-comp_ytds[beats_tab,on=.(Beat=Beats)]
final[c(`2023`)][is.na(final[c(`2023`)])]<-0
final$crime_density<-final$`2023`/final$Area_sq_mi
final<- sf::st_as_sf(final)

#Get Bounds for custom bins
min_bin<-min(comp_ytds$diff_prior,na.rm=TRUE)
max_bin<-max(comp_ytds$diff_prior,na.rm=TRUE)

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
min_bin<-min(comp_ytds$diff_base,na.rm=TRUE)
max_bin<-max(comp_ytds$diff_base,na.rm=TRUE)

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