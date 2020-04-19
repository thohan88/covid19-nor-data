source("code/utils.R")

##################################### #
# Get PDFS from FHI (current and archive) ----
##################################### #

html_curr_raw <- read_html("https://www.fhi.no/sv/smittsomme-sykdommer/corona/dags--og-ukerapporter/dags--og-ukerapporter-om-koronavirus/")
html_arch_raw <- read_html("https://www.fhi.no/sv/smittsomme-sykdommer/corona/dags--og-ukerapporter/arkiv-dags--og-ukerapporter/")

pdf_curr_links <- html_curr_raw %>% 
  html_nodes(xpath = "//a[contains(@href, '.pdf') and contains(@href, 'dagsrapport')]") %>% 
  html_attr("href") %>% 
  tibble(url = .)

pdf_arch_links <- html_arch_raw %>% 
  html_nodes(xpath = "//a[contains(@href, '.pdf') and contains(@href, 'dagsrapport')]") %>% 
  html_attr("href") %>% 
  tibble(url = .)

pdf_links <- pdf_curr_links %>% 
  bind_rows(pdf_arch_links) %>% 
  mutate(url = paste0("https://www.fhi.no/", url),
         date     = str_sub(basename(url), 1, 10) %>% ymd()) %>% 
  arrange(desc(date)) %>% 
  select(date, url)

pdfs_raw <- pdf_links %>% 
  mutate(pdf_page = pblapply(url, function(x) pdf_split(x) %>% tibble(pages = .)),
         pdf_text = pblapply(url, pdf_text)) %>% 
  select(date, pdf_page, pdf_text)

##################################### #
# Get total test figures ----
##################################### #

regex_tests <- "(?<=[tT]otalt )[0-9 ]+.(?= er rapportert)|(?<=Totalt )[0-9 ]+.(?= personer er)"

national_tests <- pdfs_raw %>%
  mutate(pdf_all_text = map_chr(pdf_text, ~paste0(.x, collapse = "\\n")),
         n_tests_cumulative = str_extract(pdf_all_text, regex_tests) %>% str_replace_all(" ", "") %>% as.numeric) %>% 
  filter(!is.na(n_tests_cumulative)) %>% 
  mutate(n_tests  = n_tests_cumulative - lead(n_tests_cumulative),
         week     = isoweek(date) %>% as.character(),
         wday_txt = format(date, "%a"),
         wday_num = format(date, "%u") %>% as.numeric) %>% 
  filter(!is.na(n_tests_cumulative)) %>% 
  select(date, n_tests, n_tests_cumulative)

write_csv(national_tests,  "data/03_covid_tests/national_tests.csv", na = "")
write_xlsx(national_tests, "data/03_covid_tests/national_tests.xlsx")

##################################### #
# Get regional test figures (Only consecutive series since 31st of March in reports.
# FHI stopped reporting this on the 12th of April  ----
##################################### #

repl_region <- c("Helse" = "Region", " Øst " = " Sør-Øst ", "Sør - Øst" = "Sør-Øst", " Sør " = " Sør-Øst ")

regional_tests <- pdfs_raw %>% 
  mutate(pdf_all_text = map_chr(pdf_text, ~paste0(.x, collapse = "\\n"))) %>%
  mutate(pdf_all_text = str_replace_all(pdf_all_text, "Region\\n *(?=(Sør-Øst|Vest|Midt|Nord|Øst|Sør))", "Region ")) %>% 
  mutate(test_string = map(pdf_all_text, ~str_extract_all(.x, "Region (Sør-Øst|Vest|Midt|Nord|Øst|Sør).+") %>% .[[1]] %>% tibble(test_string = .))) %>% 
  unnest(test_string) %>% 
  select(date, test_string)  %>% 
  mutate(test_string = str_replace_all(test_string, repl_region)) %>% 
  separate(test_string, into = c("region", "tests_cumulative", "positives_cumulative"), sep = " {2,50}", extra = "drop") %>% 
  mutate_at(vars(tests_cumulative, positives_cumulative), ~str_replace_all(.x, c(" |%" = "", "," = ".")) %>% as.numeric) %>% 
  group_by(date, region) %>% 
  summarise_at(vars(tests_cumulative, positives_cumulative), sum, na.rm = TRUE) %>% 
  ungroup() %>% 
  arrange(desc(date)) %>% 
  group_by(region) %>% 
  mutate(tests     = tests_cumulative - lead(tests_cumulative,1),
         positives = positives_cumulative - lead(positives_cumulative, 1),
         days_between_dates = as.numeric(date - lead(date, 1))) %>% 
  ungroup() %>% 
  mutate(tests = ifelse(days_between_dates == 1, tests, NA),
         positives = ifelse(days_between_dates == 1, positives, NA)) %>% 
  select(date, region, n_tests = tests, n_positives = positives, n_tests_cumulative = tests_cumulative, n_positives_cumulative = positives_cumulative) %>% 
  filter(date <= ymd(20200411))

write_csv(regional_tests,  "data/03_covid_tests/regional_tests.csv", na = "")
write_xlsx(regional_tests, "data/03_covid_tests/regional_tests.xlsx")
