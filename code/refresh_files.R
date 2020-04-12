############################## #
# Refresh files
############################## #

files <- dir("code", full.names = TRUE, recursive = TRUE, pattern = "R$") %>%
  tibble(file_name = .) %>% 
  filter(!str_detect(file_name, "utils\\.R|refresh|lookup|help|google")) %>% 
  arrange(desc(row_number()))

foo <- map(files$file_name, source)

rmarkdown::render_site("docs")
rmarkdown::render(input       = here("docs", "examples", "01_case_dashboard", "index.Rmd"),
                  output_file = here("docs", "examples", "01_case_dashboard", "index.html"))
