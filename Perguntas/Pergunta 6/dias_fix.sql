WITH calendario AS (
    SELECT 
        data_dia::date,
        CASE EXTRACT(DOW FROM data_dia)
            WHEN 0 THEN 'Domingo'
            WHEN 1 THEN 'Segunda-feira'
            WHEN 2 THEN 'Terça-feira'
            WHEN 3 THEN 'Quarta-feira'
            WHEN 4 THEN 'Quinta-feira'
            WHEN 5 THEN 'Sexta-feira'
            WHEN 6 THEN 'Sábado'
        END AS dia_semana
    FROM generate_series(
        '2023-01-01'::date, 
        '2024-12-31'::date, 
        '1 day'
    ) AS data_dia
),
new_sales AS (
    SELECT 
        sale_date,
        COUNT(id_sale) AS vendas,
        SUM(qtd) AS volume,
        SUM(brl_total) AS valor_venda
    FROM sales
    GROUP BY sale_date
),
new_sales_gap AS (
    SELECT 
        c.data_dia,
        c.dia_semana,
        COALESCE(vendas, 0) AS vendas,
        COALESCE(volume, 0) AS volume,
        COALESCE(valor_venda, 0) AS valor_venda
    FROM calendario c
    LEFT JOIN new_sales s
    ON c.data_dia = s.sale_date
)
SELECT 
    dia_semana,
    ROUND(AVG(valor_venda),2) as media_venda
FROM
    new_sales_gap
GROUP BY
    dia_semana
ORDER BY
    media_venda;