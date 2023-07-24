
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

# Creating a color palette, with custom bins, based on differnce from prior year
pal <- colorBin( "RdYlBu"
                ,domain=final$OffenseCount
                ,c_bins
                ,pretty = FALSE)

leaflet() %>%
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

