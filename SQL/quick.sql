with precos_unitarios AS (
    SELECT id_sale, id_product, ROUND(brl_total / qtd, 2) AS preco_unitario
    FROM sales
),
precos_importacao AS (
    SELECT id_product, ROUND(usd_price * 5.19, 2) AS preco_importacao
    FROM import_costs
    WHERE end_date IS NULL
)
SELECT
    u.id_product,
    u.preco_unitario,
    i.preco_importacao
FROM precos_unitarios u
JOIN precos_importacao i ON u.id_product = i.id_product
WHERE u.preco_unitario > i.preco_importacao
ORDER BY (u.preco_unitario - i.preco_importacao) DESC

SELECT start_date
FROM import_costs
WHERE end_date IS NULL
ORDER BY start_date DESC
LIMIT 5;

SELECT sale_date
FROM sales
ORDER BY sale_date DESC
LIMIT 5;