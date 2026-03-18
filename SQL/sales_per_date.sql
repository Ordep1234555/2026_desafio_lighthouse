WITH sales_monthly AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        EXTRACT(MONTH FROM sale_date) AS sale_month,
        COUNT(*) AS total_sales,
        SUM(brl_total) AS total_faturado
    FROM sales
    GROUP BY sale_year, sale_month
    ORDER BY sale_year, sale_month
),
sales_difference AS (
    SELECT 
        CONCAT(sale_year, '/', sale_month) AS sale_period,
        total_sales,
        total_sales - LAG(total_sales) OVER (ORDER BY sale_year, sale_month) AS sales_difference
    FROM sales_monthly
)

SELECT *
FROM sales_difference
WHERE sales_difference IS NOT NULL
ORDER BY sales_difference DESC
LIMIT 10;

SELECT EXTRACT(YEAR FROM sale_date) AS sale_year,
       EXTRACT(MONTH FROM sale_date) AS sale_month,
       COUNT(*) AS total_sales,
       SUM(brl_total) AS total_faturado
FROM sales
GROUP BY sale_year, sale_month
ORDER BY total_sales DESC
LIMIT 10;



