############################## #
# Todo: Move all code for fetching data from MSIS to this repo
############################## #

source("code/utils.R")

#latest_scraping_kom_byd             <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_latest.RDS")
#latest_scraping_kom                 <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_latest_kommune.RDS")
complete_scraping_comp_kom_byd       <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_complete.RDS")
complete_scraping_comp_kom_byd_wide  <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_complete_wide.RDS")
complete_scraping_comp_kom           <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_complete_kommune.RDS")
complete_scraping_comp_kom_wide      <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_complete_wide_kommune.RDS")

#write_csv(latest_scraping_kom_byd,             "data/01_infected/msis/msis_latest_municipality_and_district.csv", na = "")
#write_csv(latest_scraping_kom,                 "data/01_infected/msis/msis_latest_municipality.csv", na = "")
write_csv(complete_scraping_comp_kom_byd,      "data/01_infected/msis/municipality_and_district.csv", na = "")
write_csv(complete_scraping_comp_kom_byd_wide, "data/01_infected/msis/municipality_and_district_wide.csv", na = "")
write_csv(complete_scraping_comp_kom,          "data/01_infected/msis/municipality.csv", na = "")
write_csv(complete_scraping_comp_kom_wide,     "data/01_infected/msis/municipality_wide.csv", na = "")

write_xlsx(complete_scraping_comp_kom_byd,      "data/01_infected/msis/municipality_and_district.xlsx")
write_xlsx(complete_scraping_comp_kom_byd_wide, "data/01_infected/msis/municipality_and_district_wide.xlsx")
write_xlsx(complete_scraping_comp_kom,          "data/01_infected/msis/municipality.xlsx")
write_xlsx(complete_scraping_comp_kom_wide,     "data/01_infected/msis/municipality_wide.xlsx")
