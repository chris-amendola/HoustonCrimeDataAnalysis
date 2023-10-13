library(gganimate)
library(ggspatial)
library(mapview)


#Maybe all 'major crimes' might be interesting for market basket analysis

city_raw<-read_sf('C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/COH_ADMINISTRATIVE_BOUNDARY_-_MIL/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.shp')
city<-city_raw$geometry
#plot(city)

# make a square grid over the countries
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
                      &(RMSOccurrenceDate<=glue('2023-08-31')),]%>%
  .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))] |>
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)
#Look at 123 rows lost to no long/lati

lat_min<-min(data_pre$MapLatitude)
lat_max<-max(data_pre$MapLatitude)
lon_min<-min(data_pre$MapLongitude)
lon_max<-max(data_pre$MapLongitude)

# Join grid cells to incident data
incident_cells<-houston_grid%>%  
                st_as_sf() |> # cast to sf
                mutate(grid_id=row_number()) |> # create unique ID
                st_join(data_pre)|>
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

sum_grid%>%ggplot(aes(fill = n_lag)) + 
  geom_sf(lwd = 0.1, color = "white")

# Omnibus Clustering test
global_g_test(sum_grid$n,sum_grid$nb,sum_grid$wt)

# Local Cluster detection
sum_grid$Gi<-local_g_perm(sum_grid$n,sum_grid$nb,sum_grid$wt,nsim=199)

spots<-sum_grid%>%unnest(Gi)

gg <- spots |> 
  select(gi, p_folded_sim) |> 
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
      levels = c("Very hot", "Hot", "Somewhat hot",
                 "Insignificant",
                 "Somewhat cold", "Cold", "Very cold")
    )
  ) |> 
  ggplot(aes(fill = classification)) +
  annotation_map_tile()+
  coord_sf(datum = NA)+
  geom_sf(color = "black", lwd = 0.1,inherit.aes = FALSE) +
  scale_fill_brewer(type = "div", palette = 5) +
  theme_void() +
  labs(
    fill = "Hot Spot Classification",
    title = "Violent Crime Hot Spots Houston- YTD August 2023"
  )

gg

function(){
## Emerging Hot-Spot Analysis
# Create spacetime object called `bos`

# Summarize Incidents by grid-cell
# --Set nulls to zeros
time_series<-incident_cells%>%  
  filter(grid_id!=4057)%>%
  group_by(grid_id,year_mon)%>%
  summarise(n=sum(OffenseCount))%>%
  replace_na(list(n=0))

# Geo-Data
geo_data<-sum_grid[c('grid_id','x')]|>
  filter(grid_id!=4057) ## Drop Neighborless grid-cell - Empircally derived

# Create Template Grid for Space-time cube
grid_id<-unique(time_series$grid_id)
year_mon<-sort(unique(time_series$year_mon))

cube_grid<-expand_grid(grid_id,year_mon)

# Merge aggregate time series to cube template
pre_cube<-merge( cube_grid
                ,time_series
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

# conduct EHSA
ehsa <- emerging_hotspot_analysis(
  x = cube,
  .var = "n",
  k = 1,
  nsim = 9
)

ehsa}