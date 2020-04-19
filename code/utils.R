library(tidyverse)
library(AzureStor)
library(lubridate)
library(rvest)
library(readxl)
library(here)
library(sf)
library(writexl)
library(glue)
library(pdftools)
library(pbapply)
library(jsonlite)
library(gt)
library(httr)
library(rmarkdown)

##################################### #
# Process ----
##################################### #

readRDSurl <- function(url, cont) {
  tmpfile <- tempfile(fileext = "RDS")
  download.file(url, tmpfile, mode = "wb")
  readRDS(tmpfile)
}

##################################### #
# Get metadata for all tables ----
##################################### #

get_table_data <- function(file_meta) {
  
  sources     <- fromJSON(file_meta) %>% as_tibble()
  
  dl_base     <- "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/"
  git_base    <- "https://github.com/thohan88/covid19-nor-data/tree/master/"
  pr_base     <- "https://github.com/thohan88/covid19-nor-data/blob/master/"
  dl_table    <- function(csv_link, xlsx_link) glue('<a href = "{dl_base}{csv_link}">csv</a> <a href = "{dl_base}{xlsx_link}">xlsx</a>')
  dl_map      <- function(geojson) glue('<a href = "{dl_base}{geojson}">geojson</a>')
  pr_table    <- function(csv_link) glue('<a href = "{pr_base}{csv_link}"><span class="fa fa-search"></span></a>')
  pr_map      <- function(geojson) glue('<a href = "{pr_base}{geojson}"><span class="fa fa-search"></span></a>')
  
  files <- dir(here("data"), recursive = TRUE) %>% 
    paste0("data/", .) %>% 
    tibble(file_name = .) %>% 
    mutate(file_name_sans_ext = tools::file_path_sans_ext(file_name),
           folder             = dirname(file_name_sans_ext),
           basename           = basename(file_name_sans_ext), 
           extension          = tools::file_ext(file_name)) %>% 
    mutate(file_name = str_replace_all(file_name, "\\.\\./", "")) %>% 
    spread(extension, file_name) %>% 
    mutate(label    = case_when(str_detect(file_name_sans_ext, "/municipalities$")   ~ "Municipalities",
                                str_detect(file_name_sans_ext, "/municipalities_districts$") ~ "Municipalities and districts",
                                str_detect(file_name_sans_ext, "/msis$")             ~ "MSIS regions",
                                str_detect(file_name_sans_ext, "/02_maps/")          ~ "Maps",
                                str_detect(file_name_sans_ext, "/01_lookup_tables/") ~ "Lookup tables",
                                str_detect(file_name_sans_ext, "/01_infected/")      ~ "Infected",
                                str_detect(file_name_sans_ext, "admissions_with")    ~ "In respirator",
                                str_detect(file_name_sans_ext, "/02_admissions/")    ~ "Admissions",
                                str_detect(file_name_sans_ext, "/03_covid_tests/")   ~ "Covid tests",
                                str_detect(file_name_sans_ext, "/google")            ~ "Google Mobility",
                                str_detect(file_name_sans_ext, "/apple")             ~ "Apple Mobility",
                                str_detect(file_name_sans_ext, "/10_employment/")    ~ "Unemployment benefits")) %>% 
    left_join(sources, by = "label") %>% 
    mutate(category = case_when(str_detect(file_name_sans_ext, "/02_maps/")          ~ "Maps",
                                str_detect(file_name_sans_ext, "/01_lookup_tables/") ~ "Lookup tables",
                                TRUE                                                 ~ category),
           download = case_when(category %in% c("Healthcare", "Mobility", "Economics", "Lookup tables") ~ map2_chr(csv, xlsx, dl_table),
                                category %in% c("Lookup tables", "Maps")                     ~ map_chr(geojson, dl_map)),
           preview  = case_when(category %in% c("Healthcare", "Mobility", "Economics", "Lookup tables") ~ map_chr(csv, pr_table),
                                category %in% c("Lookup tables", "Maps")                     ~ map_chr(geojson, pr_map)),
           github   = glue('<a href = "{git_base}{folder}"><span class="fa fa-github"></span></a>'),
           updated = format(Sys.Date(), "%Y-%m-%d"),
           category = fct_relevel(as.factor(category), "Healthcare", "Mobility", "Economics", "Lookup tables", "Maps"),
           label    = fct_relevel(as.factor(label), "Infected", "Admissions", "In respirator", "Covid tests", 
                                  "Municipalities", "Municipalities and districts", "MSIS regions")) %>% 
    arrange(category, label)
}

##################################### #
# Print source table ----
##################################### #

print_source_tbl <- function(tbl) {
  tbl %>% 
    mutate(source = map2_chr(link, source, ~glue("<a href = \"{.x}\">{.y}</a>"))) %>% 
    mutate(meta = pmap(list(freq, level, source, preview, github, download),
                       ~tibble(key = c("Frequency:", "Level:", "Source:", "Preview:", "Github:", "Download:"),
                               val = c(..1, ..2, ..3, ..4, ..5, ..6)) %>%
                         knitr::kable("html", escape = FALSE, col.names = NULL, table.attr = "class=\"inline_source_tbl\"")), 
           desc = paste0(meta, "<br>", desc)) %>%
    select(label, desc) %>%
    mutate(desc = map(desc, htmltools::HTML)) %>% 
    gt(groupname_col = "label") %>% 
    tab_options(table.width = pct(100),
                column_labels.hidden = TRUE,
                data_row.padding = px(15),
                table.border.top.style = "hidden",
                table.border.bottom.style = "hidden",
                row.striping.include_table_body = FALSE) %>% 
    tab_style(style = list(
      cell_borders(sides = c("top", "bottom"), color = "#DEE2E5", weight = px(1)),
      cell_fill(color = "#ecf0f1")),
      locations = list(cells_row_groups())) %>%
    tab_style(
      style = list(cell_borders(sides = c("top", "bottom"), color = "#DEE2E5", weight = px(1))),
      locations = list(cells_body())) %>% 
    cols_align(align = c("left"), columns = vars(desc))
}

