library(tidyverse)
library(glue)
library(sf)
library(lubridate)
library(here)
library(sparkline)
library(DT)
library(leaflet)
library(htmlwidgets)
library(htmltools)
library(crosstalk)
library(summarywidget)

inf_raw     <- read_csv(here::here("data", "01_infected", "msis", "municipality_and_district.csv"))
inf_map_raw <- st_read(here::here("data", "00_lookup_tables_and_maps", "02_maps", "msis.geojson"), quiet = TRUE)

# Replace lines above with this if running externally
# inf_raw     <- read_csv("https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/01_infected/msis/municipality_and_district.csv")
# inf_map_raw <- st_read("https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/02_maps/msis.geojson", quiet = TRUE)

# Setup case table
inf <- inf_raw %>% 
  select(date, kommune_bydel_no, kommune_bydel_name, cases, population) %>% 
  arrange(kommune_bydel_no, date) %>% 
  group_by(kommune_bydel_no) %>% 
  mutate(new_cases = cases - lag(cases, 1)) %>% 
  ungroup() %>% 
  group_by(kommune_bydel_no, kommune_bydel_name) %>% 
  nest() %>% 
  ungroup() %>%
  mutate(cases_current = map(data, ~.x %>% select(cases, population) %>% slice(n())),
         cases_lag_1d  = map_dbl(data, ~.x %>%  slice(n()-1) %>% pull(cases)),
         cases_lag_5d  = map_dbl(data, ~.x %>%  slice(n()-5) %>% pull(cases)),
         cases_lag_10d = map_dbl(data, ~.x %>%  slice(n()-10) %>% pull(cases))) %>% 
  unnest(cases_current) %>% 
  mutate(cases_inc_1d        = cases - cases_lag_1d,
         cases_log           = log10(cases),
         cases_per_pop       = round(cases/population*1000, 1),
         doubling_time_1d    = round((1*log(2))/log(cases/cases_lag_1d), 1),
         doubling_time_5d    = round((5*log(2))/log(cases/cases_lag_5d), 1),
         doubling_time_10d   = round((10*log(2))/log(cases/cases_lag_10d), 1),
         sparkline_cases     = map(data, ~.x %>% slice((n()-14):n()) %>% pull(cases) %>% spk_chr(type="line", width = 120, height = 60)),
         sparkline_new_cases = map(data, ~.x %>% slice((n()-14):n()) %>% pull(new_cases) %>% spk_chr(type="bar", width = 120, barWidth = 18, height = 60))) %>% 
  mutate_at(vars(matches("doubling|log"), cases_per_pop), ~ifelse(is.na(.x) | is.infinite(.x) | is.nan(.x) | .x <= 0, NA, .x)) %>% 
  select(-data)

js <- "function(el,x) {
      $('head').append('<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">')
      this.on('popupopen', function() {HTMLWidgets.staticRender();});
      var updateLegend = function () {
          var selectedGroup = document.querySelectorAll('input:checked')[0].nextSibling.innerText.substr(1);

          document.querySelectorAll('.legend').forEach(a => a.hidden=true);
          document.querySelectorAll('.legend').forEach(l => {
            if (l.children[0].children[0].innerText == selectedGroup) l.hidden=false;
          });
      };
      updateLegend();
      this.on('baselayerchange', e => updateLegend());}"

generate_popup <- function(title, sparkline1, sparkline2, cases, population, cases_per_pop, cases_inc_1d, doubling_time_5d, doubling_time_10d) {
  tab <- 
    tibble(
      `New Cases` = c("<i>Last 14 days</>", sparkline2, " ", "Cases:", "Population", "Cases Per 1.000:", "New Cases (24h)", "5-day doubling rate", "10-day doubling rate"),
      `Total Cases` = c("<i>Last 14 days</>", sparkline1, " ", scales::number(cases), scales::number(population), cases_per_pop, cases_inc_1d, doubling_time_5d, doubling_time_10d)) %>%
    mutate_at(vars(`Total Cases`), ~ifelse(is.na(.x), "", .x)) %>% 
    knitr::kable("html", escape = FALSE) %>% 
    as.character() %>% 
    paste0("<h3>", title, "</h3>", .) %>% 
    paste0("<style> div.leaflet-popup-content {width:auto !important;}</style>", .) 
}

breaks_pop_grp  <- c(-1, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 5, 1000)
labels_pop_grp  <- c("0", "0 - 0.5", "0.5 - 1", "1 - 1.5", "1.5 - 2", "2 - 2.5", "2.5 - 3", "3 - 3.5", "3.5 - 5", ">5")
col_pop_grp     <- colorRampPalette(c("#ecda9a", "#ee4d5a"))(length(labels_pop_grp))
pal_pop_grp     <- colorFactor(col_pop_grp, levels = labels_pop_grp, na.color = "transparent")

breaks_inc_1d   <- c(-1, 0, 1, 3, 6, 10, 1000)
labels_inc_1d   <- c("0", "1", "2 - 3", "4 - 6", "7 - 10", "> 10")
col_inc_1d      <- colorRampPalette(c("#ecda9a", "#ee4d5a"))(length(labels_inc_1d))
pal_inc_1d      <- colorFactor(col_inc_1d, levels = labels_inc_1d, na.color = "transparent")


