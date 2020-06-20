source("code/utils.R")
# Eventually move to schedule automatic updates
# Need to use a scaling factor to make sure shapes extracted from the PDF match up to y-axis used in report
# Appears to be consistent, but want one more test.

file_names <- c("https://www.gstatic.com/covid19/mobility/2020-03-29_NO_Mobility_Report_en.pdf",
                "https://www.gstatic.com/covid19/mobility/2020-04-05_NO_Mobility_Report_en.pdf",
                "https://www.gstatic.com/covid19/mobility/2020-04-11_NO_Mobility_Report_en.pdf")

latest_pdf <- read_html("https://www.google.com/covid19/mobility/") %>% 
  html_nodes(xpath = "//a[contains(@href, 'NO_Mobility_Report_en.pdf')]") %>%
  html_attr("href")

mob <- scrape_google_covid_pdf(latest_pdf)

write_csv(mob, "data/20_mobility/google/mobility.csv")
write_xlsx(mob, "data/20_mobility/google/mobility.xlsx")
