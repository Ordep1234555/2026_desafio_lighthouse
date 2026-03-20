WITH PrecoUnitario AS (
    SELECT 
        id,
        id_client,
        id_product,
        qtd,
        total,
        sale_date,
        (total / NULLIF(qtd, 0)) AS preco_unitario
    FROM vendas_raw
    WHERE qtd > 0 -- Ignorando possíveis devoluções momentaneamente
),
EstatisticasProduto AS (
    SELECT 
        id_product,
        AVG(preco_unitario) AS preco_medio,
        STDDEV(preco_unitario) AS desvio_padrao,
        MIN(preco_unitario) AS preco_min,
        MAX(preco_unitario) AS preco_max
    FROM PrecoUnitario
    GROUP BY id_product
)
SELECT 
    p.id,
    p.id_product,
    p.qtd,
    p.total,
    p.preco_unitario,
    e.preco_medio,
    -- Calcula o Z-Score do preço unitário (quão longe está da média em desvios padrões)
    ABS(p.preco_unitario - e.preco_medio) / NULLIF(e.desvio_padrao, 0) AS z_score_preco
FROM PrecoUnitario p
JOIN EstatisticasProduto e ON p.id_product = e.id_product
WHERE 
    e.desvio_padrao > 0 
    AND (ABS(p.preco_unitario - e.preco_medio) / e.desvio_padrao) > 3 -- Outliers a 3 desvios padrões
ORDER BY z_score_preco DESC;


WITH Quartis AS (
    SELECT 
        id_product,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total) AS q3
    FROM vendas_raw
    GROUP BY id_product
),
Limites AS (
    SELECT 
        id_product,
        q1,
        q3,
        (q3 - q1) AS iqr,
        q1 - (1.5 * (q3 - q1)) AS limite_inferior,
        q3 + (1.5 * (q3 - q1)) AS limite_superior
    FROM Quartis
)
SELECT 
    v.id,
    v.id_product,
    v.total,
    l.limite_inferior,
    l.limite_superior
FROM vendas_raw v
JOIN Limites l ON v.id_product = l.id_product
WHERE v.total < l.limite_inferior 
   OR v.total > l.limite_superior
ORDER BY v.total DESC;

WITH GastosCliente AS (
    SELECT 
        id_client,
        COUNT(id) as qtd_compras,
        AVG(total) as ticket_medio_cliente,
        MAX(total) as maior_compra,
        SUM(total) as gasto_total
    FROM vendas_raw
    GROUP BY id_client
)
SELECT 
    id_client,
    qtd_compras,
    ticket_medio_cliente,
    maior_compra,
    gasto_total,
    -- Razão entre a maior compra e o ticket médio normal do cliente
    (maior_compra / NULLIF(ticket_medio_cliente, 0)) AS proporcao_anomalia
FROM GastosCliente
WHERE qtd_compras > 5 -- Focando em clientes recorrentes
  AND (maior_compra / NULLIF(ticket_medio_cliente, 0)) > 10 -- A maior compra é 10x maior que a média dele
ORDER BY proporcao_anomalia DESC;

WITH TotaisDiarios AS (
    SELECT 
        DATE(sale_date) AS data_venda,
        SUM(total) AS faturamento_dia,
        COUNT(id) AS volume_transacoes
    FROM vendas_raw
    GROUP BY DATE(sale_date)
),
MediaMovel AS (
    SELECT 
        data_venda,
        faturamento_dia,
        volume_transacoes,
        -- Média móvel dos últimos 7 dias
        AVG(faturamento_dia) OVER (
            ORDER BY data_venda 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS media_7_dias_anteriores
    FROM TotaisDiarios
)
SELECT 
    data_venda,
    faturamento_dia,
    media_7_dias_anteriores,
    (faturamento_dia / NULLIF(media_7_dias_anteriores, 0)) - 1 AS percentual_variacao
FROM MediaMovel
WHERE media_7_dias_anteriores IS NOT NULL
  AND (faturamento_dia / NULLIF(media_7_dias_anteriores, 0)) > 2.5 -- Dias que faturaram 150%+ acima da média móvel
ORDER BY percentual_variacao DESC;