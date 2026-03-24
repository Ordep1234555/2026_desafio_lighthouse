import pandas as pd

df_custos = pd.read_json('Datasets/custos_importacao.json')

print(df_custos.info())

# Tirando as colunas de dentro do dicionario
df_custos = df_custos.explode('historic_data')

# Aplicando Series para transformar em multiplas linhas
df_custos = pd.concat([
    df_custos.drop(columns=['historic_data']),
    df_custos['historic_data'].apply(pd.Series)
], axis=1)

df_custos['start_date'] = pd.to_datetime(df_custos['start_date'], dayfirst=True)

print(df_custos.info())

df_custos.to_csv('custos_importacao.csv', index=False)