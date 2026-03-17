-- 1. DEFININDO AS CHAVES PRIMÁRIAS
ALTER TABLE clients ADD PRIMARY KEY (id_client);
ALTER TABLE products ADD PRIMARY KEY (id_product);
ALTER TABLE sales ADD PRIMARY KEY (id_sale);
ALTER TABLE import_costs ADD PRIMARY KEY (id_product, start_date);

-- 2. DEFININDO AS CHAVES ESTRANGEIRAS
ALTER TABLE sales 
    ADD CONSTRAINT fk_sales_client FOREIGN KEY (id_client) REFERENCES clients (id_client),
    ADD CONSTRAINT fk_sales_product FOREIGN KEY (id_product) REFERENCES products (id_product);

ALTER TABLE import_costs 
    ADD CONSTRAINT fk_import_costs_product FOREIGN KEY (id_product) REFERENCES products (id_product);

-- 3. CONSERTANDO TIPO DE DADOS

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('sales', 'clients', 'products', 'import_costs');

ALTER TABLE products 
    ALTER COLUMN brl_price TYPE NUMERIC(10, 2) USING brl_price::NUMERIC(10, 2),
    ALTER COLUMN category TYPE VARCHAR(15);

ALTER TABLE import_costs 
    ALTER COLUMN usd_price TYPE NUMERIC(10, 2) USING usd_price::NUMERIC(10, 2),
    ALTER COLUMN start_date TYPE DATE USING start_date::DATE,
    ALTER COLUMN end_date TYPE DATE USING end_date::DATE;

ALTER TABLE sales 
    ALTER COLUMN brl_total TYPE NUMERIC(10, 2) USING brl_total::NUMERIC(10, 2),
    ALTER COLUMN qtd TYPE INTEGER USING qtd::INTEGER,
    ALTER COLUMN sale_date TYPE DATE USING sale_date::DATE;

ALTER TABLE clients 
    ALTER COLUMN state TYPE CHAR(2);    

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN 
('sales', 'clients', 'products', 'import_costs');