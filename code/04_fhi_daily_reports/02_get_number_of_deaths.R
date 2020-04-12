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
  mutate(pdf_text = pblapply(url, pdf_text),
         pdf_all_text = map_chr(pdf_text, ~paste0(.x, collapse = "\\n"))) %>% 
  select(date, pdf_all_text)

##################################### #
# Get total test figures ----
##################################### #

deaths <- pdfs_raw %>%
  mutate(deaths = str_extract(pdf_all_text, "[0-9 ]{1,4}(?= dødsfall)") %>% str_replace_all(" ", "") %>% as.numeric()) %>% 
  select(date, deaths)

write_csv(deaths,  "data/04_deaths/deaths_total_fhi.csv", na = "")
write_xlsx(deaths, "data/04_deaths/deaths_total_fhi.xlsx")