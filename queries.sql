
USE cle_week1;

-- 1. check row count for all tables
SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items
UNION ALL
SELECT 'events', COUNT(*)
FROM events;

-- 2. check for missing values
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR name IS NULL
   OR city IS NULL
   OR state IS NULL
   OR signup_date IS NULL
   OR segment IS NULL;

-- 3. duplicate customer id
SELECT customer_id, COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 4. duplicate order id
SELECT order_id, COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 5. invalid quantities
SELECT *
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;

-- 6. duplicate order item records
SELECT order_id,product_id,quantity,unit_price,discount,COUNT(*) AS occurrences
FROM order_items
GROUP BY
    order_id,
    product_id,
    quantity,
    unit_price,
    discount
HAVING COUNT(*) > 1;

-- 7. duplicate event id's
SELECT
    event_id,
    COUNT(*) AS occurrences
FROM events
GROUP BY event_id
HAVING COUNT(*) > 1;


-- 8. daily revenue
SELECT
    o.order_date,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('delivered', 'completed')
GROUP BY o.order_date
ORDER BY o.order_date;


-- 9. top 5 products
SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 5;


-- 10. repeat customers
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 11. order status distribution
SELECT
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY status;


-- 12. avg order value
SELECT AVG(order_total) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS totals;


-- 13. CTE: total spending per customer
WITH customer_spending AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS total_spending
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT *
FROM customer_spending
ORDER BY total_spending DESC;

-- 14. rank product by price
SELECT
    product_name,
    unit_price,
    RANK() OVER (ORDER BY unit_price DESC) AS price_rank
FROM products;


-- 15. view: order summary (reusable view)
CREATE OR REPLACE VIEW order_summary AS
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_total
FROM order_items
GROUP BY order_id;
