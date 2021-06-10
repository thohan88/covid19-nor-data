from sys import path
import re
import pandas as pd

path.append("code")
from utils import get_fhi_datafiles

updated = False
df = pd.read_csv('data/04_deaths/deaths_total_fhi.csv', index_col="date")
datafiles = get_fhi_datafiles('data_covid19_demographics')

for datafile in datafiles:
    match = re.search(r"\d{4}-\d{2}-\d{2}", datafile)
    if match:
        date = match.group()
    else:
        # fhi now includes a 'latest' file
        print(f"No date in {datafile}")
        continue

    if date not in df.index:
        print(f"Fetching {datafile}")
        data = pd.read_csv(datafile)
        # drop internal totals, do sums ourselves
        # csvs stopped including redundant totals on 2021-03-09
        data = data[(data["sex"] != "total") & (data["age"] != "total")]
        # store new total
        df.loc[date, "deaths"] = data.n.sum()
        updated = True


if updated:
    print("Writing updated deaths_total_fhi")
    df = df.astype({'deaths': int}).sort_index(ascending=False)
    df.to_csv("data/04_deaths/deaths_total_fhi.csv", encoding="utf-8")
    df.to_excel("data/04_deaths/deaths_total_fhi.xlsx", encoding="utf-8")
