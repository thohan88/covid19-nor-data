############################## #
# Todo: Move code for generating these tables to another repo
############################## #

source("code/utils.R")

mun_dist <- readRDSurl("https://covidnor.blob.core.windows.net/public/maps/kommune_bydel_very_low.RDS")
mun      <- readRDSurl("https://covidnor.blob.core.windows.net/public/maps/kommune_very_low.RDS")
msis     <- readRDSurl("https://covidnor.blob.core.windows.net/public/maps/msis_very_low.RDS")

st_write(mun_dist,  "data/00_lookup_tables_and_maps/02_maps/municipalities_districts.geojson", delete_dsn = TRUE)
st_write(mun,       "data/00_lookup_tables_and_maps/02_maps/municipalities.geojson", delete_dsn = TRUE)
st_write(msis,      "data/00_lookup_tables_and_maps/02_maps/msis.geojson", delete_dsn = TRUE)
