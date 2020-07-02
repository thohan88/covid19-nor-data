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

mapping = {'Tildelingsdato': 'grant_date',
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
           'Fylke': 'district'}

df = pd.read_csv(data, delimiter=';')

df = df[columns].rename(columns=mapping).sort_values(by='grant_date', ascending=False)

df['grant_date'] = pd.to_datetime(df.grant_date, format='%Y-%m-%dT%H.%M.%SZ')
df['period_month'] = pd.to_datetime(df.period_month, format='%B %Y')
df['industry_code'] = df['industry_code'].round(3).astype(str)

locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

df.to_csv('data/30_economics/tax_administration/business_compensation_scheme.csv', encoding='utf-8', index=False)
df.to_excel('data/30_economics/tax_administration/business_compensation_scheme.xlsx', encoding='utf-8', index=False)