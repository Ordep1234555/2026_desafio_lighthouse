-- Como a instrução especifica para não fazer tratamento dos dados,
-- vou usar uma CTE para ter a sale_date como data provisoriamente
-- a intenção é uma query que responda todas as perguntas
WITH
    vendas_formatada AS (
        SELECT
            CASE
                WHEN sale_date LIKE '____-__-__' THEN CAST(sale_date AS DATE)
                WHEN sale_date LIKE '__-__-____' THEN TO_DATE (sale_date, 'DD-MM-YYYY')
                ELSE NULL
            END AS data_formatada,
            total
        FROM
            vendas_raw
    ),
    info1_tmp AS (
        SELECT
            COUNT(*) AS total_LINHAS,
            MIN(data_formatada) AS data_minima,
            MAX(data_formatada) AS data_maxima,
            MIN(total) AS valor_minimo,
            MAX(total) AS valor_maximo,
            AVG(total) AS valor_medio
        FROM
            vendas_formatada
    ),
    info2_tmp AS (
        SELECT
            COUNT(*) as total_COLUNAS
        FROM
            information_schema.columns
        WHERE
            table_name = 'vendas_raw'
    )
SELECT
    total_LINHAS,
    total_COLUNAS,
    data_minima,
    data_maxima,
    valor_minimo,
    valor_maximo,
    valor_medio
FROM
    info1_tmp,
    info2_tmp;