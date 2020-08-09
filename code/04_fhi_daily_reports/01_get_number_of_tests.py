from sys import path
path.append('code/')
import pandas as pd
import requests
from datetime import datetime, date
from utils import get_fhi_datafiles

def national_tests():
    '''Daily and cumulative numbers of all the people tested for COVID-19 in Norway.'''
    updated = False
    df = pd.read_csv('data/03_covid_tests/national_tests.csv')

    r = requests.get('https://www.fhi.no/api/chartdata/api/91672').json()
    tests = r['figures'][4]
    date = str(datetime.strptime(tests['updated'], '%d/%m/%Y').date())

    if df['date'].str.contains(date).sum() == 0:
        n_tests_cumulative = tests['number']
        n_tests = n_tests_cumulative - df['n_tests_cumulative'].max()

        df.loc[-1] = [date, n_tests, n_tests_cumulative]
        df.index = df.index + 1
        df = df.sort_index()
        updated = True

    if updated:
        df.to_csv('data/03_covid_tests/national_tests.csv', encoding='utf-8', index=False)
        df.to_excel('data/03_covid_tests/national_tests.xlsx', encoding='utf-8', index=False)

def national_tests_lab():
    '''Laboratory data - Daily numbers of people tested for COVID-19 in Norway.'''
    datafile = get_fhi_datafiles('data_covid19_lab_by_time_')[-1]

    df = pd.read_csv(datafile, usecols=['date', 'n_neg', 'n_pos', 'pr100_pos'])

    df['n_tests'] = df['n_neg'] + df['n_pos']
    df['n_neg_cumulative'] = df['n_neg'].cumsum()
    df['n_pos_cumulative'] = df['n_pos'].cumsum()
    df['n_tests_cumulative'] = df['n_tests'].cumsum()

    df = df.sort_values(by=['date'], ascending=False)

    df.to_csv('data/03_covid_tests/national_tests_lab.csv', encoding='utf-8', index=False)
    df.to_excel('data/03_covid_tests/national_tests_lab.xlsx', encoding='utf-8', index=False)

if __name__ == "__main__":
    national_tests()
    national_tests_lab()