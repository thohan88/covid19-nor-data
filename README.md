Public COVID-19 Data for Norway (covid19data.no)
================================================

### Motivation

The current state of publicly available data about the
COVID-19-situtation in Norway is a mix of
[PDF-reports](https://www.fhi.no/sv/smittsomme-sykdommer/corona/dags--og-ukerapporter/dags--og-ukerapporter-om-koronavirus/),
[Excel-files](https://www.nav.no/no/nav-og-samfunn/statistikk/arbeidssokere-og-stillinger-statistikk/permitterte),
[Power
BI-dashboards](https://www.helsedirektoratet.no/statistikk/antall-innlagte-pasienter-pa-sykehus-med-pavist-covid-19)
and public registries. Further, much of the data is only released as
cumulative statistics at aggregated levels
(e.g. [MSIS](http://www.msis.no/)). The absence of detailed data has
created a market for media outlets to release local “situation reports”
behind paywalls (see:
[Aftenposten](https://www.aftenposten.no/norge/i/K3mnr4/i-det-meste-av-landet-bremser-viruset-opp-i-oslo-sprer-det-seg-raskt-fra-bydel-til-bydel)).
This project is a an open-source effort to make data about the Covid-19
situtation in Norway available to the public in a timely and coherent
manner. Data is updated daily from official sources such as The
Institute of Public Health and Norwegian Directorate of Health.

### Contributing to the project

This project is a collaborative and voluntary effort and we would love
your help. Please get in touch.

### Examples: Use of data

[![Case
Dashboard](docs/img/MSIS_dashboard_full.PNG)](https://www.covid19data.no/examples/01_case_dashboard/)
The [Case
Dashboard](https://www.covid19data.no/examples/01_case_dashboard/) and
[Case Map](https://www.covid19data.no/examples/02_case_map/) illustrates
how the data can potentially be used. These examples show current
Covid-19 Cases in Norway at municipality and district-level reported to
the Norwegian Surveillance System for Communicable Diseases (MSIS) with
fully available source code.

### Available data

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Category</th>
<th style="text-align: left;">Data</th>
<th style="text-align: left;">Source</th>
<th style="text-align: left;">Updated</th>
<th style="text-align: left;">Download</th>
<th style="text-align: left;">Preview</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">Infected</td>
<td style="text-align: left;">MSIS</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/01_infected/msis/municipality_and_district.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/01_infected/msis/municipality_and_district.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/01_infected/msis/municipality_and_district.csv">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">Admissions</td>
<td style="text-align: left;">Directorate of Health</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/02_admissions/admissions.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/02_admissions/admissions.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/02_admissions/admissions.csv">preview</a></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">In respirator</td>
<td style="text-align: left;">Directorate of Health</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/02_admissions/admissions_with_respirators.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/02_admissions/admissions_with_respirators.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/02_admissions/admissions_with_respirators.csv">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">Covid tests</td>
<td style="text-align: left;">FHI</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/03_covid_tests/national_tests.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/03_covid_tests/national_tests.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/03_covid_tests/national_tests.csv">preview</a></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">Covid deaths</td>
<td style="text-align: left;">FHI</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/04_deaths/deaths_total_fhi.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/04_deaths/deaths_total_fhi.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/04_deaths/deaths_total_fhi.csv">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Mobility</td>
<td style="text-align: left;">Apple Mobility</td>
<td style="text-align: left;">Apple</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/20_mobility/apple/mobility.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/20_mobility/apple/mobility.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/20_mobility/apple/mobility.csv">preview</a></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Mobility</td>
<td style="text-align: left;">Google Mobility</td>
<td style="text-align: left;">Google</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/20_mobility/google/mobility.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/20_mobility/google/mobility.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/20_mobility/google/mobility.csv">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Mobility</td>
<td style="text-align: left;">Google Mobility</td>
<td style="text-align: left;">Google</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/20_mobility/google/mobility_national.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/20_mobility/google/mobility_national.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/20_mobility/google/mobility_national.csv">preview</a></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Economics</td>
<td style="text-align: left;">Unemployment benefits</td>
<td style="text-align: left;">NAV</td>
<td style="text-align: left;">2020-06-26</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/10_employment/nav/applications_unemployment_benefits.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/10_employment/nav/applications_unemployment_benefits.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/10_employment/nav/applications_unemployment_benefits.csv">preview</a></td>
</tr>
</tbody>
</table>

For further information about the data sources, see this
[section](https://www.covid19data.no/data.html).

### Supporting data

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Category</th>
<th style="text-align: left;">Data</th>
<th style="text-align: left;">Download</th>
<th style="text-align: left;">Preview</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Lookup tables</td>
<td style="text-align: left;">Municipalities</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.csv">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Lookup tables</td>
<td style="text-align: left;">Municipalities and districts</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities_districts.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities_districts.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/00_lookup_tables_and_maps/01_lookup_tables/municipalities_districts.csv">preview</a></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Lookup tables</td>
<td style="text-align: left;">MSIS regions</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/msis.csv">csv</a> <a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/01_lookup_tables/msis.xlsx">xlsx</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/00_lookup_tables_and_maps/01_lookup_tables/msis.csv">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Maps</td>
<td style="text-align: left;">Municipalities</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/02_maps/municipalities.geojson">geojson</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/00_lookup_tables_and_maps/02_maps/municipalities.geojson">preview</a></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Maps</td>
<td style="text-align: left;">Municipalities and districts</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/02_maps/municipalities_districts.geojson">geojson</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/00_lookup_tables_and_maps/02_maps/municipalities_districts.geojson">preview</a></td>
</tr>
<tr class="even">
<td style="text-align: left;">Maps</td>
<td style="text-align: left;">MSIS regions</td>
<td style="text-align: left;"><a href = "https://raw.githubusercontent.com/thohan88/covid19-nor-data/master/data/00_lookup_tables_and_maps/02_maps/msis.geojson">geojson</a></td>
<td style="text-align: left;"><a href = "https://github.com/thohan88/covid19-nor-data/blob/master/data/00_lookup_tables_and_maps/02_maps/msis.geojson">preview</a></td>
</tr>
</tbody>
</table>
