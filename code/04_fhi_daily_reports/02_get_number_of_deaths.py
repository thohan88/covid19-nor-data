from sys import path
path.append('code/')
import re
import pandas as pd
from datetime import datetime
from utils import get_fhi_datafiles

updated = False
df = pd.read_csv('data/04_deaths/deaths_total_fhi.csv')
datafiles = get_fhi_datafiles('data_covid19_demographics')

for datafile in datafiles:
    date = re.search('\d{4}-\d{2}-\d{2}', datafile).group()

    if df['date'].str.contains(date).sum() == 0:
        data = pd.read_csv(datafile)
        n = data.loc[(data['age'] == 'total') & (data['sex'] == 'total'), ['n']].values[0][0]

        df.loc[-1] = [date, n]
        df.index = df.index + 1
        df = df.sort_index()
        updated = True

if updated:
    df.to_csv('data/04_deaths/deaths_total_fhi.csv', encoding='utf-8', index=False)
    df.to_excel('data/04_deaths/deaths_total_fhi.xlsx', encoding='utf-8', index=False)