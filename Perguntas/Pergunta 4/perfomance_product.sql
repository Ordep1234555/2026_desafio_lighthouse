WITH
    new_sales AS (
        SELECT
            s.id_sale,
            s.id_product,
            s.sale_date,
            s.qtd,
            s.brl_total,
            ic.usd_price,
            c.taxa_cambio,
            ROUND(ic.usd_price * c.taxa_cambio * s.qtd, 2) AS brl_total_cost,
            (
                s.brl_total - ROUND(ic.usd_price * c.taxa_cambio * s.qtd, 2)
            ) AS brl_profit
        FROM
            sales s
            JOIN import_costs ic ON s.id_product = ic.id_product
            AND s.sale_date >= ic.start_date
            AND (
                s.sale_date <= ic.end_date
                OR ic.end_date IS NULL
            )
            JOIN cambio_usd c ON s.sale_date = c.taxa_cambio_data
    )
SELECT
    id_product,
    SUM(brl_total) AS receita_total,
    SUM(
        CASE
            WHEN brl_profit < 0 THEN brl_profit
        END
    ) AS prejuizo_total,
    ABS(
        SUM(
            CASE
                WHEN brl_profit < 0 THEN brl_profit
            END
        )
    ) / SUM(brl_total) * 100 AS pct_perda
FROM
    new_sales
GROUP BY
    id_product;