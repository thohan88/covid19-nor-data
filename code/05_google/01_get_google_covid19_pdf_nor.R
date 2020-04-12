source("code/utils.R")

tmpfile   <- tempfile(fileext = ".pdf")
tmpdir    <- tempdir()
file_name <- "https://www.gstatic.com/covid19/mobility/2020-04-05_NO_Mobility_Report_en.pdf"
download.file(file_name, tmpfile, mode = "wb")
pages_raw <- pdftools::pdf_split(tmpfile, tmpdir)

mob_raw <- pages_raw %>% 
  tibble(file_name = .) %>% 
  mutate(page = row_number()) %>% 
  slice(3:8) %>%  
  mutate(content = map(file_name, scrape_google_covid_pdf_page)) %>% 
  unnest(content)

# Get counties for merge
mun <- read_csv("https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.csv") %>% 
  group_by(fylke_no) %>% 
  summarise(fylke_name = first(fylke_name))

mob <- mob_raw %>% 
  mutate(y = (50-y)*1.6/100) %>%
  mutate(region = str_replace_all(region, c("Trondelag" = "Trøndelag", "Og" = "og"))) %>% 
  left_join(mun, by = c("region" = "fylke_name")) %>% 
  select(fylke_no, fylke_name = region, category, date, mob_change = y, mob_change_last = mob_change)

write_csv(mob, "data/20_mobility/google/mobility.csv")
write_xlsx(mob, "data/20_mobility/google/mobility.xlsx")
