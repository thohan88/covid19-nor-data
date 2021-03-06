source("code/utils.R")

############################## #
# Refresh data
############################## #

source_possibly <- possibly(source, otherwise = "NA")
py_run_possibly <- possibly(reticulate::py_run_file, otherwise = "NA")

files_data <- dir("code", full.names = TRUE, recursive = TRUE, pattern = "R$") %>%
  tibble(file_name = .) %>% 
  filter(!str_detect(file_name, "utils\\.R|refresh|lookup|help|google|_api|_legacy\\.R")) %>% 
  arrange(desc(row_number()))

foo <- map(files_data$file_name, source_possibly)

py_run_possibly("code/03_nav/02_wage_compensation/01_get_wage_compensation.py")
py_run_possibly("code/04_fhi_daily_reports/01_get_number_of_tests.py")
py_run_possibly("code/04_fhi_daily_reports/02_get_number_of_deaths.py")
py_run_possibly("code/05_google/01_get_google_covid19.py")
py_run_possibly("code/07_tax_administration/01_get_business_compensation_scheme.py")

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
