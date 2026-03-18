WITH values_sale AS
(
    SELECT 
        id_product, 
        COUNT(*) AS total_vendas,
        SUM(qtd) AS total_vendido,
        SUM(brl_total) AS total_faturado,
        ROUND(SUM(brl_total) / COUNT(*), 2) AS preco_medio_venda,
        ROUND(SUM(brl_total) / SUM(qtd), 2) AS preco_medio_unidade
    FROM sales
    GROUP BY id_product
    ORDER BY id_product ASC
)

SELECT
    p.id_product,
    p.brl_price AS preco_unitario,
    v.preco_medio_unidade,
    v.total_vendas,
    v.preco_medio_venda,
    v.total_vendido,
    v.total_faturado
FROM products p
JOIN values_sale v ON p.id_product = v.id_product
ORDER BY p.id_product ASC;