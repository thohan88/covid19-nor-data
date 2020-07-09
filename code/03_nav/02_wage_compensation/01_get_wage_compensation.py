import requests
import pandas as pd


def key_figures():
    datapackage = requests.get('https://data.nav.no/api/nav-opendata/bc415e741ce8d6c11c3d4f2af11105ce/datapackage.json').json()
    data = requests.get('https://data.nav.no/api/nav-opendata/bc415e741ce8d6c11c3d4f2af11105ce/resources/N%C3%B8kkeltall_for_ordningen.json').json()

    df = pd.read_csv('data/30_economics/nav/wage_compensation_timeseries.csv')

    date = datapackage['updated']
    n_companies = data['data'][1]['value']
    n_employees = data['data'][2]['value']
    total_amount = data['data'][0]['value']
    last_updated = datapackage['modified']

    if df['date'].str.contains(date).sum() == 0:
        df.loc[-1] = [date, n_companies, n_employees, total_amount, last_updated]
        df.index = df.index + 1
        df = df.sort_index()
    else:
        df.loc[df.date == date, 'n_companies'] = n_companies
        df.loc[df.date == date, 'n_employees'] = n_employees
        df.loc[df.date == date, 'total_amount'] = total_amount
        df.loc[df.date == date, 'last_updated'] = last_updated

    df.to_csv('data/30_economics/nav/wage_compensation_timeseries.csv', encoding='utf-8', index=False)
    df.to_excel('data/30_economics/nav/wage_compensation_timeseries.xlsx', encoding='utf-8', index=False)


def wage_compensation():
    url = 'https://data.nav.no/api/nav-opendata/bc415e741ce8d6c11c3d4f2af11105ce/resources/Virksomheter_som_har_f%C3%A5tt_innvilget_l%C3%B8nnskompensasjon_for_sine_ansatte.csv.gz'

    df = pd.read_csv(url, delimiter=';', compression='gzip')

    mapping = {'Organisasjonsnummer': 'organisation_number',
               'Virksomhetsnavn': 'company_name',
               'Antall arbeidsforhold med innvilget lønnskompensasjon': 'n_employees'}

    df = df.rename(columns=mapping)

    df.to_csv('data/30_economics/nav/wage_compensation.csv', encoding='utf-8', index=False)
    df.to_excel('data/30_economics/nav/wage_compensation.xlsx', encoding='utf-8', index=False)


if __name__ == "__main__":
    key_figures()
    wage_compensation()
