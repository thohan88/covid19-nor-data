############################## #
# Todo: Move code for generating these tables to another repo
############################## #

source("code/utils.R")

mun_dist <- readRDSurl("https://covidnor.blob.core.windows.net/public/mapping/kommune_bydel.RDS")
mun      <- readRDSurl("https://covidnor.blob.core.windows.net/public/mapping/kommune.RDS")
msis     <- readRDSurl("https://covidnor.blob.core.windows.net/public/mapping/msis.RDS")
pop      <- readRDSurl("https://covidnor.blob.core.windows.net/public/ssb/population.RDS")

mun_dist_pop <- mun_dist %>% 
  left_join(pop %>% select(kommune_bydel_no, population), by = "kommune_bydel_no")

mun_pop <- mun %>% 
  left_join(pop %>% count(kommune_no, wt = population, name = "population_kommune"), by = "kommune_no")

msis_pop <- msis %>% 
  left_join(pop %>% select(kommune_bydel_no, population), by = "kommune_bydel_no") %>% 
  left_join(pop %>% count(kommune_no, wt = population, name = "population_kommune"), by = "kommune_no") %>% 
  mutate(population = coalesce(population, population_kommune)) %>% 
  select(-population_kommune)


write_csv(mun_dist_pop,  "data/00_lookup_tables_and_maps/01_lookup_tables/municipalities_districts.csv", na = "")
write_csv(mun_pop,       "data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.csv", na = "")
write_csv(msis_pop,      "data/00_lookup_tables_and_maps/01_lookup_tables/msis.csv", na = "")

write_xlsx(mun_dist_pop, "data/00_lookup_tables_and_maps/01_lookup_tables/municipalities_districts.xlsx")
write_xlsx(mun_pop,      "data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.xlsx")
write_xlsx(msis_pop,     "data/00_lookup_tables_and_maps/01_lookup_tables/msis.xlsx")

