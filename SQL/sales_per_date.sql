SELECT 
    EXTRACT(YEAR FROM sale_date) AS year, 
    EXTRACT(MONTH FROM sale_date) AS month, 
    ROUND(SUM(brl_total), 2) AS total_sales
FROM sales
GROUP BY year, month
ORDER BY year, month;