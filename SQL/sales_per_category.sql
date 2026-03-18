WITH values_sale AS
(
    SELECT 
        id_product, 
        COUNT(*) AS total_vendas,
        SUM(qtd) AS total_vendido,
        SUM(brl_total) AS total_faturado
    FROM sales
    GROUP BY id_product
    ORDER BY id_product ASC
)

SELECT
    p.category,
    SUM(v.total_vendas) AS total_vendas,
    ROUND(SUM(v.total_faturado) / SUM(v.total_vendas), 2) AS faturamento_venda,
    SUM(v.total_vendido) AS total_vendido,
    SUM(v.total_faturado) AS total_faturado,
    ROUND(SUM(v.total_faturado) / SUM(v.total_vendido), 2) AS faturamento_medio
FROM products p
JOIN values_sale v ON p.id_product = v.id_product
GROUP BY p.category
ORDER BY total_faturado DESC;