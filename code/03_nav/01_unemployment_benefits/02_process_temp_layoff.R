source("code/utils.R")

dist_raw <- readRDS(here("code", "03_nav", "01_unemployment_benefits", "processed", "temporary_laid_off_districts_raw.RDS"))
mun_raw  <- readRDS(here("code", "03_nav", "01_unemployment_benefits", "processed", "temporary_laid_off_municipalities_raw.RDS"))
mapping  <- read_csv("https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities_districts.csv")

dist_mapped <- dist_raw %>% 
  left_join(mapping %>% select(kommune_bydel_no, bydel_name), by = c("district" = "bydel_name")) %>%
  mutate(kommune_bydel_no = ifelse(kommune_name == "Oslo" & district == "n/a", "030199", kommune_bydel_no)) %>% 
  filter(!is.na(kommune_bydel_no)) %>% 
  select(kommune_bydel_no, week, share, amount, total)

mun_mapped <- mun_raw %>% 
  filter(!kommune_no %in% c("0301", "1103", "4601", "5001")) %>% 
  left_join(mapping %>% select(kommune_no, kommune_bydel_no), by = c("kommune_no" = "kommune_no")) %>% 
  select(kommune_bydel_no, week, share, amount, total)

dist_mun <- dist_mapped %>% 
  bind_rows(mun_mapped) %>% 
  filter(week != "I alt")

applications_unemployment_benefits <- dist_mun %>% 
  left_join(mapping, by = "kommune_bydel_no") %>% 
  mutate(date_from = paste("2020", week, 1, sep = "-") %>% as.Date("%Y-%U-%u")-7,
         date_to   = date_from + 6,
         week      = paste(year(date_from), str_pad(isoweek(date_from), 2, "left", "0"), sep = "-")) %>% 
  select(week, date_from, date_to, kommune_bydel_no, kommune_bydel_name, kommune_no, kommune_name,
         fylke_no, fylke_name, unemployment_benefits_applications = amount, workforce = total, share)
  
write_csv(applications_unemployment_benefits, "data/10_employment/nav/applications_unemployment_benefits.csv", na = "")
write_xlsx(applications_unemployment_benefits, "data/10_employment/nav/applications_unemployment_benefits.xlsx")