breaks_doubling <- c(-1, 0, 8, 14, 20, 35, 50, 10E5)
labels_doubling <- c("0", "1 - 8 days", "9 - 14 days", "15 - 20 days", "21 - 35 days", "36 - 50 days", "> 50 days")
col_doubling    <- colorRampPalette(c("#ee4d5a", "#ecda9a"))(length(labels_doubling))
pal_doubling    <- colorFactor(col_doubling, levels = labels_doubling, na.color = "transparent")

col_log         <- colorRampPalette(c("#ecda9a", "#ee4d5a"))(10)
pal_log         <- colorNumeric(col_log, inf$cases_log, na.color = "transparent")
lab_log         <- labelFormat(transform = function(x) 10^x)

inf_map_raw %>% 
  select(kommune_bydel_no) %>%
  inner_join(inf, by = "kommune_bydel_no") %>%
  mutate(cases_per_pop_grp   = cut(cases_per_pop, include.lowest = TRUE, breaks = breaks_pop_grp, labels = labels_pop_grp),
         cases_inc_1d_grp    = cut(cases_inc_1d, include.lowest = TRUE, breaks = breaks_inc_1d, labels = labels_inc_1d) %>% na_if(0),
         cases_doub_5d_grp   = cut(doubling_time_5d, include.lowest = TRUE, breaks = breaks_doubling, labels = labels_doubling) %>% na_if(0),
         cases_doub_10d_grp   = cut(doubling_time_10d, include.lowest = TRUE, breaks = breaks_doubling, labels = labels_doubling) %>% na_if(0),
         popup = pmap(list(kommune_bydel_name, sparkline_cases, sparkline_new_cases, cases,
                           population, coalesce(cases_per_pop,0), coalesce(cases_inc_1d,0), doubling_time_5d, doubling_time_10d), generate_popup)) %>%
  rename(`Total Cases`         = cases_log,
         `Per 1.000`           = cases_per_pop_grp,
         `New Cases`           = cases_inc_1d_grp,
         `Doubling rate (5d)`  = cases_doub_5d_grp,
         `Doubling rate (10d)` = cases_doub_10d_grp) %>% 
  leaflet() %>%
  addProviderTiles(providers$CartoDB) %>%
  addPolygons(fillColor   = ~pal_pop_grp(`Per 1.000`),
              group       = "Per 1.000",
              fillOpacity = 0.7,
              weight      = 1,
              label       = ~kommune_bydel_name,
              popup       = ~popup,
              color       = "grey") %>%
  addPolygons(fillColor   = ~pal_inc_1d(`New Cases`),
              group       = "New Cases",
              fillOpacity = 0.7,
              weight      = 1,
              label       = ~kommune_bydel_name,
              popup       = ~popup,
              color       = "grey") %>%
  addPolygons(fillColor   = ~pal_log(`Total Cases`),
              fillOpacity = 0.7,
              group       = "Total Cases",
              label       = ~kommune_bydel_name,
              popup       = ~popup,
              weight      = 1,
              color       = "grey") %>%
  addPolygons(fillColor   = ~pal_doubling(`Doubling rate (5d)`),
              fillOpacity = 0.7,
              group       = "Doubling rate (5d)",
              label       = ~kommune_bydel_name,
              popup       = ~popup,
              weight      = 1,
              color       = "grey") %>% 
  addPolygons(fillColor   = ~pal_doubling(`Doubling rate (10d)`),
              fillOpacity = 0.7,
              group       = "Doubling rate (10d)",
              label       = ~kommune_bydel_name,
              popup       = ~popup,
              weight      = 1,
              color       = "grey") %>% 
  addLegend(position= "bottomright",
            pal     = pal_pop_grp,
            values  = ~`Per 1.000`,
            group   = "Per 1.000") %>%
  addLegend(position= "bottomright",
            pal     = pal_inc_1d,
            values  = ~`New Cases`,
            group   = "New Cases") %>% 
  addLegend(position= "bottomright",
            pal     = pal_log,
            bins    = c(0, 1, 2, 3, 4),
            labFormat = lab_log,
            values  = ~`Total Cases`,
            group   = "Total Cases") %>%
  addLegend(position= "bottomright",
            pal     = pal_doubling,
            values  = ~`Doubling rate (5d)`,
            group   = "Doubling rate (5d)") %>% 
  addLegend(position= "bottomright",
            pal     = pal_doubling,
            values  = ~`Doubling rate (10d)`,
            group   = "Doubling rate (10d)") %>% 
  addLayersControl(baseGroups = c("Per 1.000", "Total Cases", "New Cases", "Doubling rate (5d)", "Doubling rate (10d)"), 
                   position = "topleft",
                   options = layersControlOptions(collapsed=TRUE)) %>%
  spk_add_deps() %>% 
  #onRender(js) %>% 
  addEasyButton(
    easyButton(
      icon = "fa-sign-out",
      title = "Back to covid19data.no",
      onClick = JS("function(){window.location.href = 'https://www.covid19data.no';}"))) %>% 
  saveWidget(here("docs", "examples", "02_case_map", "map.html"))


