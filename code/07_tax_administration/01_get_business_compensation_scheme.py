import io
import locale
import requests
import pandas as pd

locale.setlocale(locale.LC_ALL, 'nb_NO.UTF-8')

resp = requests.get('https://www.skatteetaten.no/api/kontantstotteForNaeringRegister/export?fileFormat=.csv')
data = io.StringIO(resp.content.decode('utf-8'))

columns = ['Tildelingsdato','Organisasjonsnavn','Organisasjonsnummer','Naeringskode','TildeltForPeriode',
           'TildeltBeloep','SamledeUungaaeligeFasteKostnaderPerPeriode','OmsetningJanuarFebruar2020',
           'OmsetningJanuarFebruar2019','OmsetningSoektPeriode','OmsetningTilsvarendePeriode2019',
           'Justeringsfaktor','Fylke']

mapping = {'Tildelingsdato': 'date',
           'Organisasjonsnavn': 'company_name',
           'Organisasjonsnummer': 'organisation_number',
           'Naeringskode': 'industry_code',
           'TildeltForPeriode': 'period_month',
           'TildeltBeloep': 'amount',
           'SamledeUungaaeligeFasteKostnaderPerPeriode': 'total_unavoidable_fixed_costs',
           'OmsetningJanuarFebruar2020': 'revenue_2020',
           'OmsetningJanuarFebruar2019': 'revenue_2019',
           'OmsetningSoektPeriode': 'actual_revenue_for_the_period',
           'OmsetningTilsvarendePeriode2019': 'turnover_corresponding_period_2019',
           'Justeringsfaktor': 'adjustment_factor',
           'Fylke': 'fylke_name'}

df = pd.read_csv(data, delimiter=';', dtype={'Naeringskode': str})
df = df[columns].rename(columns=mapping).sort_values(by='date', ascending=False)

df['date'] = pd.to_datetime(df.date, format='%Y-%m-%dT%H:%M:%SZ')
df['period_month'] = pd.to_datetime(df.period_month, format='%B %Y')
df['fylke_name'] = df['fylke_name'].fillna('Ukjent Fylke')

# merge districts
districts = pd.read_csv('data/00_lookup_tables_and_maps/01_lookup_tables/municipalities.csv', usecols=['fylke_name', 'fylke_no'], dtype=str).drop_duplicates()
df = pd.merge(df, districts, how='left', on='fylke_name')

# merge classifications
classification = pd.read_csv('data/00_lookup_tables_and_maps/01_lookup_tables/standard_industrial_classification.csv', usecols=['code', 'name'], delimiter=';', encoding='ISO-8859-1', dtype=str)
classification = classification[['code', 'name']].rename(columns={'code': 'industry_code', 'name': 'industry_name'})
df = pd.merge(df, classification, how='left', on='industry_code')

# reorder columns
cols = list(df)
cols.insert(12, cols.pop(cols.index('fylke_no')))
cols.insert(13, cols.pop(cols.index('industry_code')))
df = df[cols]

locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

df.to_csv('data/30_economics/tax_administration/business_compensation_scheme.csv', encoding='utf-8', index=False)
df.to_excel('data/30_economics/tax_administration/business_compensation_scheme.xlsx', encoding='utf-8', index=False)