library(gganimate)
library(ggspatial)
library(mapview)
library(RColorBrewer)
mapviewOptions(fgb = FALSE)

violent_crimes<-c('Aggravated Assault'
                  ,'Forcible rape'
                  ,'Robbery'
                  ,'Murder, non-negligent')

#violent_crimes<-c('Theft from motor vehicle')

#Maybe all 'major crimes' might be interesting for market basket analysis

city_raw<-read_sf('C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/COH_ADMINISTRATIVE_BOUNDARY_-_MIL/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.shp')
city<-city_raw$geometry
#plot(city)

# make a square grid over the countries
# Grids appear to be 500 meters 
grd<-st_make_grid( city
                  ,n = 200
                  ,square=FALSE)
#plot(grd)

# find which grid points intersect `polygons` (countries) 
# and create an index to subset from
index<-which(lengths(st_intersects(grd,city))>0)
# subset the grid to make a fishnet
houston_grid<-grd[index]
# visualize the fishnet
plot(houston_grid)

# DATA - Last Complete Year 2022
data_pre<-multi_year[ (NIBRSDescription %chin% violent_crimes)
                      &(RMSOccurrenceDate>=glue('2023-01-01'))
                      &(RMSOccurrenceDate<=glue('2023-11-30')),]%>%
  .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))] %>%
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)
#Look at 123 rows lost to no long/lati

lat_min<-min(data_pre$MapLatitude)
lat_max<-max(data_pre$MapLatitude)
lon_min<-min(data_pre$MapLongitude)
lon_max<-max(data_pre$MapLongitude)

# Join grid cells to incident data
#200 Grid - Drop 4057
incident_cells<-houston_grid%>%  
                st_as_sf() %>% # cast to sf
                mutate(grid_id=row_number()) %>% # create unique ID
                st_join(data_pre)%>%
                filter(grid_id!=4057) ## Drop Neighborless grid-cell - Empircally derived

# Summarize Incidents by grid-cell
# --Set nulls to zeros
sum_grid<-incident_cells%>%   
          group_by(grid_id)%>%
          summarise(n=sum(OffenseCount))%>%
          replace_na(list(n=0))

hist(sum_grid$n)

#-----

sum_grid$nb<-st_contiguity(sum_grid$x)
sum_grid$nn<-lengths(sum_grid$nb)

sum_grid$wt<-st_weights(sum_grid$nb)

sum_grid$n_lag<-st_lag(sum_grid$n,sum_grid$nb,sum_grid$wt)


pal<-rev(brewer.pal(5,'RdBu'))
sum_grid%>%ggplot(aes(fill = n_lag)) + 
  scale_fill_gradientn(colors=pal)+
  geom_sf(lwd = 0.1, color = "white")

# Omnibus Clustering test
global_g_test(sum_grid$n,sum_grid$nb,sum_grid$wt)

# Local Cluster detection
sum_grid$Gi<-local_g_perm(sum_grid$n,sum_grid$nb,sum_grid$wt,nsim=199)

# Visuals
spots<-sum_grid%>%unnest(Gi)

hs_cat <- spots %>% 
  select(gi, p_folded_sim) %>% 
  mutate(
    classification = case_when(
      gi > 0 & p_folded_sim <= 0.01 ~ "Very hot",
      gi > 0 & p_folded_sim <= 0.05 ~ "Hot",
      gi > 0 & p_folded_sim <= 0.1 ~ "Somewhat hot",
      gi < 0 & p_folded_sim <= 0.01 ~ "Very cold",
      gi < 0 & p_folded_sim <= 0.05 ~ "Cold",
      gi < 0 & p_folded_sim <= 0.1 ~ "Somewhat cold",
      TRUE ~ "Insignificant"
    ),
    # we now need to make it look better :) 
    # if we cast to a factor we can make diverging scales easier 
    classification = factor(
      classification,
      levels = c( "Very hot"
                 ,"Hot"
                 ,"Somewhat hot"
                 ,"Insignificant"
                 ,"Somewhat cold"
                 ,"Cold"
                 ,"Very cold")
    )
  ) 

# Interactive Map
hs_cat%>%
  mapview( zcol='classification'
          ,alpha.regions=0.5
          ,col.regions=brewer.pal(6,'RdBu')
          ,layer.name='Hot-Spot Level')

# Static Districts
hs_cat%>%ggplot(aes(fill = classification)) + 
  scale_fill_brewer(palette='RdBu')+
  geom_sf(lwd = 0.1, color = "white")+
  geom_sf( data=districts
          ,fill=NA
          ,linewidth=0.4
          ,color="black"
          )+geom_sf_label(data=districts,aes(fill=NULL,label=DISTRICT))+
  theme( axis.text.x=element_blank() 
        ,axis.ticks.x=element_blank() 
        ,axis.text.y=element_blank() 
        ,axis.ticks.y=element_blank()
        ,axis.title.x=element_blank()
        ,axis.title.y=element_blank())

# Static Districts
hs_cat%>%ggplot(aes(fill = classification)) + 
  scale_fill_brewer(palette='RdBu')+
  geom_sf(lwd = 0.1, color = "white")+
  geom_sf( data=districts
           ,fill=NA
           ,linewidth=0.4
           ,color="black"
  )+
  theme( axis.text.x=element_blank() 
         ,axis.ticks.x=element_blank() 
         ,axis.text.y=element_blank() 
         ,axis.ticks.y=element_blank()
         ,axis.title.x=element_blank()
         ,axis.title.y=element_blank())

##Create Animation Frames
