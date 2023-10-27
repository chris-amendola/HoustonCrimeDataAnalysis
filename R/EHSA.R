library(ggspatial)

# HEX GRID HOUSTON
city_raw<-read_sf('C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/COH_ADMINISTRATIVE_BOUNDARY_-_MIL/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.shp')
city<-city_raw$geometry
#plot(city)

# make a square grid over the countries
grd<-st_make_grid( city
                   ,n = 200
                   ,square=FALSE)
#plot(grd)

# find which grid points intersect `polygons` 
# and create an index to subset from
index<-which(lengths(st_intersects(grd,city))>0)
# subset the grid to make a fishnet
houston_grid<-grd[index]
# visualize the fishnet
plot(houston_grid)

# DATA PREP
# YTD
data_pre<-multi_year[ (NIBRSDescription %chin% violent_crimes)
                      &(RMSOccurrenceDate>=glue('2022-01-01'))
                      &(RMSOccurrenceDate<=glue('2023-08-31')),]%>%
  .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))] |>
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)
#Look at 123 rows lost to no long/lati

#Usefull later
lat_min<-min(data_pre$MapLatitude)
lat_max<-max(data_pre$MapLatitude)
lon_min<-min(data_pre$MapLongitude)
lon_max<-max(data_pre$MapLongitude)

# 'Fill-in' Grids with summary
incident_cells<-houston_grid%>%  
  st_as_sf() |> # cast to sf
  mutate(grid_id=row_number()) |> # create unique ID
  st_join(data_pre)|>
  filter(grid_id!=4057) ## Drop Neighborless grid-cell - Empircally derived

# Unique Grid Geometry
geo_data<-unique(incident_cells[c('grid_id','x')])|>
  filter(grid_id!=4057) ## Drop Neighborless grid-cell - Empircally derived


# Summarize Incidents by grid-cell
# --Set nulls to zeros
sum_grid<-incident_cells|>
          filter(grid_id!=4057)|>
          group_by(grid_id,year_mon)|>
          summarise(n=sum(OffenseCount))|>
          replace_na(list(n=0))

hist(sum_grid$n)

## Emerging Hot-Spot Analysis
# Create spacetime object 
# Create Template Grid for Space-time cube
grid_id<-unique(sum_grid$grid_id)
year_mon<-sort(unique(sum_grid$year_mon))

cube_grid<-expand_grid(grid_id,year_mon)

# Merge aggregate time series to cube template
pre_cube<-merge( cube_grid 
                 ,sum_grid
                 ,by=c( 'grid_id'
                        ,'year_mon')
                 ,all.x=TRUE)

pre_cube$n[is.na(pre_cube$n)]<-0

# Create Spacetime Cube
cube<-spacetime( pre_cube
                 ,geo_data
                 ,.loc_col="grid_id"
                 ,.time_col="year_mon")

is_spacetime_cube(cube)

remove(pre_cube)

# conduct EHSA
print('Begin EHSA...')
print(Sys.time())
ehsa <- emerging_hotspot_analysis(
  x = cube,
  .var = "n",
  k = 1,
  nsim = 99
)

ehsa
print('EHSA DONE.')
print(Sys.time())

#remove(ehsa)
head(cube)
