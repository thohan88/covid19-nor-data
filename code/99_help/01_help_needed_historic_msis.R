source("code/utils.R")

msis_raw <- readRDSurl("https://covidnor.blob.core.windows.net/public/msis/msis_infections_complete.RDS") %>% 
  select(date, kommune_bydel_no, kommune_bydel_name,cases) %>% 
  filter(date == min(date))

kommune_bydel <- msis_raw %>% select(kommune_bydel_no, kommune_bydel_name)

help_cases <- seq(ymd(20200226), max(msis_raw$date), by = 1) %>%
  tibble(date = .,
         kommune_bydel = list(kommune_bydel)) %>% 
  unnest(kommune_bydel) %>% 
  left_join(msis_raw %>% select(date, kommune_bydel_no, cases), by = c("date", "kommune_bydel_no")) %>% 
  spread(date, cases)

write_csv(help_cases, "data/99_help_wanted/historic_covid_cases.csv", na = "")
