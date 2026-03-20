-- Como a instrução especifica para não fazer tratamento dos dados,
-- vou usar uma CTE para ter a sale_date como data provisoriamente
-- a intenção é uma query que responda todas as perguntas
WITH vendas_formatada AS (
    SELECT 
        CASE 
            WHEN sale_date LIKE '____-__-__' THEN CAST(sale_date AS DATE)
            WHEN sale_date LIKE '__-__-____' THEN TO_DATE(sale_date, 'DD-MM-YYYY')
            ELSE NULL 
        END AS data_formatada
    FROM vendas_raw
),
info1_tmp AS (
    SELECT 
        MIN(data_formatada) AS data_minima,
        MAX(data_formatada) AS data_maxima
    FROM vendas_formatada
),
info2_tmp AS (
    SELECT COUNT(*) AS total_LINHAS, 
        MIN(total) AS valor_minimo,
        MAX(total) AS valor_maximo,
        AVG(total) AS valor_medio
    FROM vendas_raw
),
info3_tmp AS(
    SELECT COUNT(*) as total_COLUNAS
    FROM information_schema.columns
    WHERE table_name = 'vendas_raw'
)

SELECT 
    total_LINHAS,
    total_COLUNAS, 
    data_minima,
    data_maxima,
    valor_minimo, 
    valor_maximo, 
    valor_medio 
FROM info1_tmp, info2_tmp, info3_tmp;

-- Check
SELECT *
FROM vendas_raw
WHERE ID IN (SELECT ID FROM vendas_raw ORDER BY total DESC LIMIT 1);

SELECT 
    id,
    ROUND((total)::numeric/(qtd)::numeric,2) AS valor_unitario,
    qtd,
    total,
    sale_date
FROM vendas_raw
WHERE id_product = 76
ORDER BY valor_unitario DESC;

SELECT * FROM vendas_raw
LIMIT 10;