import pandas as pd
from sqlalchemy import create_engine

df_vendas_raw = pd.read_csv('Datasets/vendas_2023_2024.csv')

print(df_vendas_raw.head())

engine = create_engine('postgresql://postgres:postgres@localhost:5435/LH_Nautical')

df_vendas_raw.to_sql('vendas_raw', engine, if_exists='replace', index=False)

print("Sucesso")