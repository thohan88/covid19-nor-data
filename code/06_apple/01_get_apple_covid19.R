source("code/utils.R")

json_raw <- fromJSON("https://covid19-static.cdn-apple.com/covid19-mobility-data/current/v3/index.json")
data_url <- paste0("https://covid19-static.cdn-apple.com", json_raw$basePath, json_raw$regions$`en-us`$csvPath)

nor_labels <- c(
  "Norway",
  "Agder",
  "Innlandet",
  "Møre og Romsdal",
  "Nordland",
  "Oslo",
  "Rogaland",
  "Trøndelag",
  "Troms og Finnmark",
  "Vestfold og Telemark",
  "Vestland",
  "Viken")

mobility <- read_csv(data_url) %>% 
  filter(region %in% nor_labels) %>% 
  gather(date, val, matches("[0-9]{4}-[0-9]{2}-[0-9]{2}"))

write_csv(mobility, "data/20_mobility/apple/mobility.csv")
write_xlsx(mobility, "data/20_mobility/apple/mobility.xlsx")

