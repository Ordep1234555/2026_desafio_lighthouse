-- Primeiro vou pesquisar outliers no total
WITH quartiles AS (
    SELECT
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY total) AS q1,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total) AS q3
    FROM vendas_raw
),
classificacao_outliers AS (
    SELECT v.*,
        CASE 
            WHEN total < (q1 - 1.5 * (q3 - q1)) THEN 'Outlier Baixo'
            WHEN total > (q3 + 1.5 * (q3 - q1)) THEN 'Outlier Alto'
            ELSE 'Normal'
        END AS tipo_outlier
    FROM vendas_raw v, quartiles q
)
SELECT *
FROM classificacao_outliers
WHERE tipo_outlier = 'Outlier Alto';

SELECT 
    tipo_outlier,
    COUNT(*) AS quantidade
FROM classificacao_outliers
GROUP BY tipo_outlier;


-- Nenhum outlier baixo, mas alguns outliers altos
-- Vou investigar por produto, vou usar preco unitario
WITH valor_unitario AS (
    SELECT 
        id_product,
        ROUND((total)::numeric/(qtd)::numeric,2) AS valor_unitario
    FROM vendas_raw
),
quartiles_product AS (
    SELECT 
        id_product,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY valor_unitario) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY valor_unitario) AS q3
    FROM valor_unitario
    GROUP BY id_product
),
classificacao_outliers_product AS (
    SELECT v.*,
        CASE 
            WHEN valor_unitario < (q1 - 1.5 * (q3 - q1)) THEN 'Outlier Baixo'
            WHEN valor_unitario > (q3 + 1.5 * (q3 - q1)) THEN 'Outlier Alto'
            ELSE 'Normal'
        END AS tipo_outlier
    FROM valor_unitario v, quartiles_product q
    WHERE v.id_product = q.id_product
)
SELECT 
    id_product,
    tipo_outlier,
    COUNT(*) AS quantidade
FROM classificacao_outliers_product
GROUP BY id_product, tipo_outlier
HAVING tipo_outlier != 'Normal'
ORDER BY id_product, quantidade DESC;

-- Nenhuma variação de preços estranha nos itens
-- Vou investigar por data, usando o total
WITH vendas_diarias AS (
    SELECT 
        sale_date,
        SUM(total) AS total_diario
    FROM vendas_raw
    GROUP BY sale_date
),
quartiles_date AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_diario) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_diario) AS q3
    FROM vendas_diarias
),
classificacao_outliers_date AS (
    SELECT v.*,
        CASE 
            WHEN total_diario < (q1 - 1.5 * (q3 - q1)) THEN 'Outlier Baixo'
            WHEN total_diario > (q3 + 1.5 * (q3 - q1)) THEN 'Outlier Alto'
            ELSE 'Normal'
        END AS tipo_outlier
    FROM vendas_diarias v, quartiles_date q
)
SELECT 
    sale_date,
    tipo_outlier,
    COUNT(*) AS quantidade
FROM classificacao_outliers_date
GROUP BY sale_date, tipo_outlier
HAVING tipo_outlier != 'Normal'
ORDER BY sale_date, quantidade DESC;


SELECT gs.id
FROM generate_series(1, 9999) AS gs(id)
LEFT JOIN vendas_raw v
  ON v.id = gs.id
  AND v.sale_date BETWEEN DATE '2023-01-01' AND DATE '2024-12-31'
WHERE v.id IS NULL;


SELECT gs.date
FROM generate_series(
    DATE '2023-01-01',
    DATE '2024-12-31',
    INTERVAL '1 day'
) AS gs(date)
LEFT JOIN vendas_raw v
  ON v.sale_date = gs.date
WHERE v.id IS NULL
ORDER BY gs.date;