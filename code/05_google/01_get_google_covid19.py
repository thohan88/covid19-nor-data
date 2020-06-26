import pandas as pd

url = 'https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv'
df = pd.read_csv(url, usecols=['country_region_code', 'iso_3166_2_code', 'sub_region_1', 'date',
                               'retail_and_recreation_percent_change_from_baseline',
                               'grocery_and_pharmacy_percent_change_from_baseline',
                               'parks_percent_change_from_baseline',
                               'transit_stations_percent_change_from_baseline',
                               'workplaces_percent_change_from_baseline',
                               'residential_percent_change_from_baseline'])

variable_mapping = {
    'iso_3166_2_code': 'fylke_no',
    'sub_region_1': 'fylke_name',
    'retail_and_recreation_percent_change_from_baseline': 'Retail & recreation',
    'grocery_and_pharmacy_percent_change_from_baseline': 'Grocery & pharmacy',
    'parks_percent_change_from_baseline': 'Parks',
    'transit_stations_percent_change_from_baseline': 'Transit stations',
    'workplaces_percent_change_from_baseline': 'Workplace',
    'residential_percent_change_from_baseline': 'Residential'
}

df = df[df['country_region_code'] == 'NO'].rename(columns=variable_mapping)

# National data
national = df[df['fylke_name'].isnull().values].drop(columns=['fylke_no', 'fylke_name'])
national = national.melt(id_vars=['country_region_code', 'date'], var_name='category', value_name='mob_change')

national.to_csv('data/20_mobility/google/mobility_national.csv', encoding='utf-8', index=False)
national.to_excel('data/20_mobility/google/mobility_national.xlsx', encoding='utf-8', index=False)

# District data
district = df.dropna(subset=['fylke_no', 'fylke_name']).drop(columns=['country_region_code'])
district['fylke_no'] = district['fylke_no'].str.replace('NO-', '')
district = district.melt(id_vars=['fylke_no', 'fylke_name', 'date'], var_name='category', value_name='mob_change')

district.to_csv('data/20_mobility/google/mobility.csv', encoding='utf-8', index=False)
district.to_excel('data/20_mobility/google/mobility.xlsx', encoding='utf-8', index=False)