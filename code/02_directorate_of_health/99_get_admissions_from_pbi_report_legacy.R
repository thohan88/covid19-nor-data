source("code/utils.R")

body <- enc2utf8('{"exportDataType":0,"executeSemanticQueryRequest":{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"d","Entity":"DimDato"},{"Name":"f","Entity":"Fact - Respirator"}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"d"}},"Property":"Dato"},"Name":"DimDato.Dato"},{"Column":{"Expression":{"SourceRef":{"Source":"f"}},"Property":"Region"},"Name":"Fact - Respirator.Region"},{"Aggregation":{"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"f"}},"Property":"AntRespirator"}},"Function":0},"Name":"Sum(Fact - Respirator.AntRespirator)"}],"OrderBy":[{"Direction":1,"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"d"}},"Property":"Dato"}}}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1,2],"Subtotal":0}]},"DataReduction":{"Primary":{"Top":{"Count":1000000}}},"Version":1}}},{"ExportDataCommand":{"Columns":[{"QueryName":"DimDato.Dato","Name":"Dato"},{"QueryName":"Fact - Respirator.Region","Name":"Helseregion"},{"QueryName":"Sum(Fact - Respirator.AntRespirator)","Name":"Antall"}],"Ordering":[0,1,2],"FiltersDescription":"No filters applied"}}]}}],"cancelQueries":[],"modelId":3163732,"userPreferredLocale":"en-US"},"artifactId":3278594}')

token <- read_html("https://www.helsedirektoratet.no/statistikk/antall-innlagte-pasienter-pa-sykehus-med-pavist-covid-19") %>% 
  html_text() %>% 
  str_extract("(?<=accessToken: ').+(?=',)")

tmp <- tempfile(fileext = ".xlsx")

req <- POST(url = "https://wabi-europe-north-b-redirect.analysis.windows.net/export/xlsx",
            httr::add_headers(
              `content-type` = "application/json;charset=UTF-8",
              authorization = paste("EmbedToken", token),
              accept = "application/json, text/plain, */*",
              `x-powerbi-user-groupid` = "efe3d571-e636-4998-8eeb-10a64da5550c",
              `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
              `accept-language` = "nb-NO,nb;q=0.9,no;q=0.8,nn;q=0.7,en-US;q=0.6,en;q=0.5"),
            body = body,
            write_disk(tmp))

admissions <- read_excel(tmp, skip = 2) %>% 
  transmute(date = as.Date(Dato), health_reg_name = Helseregion, admissions = Antall) %>% 
  arrange(date, health_reg_name)

write_csv(admissions, "data/02_admissions/admissions_with_respirators.csv")
write_xlsx(admissions, "data/02_admissions/admissions_with_respirators.xlsx")