##################################### #
# SCrape Google Mobility Reports ----
##################################### #

scrape_google_covid_pdf <- function(file_name) {
  
  tmpfile   <- tempfile(fileext = ".pdf")
  tmpdir    <- tempdir()
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
  
}

scrape_google_covid_pdf_page <- function(pdf_file) {
  
  raw_file  <- tempfile(fileext = ".txt")
  system(glue('qpdf -qdf {pdf_file} {raw_file}'))
  
  pdf_raw   <- read_file(raw_file)
  pdf_text  <- pdf_text(pdf_file)
  
  categories <- c("Transit stations", "Workplace", "Residential", "Grocery & pharmacy", "Parks", "Workplace", "Retail & recreation")
  
  pdf_plot_meta <- pdf_text %>%
    str_split("\\n") %>%
    chuck(1) %>% 
    str_trim() %>% 
    tibble(line = .) %>% 
    # Remove disclaimer for missing data
    filter(!str_detect(line, "Not enough data for |needs a significant volume")) %>% 
    # Get rid of axis lines
    filter(!str_detect(line, "^Baseline|((\\+|-)[0-9]{1,3}% *){3}")) %>%
    # Get rid of insufficent data asterix (may reintroduce later)
    filter(line != "*") %>% 
    # Split each line in to columns based on number of spaces
    separate(line, into = c("1","2","3"), sep = " {5,100}", fill = "right") %>%
    # May not be necessary
    mutate_all(str_trim) %>% 
    # If only one column and does not start with * => Assume entry is region
    mutate(region = ifelse(`1` != "*" & is.na(`2`) & is.na(`3`), `1`, NA)) %>% 
    # Fill down region
    fill(region) %>% 
    # Remove original region entry
    filter(`1` != region) %>% 
    # Generate a row index (useful for sorting)
    mutate(row = row_number()) %>% 
    # Gather columns into row
    gather(col, val, -region, -row) %>%
    # Make sure we process by columns
    arrange(region, col, row) %>% 
    # Add categry
    mutate(category = ifelse(val %in% categories, val, NA)) %>% 
    # Fill category down
    fill(category) %>% 
    mutate(date_from  = str_extract(val, "^[A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2}"),
           date_to    = str_extract(val, "[A-Za-z]{3} [A-Za-z]{3} [0-9]{1,2}$"),
           mob_change = str_extract(val, "(\\+|-)[0-9]{1,3}(?=% compared to baseline)") %>% as.numeric()/100) %>% 
    group_by(region, category) %>% 
    mutate_at(vars(date_from, date_to, mob_change), min, na.rm = TRUE) %>%
    ungroup() %>% 
    distinct(region, category, .keep_all = TRUE) %>% 
    arrange(region, row, col) %>% 
    select(region, category, date_from, date_to, mob_change) %>% 
    mutate_at(vars(date_from, date_to), ~str_replace_all(.x, "^[A-Za-z]{3} ", "") %>% paste(year(Sys.Date())) %>% mdy())
  
  pdf_plot_content <- read_file(raw_file) %>% 
    str_extract_all("(?<=\\n).+ (l|cm|m)(?=\\n)") %>% 
    .[[1]] %>% 
    tibble(line  = .) %>%
    mutate(type  = str_extract(line, "(cm|l|m)"),
           coord = ifelse(type %in% c("l", "m"), line, NA),
           patch = ifelse(type == "m", line, NA),
           trans = ifelse(type == "cm", line, NA)) %>% 
    fill(trans, patch) %>% 
    filter(!is.na(coord)) %>% 
    mutate(coord_tbl = map(coord, ~str_extract_all(.x, "[0-9\\.-]+") %>% .[[1]] %>% map(as.numeric))) %>% 
    mutate(coord_tbl = map(coord_tbl, ~tibble(x = .x[[1]], y = .x[[2]]))) %>%
    unnest(coord_tbl)
  
  pdf_plot_data <- pdf_plot_content %>%
    filter(!str_detect(patch, "0 m")) %>%
    group_by(trans) %>% 
    nest() %>% 
    ungroup() %>% 
    filter(abs(map_dbl(data, nrow) - median(map_dbl(data, nrow)))<=4) %>% 
    select(trans) %>%
    mutate(row = row_number()) %>%
    left_join(pdf_plot_content, by = "trans") %>%
    arrange(trans, x) %>%
    filter(!(x == 0 & y == 0) & !(x == 200 & y == 0)) %>%
    complete(trans, x) %>% 
    arrange(row) %>% 
    select(trans, x, y) %>% 
    group_by(trans) %>% 
    nest() %>% 
    ungroup()
  
  pdf_plot_meta %>%
    bind_cols(pdf_plot_data) %>% 
    mutate(dates = map2(date_from, date_to, ~seq(.x, .y, 1) %>% tibble(date = .)),
           data  = map2(data, dates, ~bind_cols(.x, .y) %>% select(date, y))) %>% 
    select(region, category, mob_change, data) %>% 
    unnest(data)
}

