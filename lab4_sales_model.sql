-- Lab 4: Dimensional Model and Analytical Layer
-- Beginner-friendly SQLite implementation.
-- Fact grain: ONE ROW PER SALES ORDER LINE (not one row per order).

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;

-- DIMENSIONS
CREATE TABLE dim_customer (
    customer_sk   INTEGER PRIMARY KEY AUTOINCREMENT, -- surrogate key
    customer_id   TEXT NOT NULL,                     -- business/natural key
    customer_name TEXT NOT NULL,
    city          TEXT,
    effective_from TEXT NOT NULL,
    effective_to   TEXT NOT NULL,
    current_flag   INTEGER NOT NULL CHECK (current_flag IN (0, 1))
);

CREATE TABLE dim_product (
    product_sk   INTEGER PRIMARY KEY AUTOINCREMENT, -- surrogate key
    product_id   TEXT NOT NULL UNIQUE,              -- business key
    product_name TEXT NOT NULL,
    category     TEXT NOT NULL,
    unit_price   REAL NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE dim_date (
    date_sk      INTEGER PRIMARY KEY, -- YYYYMMDD business-style date key
    full_date    TEXT NOT NULL UNIQUE,
    day          INTEGER NOT NULL,
    month        INTEGER NOT NULL,
    month_name   TEXT NOT NULL,
    quarter      INTEGER NOT NULL,
    year         INTEGER NOT NULL
);

-- FACT TABLE
CREATE TABLE fact_sales (
    sales_line_id INTEGER PRIMARY KEY, -- source order-line identifier
    order_id      TEXT NOT NULL,
    customer_sk   INTEGER NOT NULL,
    product_sk    INTEGER NOT NULL,
    date_sk       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    REAL NOT NULL CHECK (unit_price >= 0),
    revenue       REAL NOT NULL CHECK (revenue >= 0),
    FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
    FOREIGN KEY (product_sk) REFERENCES dim_product(product_sk),
    FOREIGN KEY (date_sk) REFERENCES dim_date(date_sk)
);

-- SAMPLE DIMENSION DATA
-- Customer C001 initially lives in Jaipur; C002 lives in Delhi.
INSERT INTO dim_customer
(customer_id, customer_name, city, effective_from, effective_to, current_flag)
VALUES
('C001', 'Aarav Sharma', 'Jaipur', '2026-01-01', '9999-12-31', 1),
('C002', 'Meera Singh',  'Delhi',  '2026-01-01', '9999-12-31', 1);

INSERT INTO dim_product (product_id, product_name, category, unit_price)
VALUES
('P001', 'Laptop',  'Electronics', 50000),
('P002', 'Mouse',   'Accessories', 800),
('P003', 'Notebook','Stationery', 100);

INSERT INTO dim_date
(date_sk, full_date, day, month, month_name, quarter, year)
VALUES
(20260110, '2026-01-10', 10, 1, 'January', 1, 2026),
(20260115, '2026-01-15', 15, 1, 'January', 1, 2026),
(20260205, '2026-02-05', 5, 2, 'February', 1, 2026),
(20260210, '2026-02-10', 10, 2, 'February', 1, 2026);

-- SAMPLE SALES: each row is one product line in an order.
-- Revenue = quantity * unit_price.
INSERT INTO fact_sales
(sales_line_id, order_id, customer_sk, product_sk, date_sk, quantity, unit_price, revenue)
VALUES
(1, 'ORD101', 1, 1, 20260110, 1, 50000, 50000),
(2, 'ORD101', 1, 2, 20260110, 2,   800,  1600),
(3, 'ORD102', 2, 3, 20260115, 5,   100,   500),
(4, 'ORD103', 2, 2, 20260205, 1,   800,   800),
(5, 'ORD104', 1, 3, 20260210, 3,   100,   300);

-- ANALYTICAL QUERIES

-- 1. Overall revenue and units sold.
SELECT
    SUM(revenue) AS total_revenue,
    SUM(quantity) AS total_units
FROM fact_sales;

-- 2. Number of distinct customers who purchased.
SELECT COUNT(DISTINCT customer_sk) AS purchasing_customer_versions
FROM fact_sales;

-- 3. Revenue and units by product/category.
SELECT
    p.category,
    p.product_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY p.category, p.product_name
ORDER BY total_revenue DESC;

-- 4. Monthly revenue.
SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.revenue) AS monthly_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- 5. Revenue by customer version. The customer surrogate key keeps
-- historical sales attached to the customer attributes valid at sale time.
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY c.customer_sk, c.customer_id, c.customer_name, c.city
ORDER BY total_revenue DESC;

-- SCD TYPE 2 DEMONSTRATION
-- On 2026-02-15, customer C001 moves from Jaipur to Ajmer.
-- Step 1: close the old version.
UPDATE dim_customer
SET effective_to = '2026-02-14',
    current_flag = 0
WHERE customer_id = 'C001' AND current_flag = 1;

-- Step 2: insert a new version with a new surrogate key.
INSERT INTO dim_customer
(customer_id, customer_name, city, effective_from, effective_to, current_flag)
VALUES
('C001', 'Aarav Sharma', 'Ajmer', '2026-02-15', '9999-12-31', 1);

-- Show both historical and current customer versions.
SELECT customer_sk, customer_id, customer_name, city,
       effective_from, effective_to, current_flag
FROM dim_customer
WHERE customer_id = 'C001'
ORDER BY effective_from;

-- Type 1 alternative (DO NOT run together with the Type 2 example if
-- you want to preserve the history above):
-- UPDATE dim_customer SET city = 'Ajmer' WHERE customer_id = 'C001'
--   AND current_flag = 1;
-- Type 1 overwrites the old value; Type 2 keeps the old row and inserts
-- a new version. Existing facts keep their original customer_sk.
