# Desafio Tecnico Progama LightHouse 2026

-> Docker Cria a base de dados Postgres

-> EDA.ipynb trata os dados e sobe eles para o banco

-> SQL/fix_database.sql ajeita os dados para definir chaves primarias e ligações

-> Visualizações e Análises: LH_Nautica_Dashboard.pbix

## Dados brutos:
clientes_crm.json = full_name, location, code, email

custos_importacao.json = product_id, product_name, category, historic_data

produtos_raw.csv = name, price, code, actual_category

vendas_2023_2024.csv = id, id_client, id_product, qtd, total, sale_date

usd_2023_2024.csv = cotacaoVenda, dataHoraCotacao

## Base de dados:
clients: id_client, full_name, email, city, state

products: id_product, product_name, category, brl_price

import_costs: id_product, start_date, end_date, usd_price

sales: id_sale, id_client, id_product, qtd, brl_total, sale_date

cambio_usd: taxa_cambio, taxa_cambio_data

## Resumo Tratamento de dados:
### clients:
- Location foi dividido entre city e state
- Emails errados foram ajustados
- Code renomeado para id_client e ordem ajustada
### products:
- Categorias previstas usando n-grams
- Formato preço ajustado
- Coluna price renomeada para brl_price e ordem ajustada
### import_costs:
- Coluna historic_data explodida para expandir as linhas (start_date e usd_price)
- Coluna end_date adicionada
- product_id renomeada para id_product e ordem ajustada
### sales:
- Formato date ajustado
- Coluna total renomeada para brl_total
- Coluna id renomeada para id_sale e ordem ajustada
### cambio_usd:
- Colunas renomeadas
- Dados faltantes preenchidos

## Resumo Análise de dados:

- 9895 vendas, 105 sale_id faltantando
- 150 itens, 3 categorias, 50 em cada ('ancoragem', 'eletrônicos', 'propulsão')
- 49 clientes, todos compram de todas as categorias
- Loja Fisica em Florianópolis, porém no dataset de clientes nenhum deles é de lá.
- Uma pessoa é de Laguna / SC
- 6 dias sem vendas entre 01/01/2023 e 31/12/2024
- 12 dias com valor de vendas considerado como outliers
- Vendas com Prejuizo = 62,47%
- Vendas com Lucro = 37,53%
- Receita Total = 2610279510.70
- Custo Total = 2749121506.71
- Lucro Total = -138841996.01
- Soma Lucros = 43468365.83
- Soma Prejuizo = -182310361.84
- Percentual de Perda (Prejuizo/Receita) = 6,98%
- Maior Prejuizo Total por Item:

  72 -> -39821041.65

  83 -> -18614294.89
- Maior Prejuizo Relativo por Item:

  72 -> 63.15004926752485756300

  83 -> 41.94540038812513745700
- TOP 3 Clientes:
  47 (64003343.75, 190)

  42 (72187369,5, 222)

  9 (66788855.35, 218)
- Vendas entre os melhores 10 clientes por categoria:

  propulsão - 6030
  
  ancoragem - 5632

  eletrônicos - 5214
- Piores dias / Média de vendas:

  Domingo 3319503.57

  Segunda-feira 3465137.71
- Melhores dias / Média de vendas:

  Sexta-feira 3715003.41

  Sábado 3710540.55
- Mais analises e as visualizações se encontram no Dashboard
