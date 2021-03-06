source("code/utils.R")

##################################### #
# Get Excel-file ----
##################################### #

url <- read_html("https://www.nav.no/no/nav-og-samfunn/statistikk/flere-statistikkomrader/relatert-informasjon/soknader-om-dagpenger") %>% 
  html_nodes(xpath = "//li[./a[contains(text(), 'Søknader om dagpenger (')]]/a[2]") %>% 
  html_attr("href")

if (str_detect(url, "^/")) url <- paste0("https://www.nav.no", url)

tmpfile <- tempfile(fileext = ".xlsx")
download.file(url, tmpfile, mode = "wb")

##################################### #
# Bydel ----
##################################### #

stat_raw <- read_excel(tmpfile, sheet = "Bydel. Permitterte", col_names = FALSE)

hdr_rows <- which(str_detect(stat_raw$...1, "I alt"))-1
hdr_cols <- stat_raw[hdr_rows[1], ] %>% 
  gather(col_name, col_title) %>% 
  filter(!is.na(col_title)) %>% 
  mutate(grp = (lead(str_detect(col_title, "I alt"))*1) %>% coalesce(0) %>% cumsum)

col_name_grp1 <- hdr_cols$col_name[hdr_cols$grp==1]
col_name_grp2 <- hdr_cols$col_name[hdr_cols$grp==2]
col_title_grp1 <- hdr_cols$col_title[hdr_cols$grp==1]
col_title_grp2 <- hdr_cols$col_title[hdr_cols$grp==2]

temp_laid_off_district <- stat_raw %>% 
  mutate(region = str_extract(...1, '[0-9]{4} [A-Za-zæøåÆØÅ]+')) %>% 
  fill(region) %>% 
  filter(!is.na(region), ...1 != "I alt", ...1 != region) %>% 
  group_by(region) %>% 
  nest() %>% 
  ungroup() %>% 
  mutate(grp1 = map(data, select, col_name_grp1),
         grp2 = map(data, select, col_name_grp2)) %>% 
  mutate_at(vars(grp1, grp2), map, slice, -1) %>% 
  mutate(grp1 = map(grp1, set_names, col_title_grp1),
         grp2 = map(grp2, set_names, col_title_grp2)) %>% 
  select(-data) %>% 
  mutate_at(vars(grp1, grp2), ~map(.x, gather, key, district, -matches("(^[0-9]+$|I alt)"))) %>%
  mutate_at(vars(grp1, grp2), ~map(.x, gather, week, val, matches("(^[0-9]+$|I alt)"))) %>%
  mutate(data = map2(grp1, grp2, bind_rows)) %>% 
  select(region, data) %>% 
  unnest(data) %>%
  spread(key, val) %>% 
  separate(region, into = c("kommune_no", "kommune_name"), sep = " ") %>% 
  rename(share  = matches("Andel"),
         amount = matches("Antall")) %>%
  mutate_at(vars(share, amount), as.numeric) %>% 
  mutate(share = share/100,
         total = round(amount/share))
  
##################################### #
# Kommune ----
##################################### #

stat_raw <- read_excel(tmpfile, sheet = "Kommune. Permitterte", col_names = FALSE)

stat_start_cell <- stat_raw %>% 
  set_names(seq(names(.))) %>% 
  mutate(row = row_number()) %>% 
  select(row, everything()) %>% 
  gather(col, val, -row) %>%
  mutate_at(vars(col, row), as.numeric) %>% 
  filter(val == "I alt") %>% 
  filter(col == lag(col) + 1 | col == lag(col) + 2) %>%
  arrange(col) %>% 
  transmute(row,
            col_start = ifelse(row_number() == 1, 1, col-1),
            col_end   = ifelse(row_number() == 1, lead(col)-3, ncol(stat_raw)))

hdr_row1_cells <- stat_start_cell[stat_start_cell$col_start == min(stat_start_cell$col_start),]
hdr_row2_cells <- stat_start_cell[stat_start_cell$col_start == max(stat_start_cell$col_start),]

hdr_row1 <- stat_raw[hdr_row1_cells$row, hdr_row1_cells$col_start:hdr_row1_cells$col_end] %>% as.character()
hdr_row2 <- stat_raw[hdr_row2_cells$row, hdr_row2_cells$col_start:hdr_row2_cells$col_end] %>% as.character()

hdr_cols1 <- stat_raw[hdr_row1_cells$row, hdr_row1_cells$col_start:hdr_row1_cells$col_end] %>% 
  gather(col_name, col_title) %>% 
  filter(!is.na(col_title)) %>% 
  mutate(grp = (lead(str_detect(col_title, "I alt"))*1) %>% coalesce(0) %>% cumsum)

hdr_cols2 <- stat_raw[hdr_row2_cells$row, hdr_row2_cells$col_start:hdr_row2_cells$col_end] %>% 
  gather(col_name, col_title) %>% 
  filter(!is.na(col_title)) %>% 
  mutate(grp = (lead(str_detect(col_title, "I alt"))*1) %>% coalesce(0) %>% cumsum)

col_name_grp1 <- hdr_cols1$col_name
col_name_grp2 <- hdr_cols2$col_name
col_title_grp1 <- hdr_cols1$col_title
col_title_grp2 <- hdr_cols2$col_title

temp_laid_off_municipality <- stat_raw %>%
  nest(data = everything()) %>% 
  mutate(grp1 = map(data, ~select(.x, col_name_grp1) %>% set_names(col_title_grp1) %>% slice(hdr_row1_cells$row:n()))) %>%
  mutate(grp2 = map(data, ~select(.x, col_name_grp2) %>% set_names(col_title_grp2) %>% slice(hdr_row2_cells$row:n()))) %>%
  mutate_at(vars(grp1, grp2), map, ~mutate(.x, key = .x[[1]][1]) %>% slice(-1) %>% rename(region = 1) %>% gather(week, val, matches("(^[0-9]+$|I alt)"))) %>%
  mutate(data = map2(grp1, grp2, bind_rows)) %>% 
  select(data) %>% 
  unnest(data) %>% 
  add_count(key, region, key, week) %>% 
  arrange(desc(n), region, key) %>% 
  filter(!is.na(region), region != "I alt") %>% 
  spread(key, val) %>% 
  mutate(region = ifelse(region == "Ukjent", "9999 Ukjent", region)) %>% 
  separate(region, into = c("kommune_no", "kommune_name"), sep = " ") %>% 
  rename(share  = matches("Andel"),
         amount = matches("Antall")) %>%
  mutate_at(vars(share, amount), as.numeric) %>% 
  mutate(share = share/100,
         total = round(amount/share)) %>% 
  filter(str_detect(kommune_no, "[0-9]{4}"))

saveRDS(temp_laid_off_district, here("code", "03_nav", "01_unemployment_benefits", "processed", "temporary_laid_off_districts_raw.RDS"))
saveRDS(temp_laid_off_municipality, here("code", "03_nav", "01_unemployment_benefits", "processed", "temporary_laid_off_municipalities_raw.RDS"))

