#Maybe all 'major crimes' migh be interesting for market basket analysis


city_raw<-read_sf('C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/COH_ADMINISTRATIVE_BOUNDARY_-_MIL/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.shp')
city<-city_raw$geometry
#plot(city)

# make a square grid over the countries
grd<-st_make_grid( city
                  ,n = 200,square=FALSE)
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
                      &(RMSOccurrenceDate>=glue('2022-01-01'))
                      &(RMSOccurrenceDate<=glue('2022-12-31')),]%>%
  .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))]%>%
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)
#Look at 123 rows lost to no long/lati

# Join grid cells to incident data
incident_cells<-houston_grid%>%  
                st_as_sf()%>% # cast to sf
                mutate(grid_id=row_number())%>% # create unique ID
                st_join(data_pre) 

# Summarize Incidents by grid-cell
sum_grid<-incident_cells%>%   
          group_by(grid_id)%>%
          summarise(n=sum(OffenseCount))

# Plot by the number of points in the grid
prep_plot<-sum_grid%>%ggplot(aes(fill = n)) + 
             # formatting 
             geom_sf(lwd = 0.1, color = "black")+
  scale_fill_gradientn(
    colors = c("#9DBF9E", "#FCB97D", "#A84268")
  )


prep_plot
