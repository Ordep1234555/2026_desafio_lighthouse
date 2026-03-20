CREATE TABLE cambio_usd (
    cotacao_venda TEXT,
    data_hora TIMESTAMP
);

-- Alterando a coluna cotacao_venda: substitui vírgula por ponto e converte para numeric
ALTER TABLE cambio_usd 
ALTER COLUMN cotacao_venda TYPE NUMERIC(10,4) 
USING REPLACE(cotacao_venda, ',', '.')::NUMERIC;

-- Alterando data_hora para o tipo DATE
ALTER TABLE cambio_usd 
ALTER COLUMN data_hora TYPE DATE 
USING data_hora::DATE;

-- Renomeando a coluna para refletir que agora é apenas data (opcional, mas recomendado)
ALTER TABLE cambio_usd RENAME COLUMN cotacao_venda TO taxa_cambio;

ALTER TABLE cambio_usd RENAME COLUMN data_hora TO taxa_cambio_data;


-- 1. Criamos a tabela temporária com a lógica alternativa
CREATE TEMP TABLE tmp_cambio_preenchido AS
WITH calendario AS (
    SELECT generate_series('2023-01-01'::date, '2024-12-31'::date, '1 day'::interval)::date AS data_dia
),
dados_com_gaps AS (
    SELECT 
        c.data_dia,
        t.taxa_cambio
    FROM calendario c
    LEFT JOIN cambio_usd t ON c.data_dia = t.taxa_cambio_data
),
-- Passo A: Criamos um "ID de Grupo" que só aumenta quando encontra um valor não nulo
grupos AS (
    SELECT 
        data_dia,
        taxa_cambio,
        COUNT(taxa_cambio) OVER (ORDER BY data_dia) AS grupo_id
    FROM dados_com_gaps
),
-- Passo B: Pegamos o valor do topo de cada grupo (o último valor válido)
valores_locf AS (
    SELECT 
        data_dia,
        MAX(taxa_cambio) OVER (PARTITION BY grupo_id) AS cotacao_final
    FROM grupos
)
-- Passo C: Aplicamos o FIRST_VALUE para tratar o dia 01/01/2023 (caso seja nulo)
SELECT 
    data_dia,
    COALESCE(
        cotacao_final, 
        (SELECT taxa_cambio FROM cambio_usd WHERE taxa_cambio IS NOT NULL ORDER BY taxa_cambio_data LIMIT 1)
    ) AS cotacao_final
FROM valores_locf;

-- 2. Limpeza e Inserção (Igual ao anterior)
TRUNCATE TABLE cambio_usd;

INSERT INTO cambio_usd (taxa_cambio_data, taxa_cambio)
SELECT data_dia, cotacao_final FROM tmp_cambio_preenchido;

DROP TABLE tmp_cambio_preenchido;

SELECT * FROM cambio_usd;

UPDATE import_costs
SET end_date = DATE '2026-03-24'
WHERE end_date IS NULL;