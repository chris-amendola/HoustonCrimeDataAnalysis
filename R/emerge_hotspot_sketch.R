df_fp <- system.file("extdata", "bos-ecometric.csv", package = "sfdep")
geo_fp <- system.file("extdata", "bos-ecometric.geojson", package = "sfdep")

# read in data
df <- read.csv(df_fp, colClasses = c("character", "character", "integer", "double", "Date"))
geo <- sf::st_read(geo_fp)

# Create spacetime object called `bos`
bos <- spacetime(df, geo,
                 .loc_col = ".region_id",
                 .time_col = "time_period")


# conduct EHSA
ehsa <- emerging_hotspot_analysis(
  x = bos,
  .var = "value",
  k = 1,
  nsim = 499
)

ehsa