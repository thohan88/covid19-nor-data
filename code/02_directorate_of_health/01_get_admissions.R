source("code/utils.R")

admissions <- GET("https://api.helsedirektoratet.no/ProduktCovid19/Covid19statistikk/helseforetak",
                  add_headers(`Ocp-Apim-Subscription-Key` = Sys.getenv("HDIR_API_KEY"))) %>%
  content("text") %>%
  fromJSON(flatten = TRUE) %>%
  unnest(covidRegistreringer) %>%
  transmute(date            = ymd_hms(dato) %>% as.Date(),
            health_org_name = helseforetakNavn,
            region,
            admissions      = antInnlagte)

write_csv(admissions, "data/02_admissions/admissions.csv")
write_xlsx(admissions, "data/02_admissions/admissions.xlsx")

admissions_respirator <- GET("https://api.helsedirektoratet.no/ProduktCovid19/Covid19Statistikk/helseregion",
                             add_headers(`Ocp-Apim-Subscription-Key` = Sys.getenv("HDIR_API_KEY"))) %>%
  content("text") %>%
  fromJSON(flatten = TRUE) %>%
  unnest(registreringer) %>%
  transmute(date            = ymd_hms(dato) %>% as.Date(),
            health_reg_name = paste("Helse", navn),
            admissions      = antInnlagte,
            respirators     = antRespirator)

write_csv(admissions_respirator, "data/02_admissions/admissions_with_respirators.csv")
write_xlsx(admissions_respirator, "data/02_admissions/admissions_with_respirators.xlsx")
