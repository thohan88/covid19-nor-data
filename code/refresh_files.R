source("code/utils.R")

############################## #
# Refresh data
############################## #

source_possibly <- possibly(source, otherwise = "NA")

files_data <- dir("code", full.names = TRUE, recursive = TRUE, pattern = "R$") %>%
  tibble(file_name = .) %>% 
  filter(!str_detect(file_name, "utils\\.R|refresh|lookup|help|google|_api\\.R")) %>% 
  arrange(desc(row_number()))

foo <- map(files_data$file_name, source_possibly)

reticulate::py_run_file("code/05_google/01_get_google_covid19.py")

############################## #
# Refresh examples
############################## #

render(input       = here("docs", "examples", "01_case_dashboard", "index.Rmd"),
       output_file = here("docs", "examples", "01_case_dashboard", "index.html"))

render(input       = here("docs", "examples", "02_case_map", "index.Rmd"),
       output_file = here("docs", "examples", "02_case_map", "index.html"))

############################## #
# Refresh site
############################## #

render_site("docs")

############################## #
# Refresh readme
############################## #

render(input = here("README.Rmd"), output_file = here("README.md"))