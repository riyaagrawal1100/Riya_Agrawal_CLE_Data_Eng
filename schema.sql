
CREATE DATABASE IF NOT EXISTS cle_week1;

USE cle_week1;

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(20),
    name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    signup_date VARCHAR(30),
    segment VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(20),
    category VARCHAR(100),
    product_name VARCHAR(150),
    unit_price DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(20),
    customer_id VARCHAR(20),
    order_date VARCHAR(30),
    status VARCHAR(50),
    payment_method VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10, 2),
    discount DECIMAL(5, 2)
);

CREATE TABLE IF NOT EXISTS events (
    event_id VARCHAR(20),
    order_id VARCHAR(20),
    event_time VARCHAR(40),
    event_type VARCHAR(100),
    source VARCHAR(100)
);
