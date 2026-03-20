SELECT * FROM vendas_raw
LIMIT 10;

UPDATE vendas_raw
SET sale_date = TO_DATE(sale_date, 'DD-MM-YYYY')
WHERE sale_date LIKE '__-__-____';

ALTER TABLE vendas_raw
ALTER COLUMN sale_date TYPE DATE
USING 
  CASE 
    WHEN sale_date ~ '^\d{4}-' THEN sale_date::date
    ELSE TO_DATE(sale_date, 'DD-MM-YYYY')
  END;

SELECT * FROM vendas_raw
LIMIT 10;

SELECT gs.id
FROM generate_series(1, 9999) AS gs(id)
LEFT JOIN vendas_raw v
  ON v.id = gs.id
WHERE v.id IS NULL;

SELECT id, total*2 FROM vendas_raw
WHERE ID = 2;