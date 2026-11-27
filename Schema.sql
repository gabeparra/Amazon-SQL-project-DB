-- Amazon-Style E-Commerce Database
-- Complete Schema, Data, Queries, and Views
-- Run this file in MySQL Workbench

CREATE DATABASE IF NOT EXISTS amazon_ecommerce;
USE amazon_ecommerce;

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'USA',
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE payment_methods (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    card_type VARCHAR(50) NOT NULL,
    last_four CHAR(4) NOT NULL,
    expiry_date DATE NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT DEFAULT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY AUTO_INCREMENT,
    store_name VARCHAR(100) NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INT DEFAULT 0,
    joined_date DATE DEFAULT (CURDATE())
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (customer_id, product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (address_id) REFERENCES addresses(address_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10,2) NOT NULL CHECK (price_at_purchase >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE shipping (
    shipping_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    tracking_number VARCHAR(100),
    carrier VARCHAR(100),
    status VARCHAR(50) DEFAULT 'pending'
        CHECK (status IN ('pending', 'in_transit', 'out_for_delivery', 'delivered', 'returned')),
    estimated_delivery DATE,
    shipped_date DATE,
    delivered_date DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================
-- INSERT DATA
-- ============================================

INSERT INTO categories (name, parent_category_id) VALUES
('Electronics', NULL),
('Computers', 1),
('Smartphones', 1),
('Home & Kitchen', NULL),
('Furniture', 4),
('Appliances', 4),
('Books', NULL),
('Fiction', 7),
('Non-Fiction', 7),
('Clothing', NULL),
('Men\'s Clothing', 10),
('Women\'s Clothing', 10);

INSERT INTO sellers (store_name, rating, total_reviews, joined_date) VALUES
('TechWorld Store', 4.5, 1200, '2022-03-15'),
('HomeComfort', 4.2, 850, '2021-07-20'),
('BookHaven', 4.8, 3400, '2020-01-10'),
('FashionHub', 3.9, 560, '2023-05-05'),
('GadgetZone', 4.1, 920, '2022-11-30');

INSERT INTO customers (first_name, last_name, email, phone) VALUES
('Alice', 'Johnson', 'alice.j@email.com', '555-0101'),
('Bob', 'Smith', 'bob.smith@email.com', '555-0102'),
('Carlos', 'Ruiz', 'carlos.r@email.com', '555-0103'),
('Diana', 'Lee', 'diana.lee@email.com', '555-0104'),
('Emma', 'Brown', 'emma.brown@email.com', '555-0105');

INSERT INTO addresses (customer_id, street, city, state, zip_code, country, is_default) VALUES
(1, '123 Maple St', 'Austin', 'TX', '78701', 'USA', TRUE),
(1, '456 Oak Ave', 'Dallas', 'TX', '75201', 'USA', FALSE),
(2, '789 Pine Rd', 'Seattle', 'WA', '98101', 'USA', TRUE),
(3, '321 Birch Ln', 'Miami', 'FL', '33101', 'USA', TRUE),
(4, '654 Cedar Blvd', 'Denver', 'CO', '80201', 'USA', TRUE),
(5, '987 Spruce Way', 'Boston', 'MA', '02101', 'USA', TRUE);

INSERT INTO payment_methods (customer_id, card_type, last_four, expiry_date, is_default) VALUES
(1, 'Visa', '1234', '2027-05-01', TRUE),
(2, 'Mastercard', '5678', '2026-08-01', TRUE),
(3, 'Amex', '9012', '2028-12-01', TRUE),
(4, 'Visa', '3456', '2027-03-01', TRUE),
(5, 'Discover', '7890', '2026-11-01', TRUE);

INSERT INTO products (seller_id, category_id, name, description, price, stock_quantity) VALUES
(1, 2, 'Gaming Laptop Pro', '15.6" RTX 4060, 32GB RAM', 1299.99, 45),
(1, 3, 'Smartphone X14', '6.1" OLED 256GB', 899.99, 120),
(2, 5, 'Ergonomic Office Chair', 'Adjustable lumbar support', 249.99, 30),
(2, 6, 'Air Fryer XL', '7-quart digital air fryer', 119.99, 80),
(3, 8, 'The Lost City', 'Bestselling fiction novel', 14.99, 200),
(3, 9, 'Learn SQL in 30 Days', 'Comprehensive SQL guide', 29.99, 150),
(4, 11, 'Men\'s Denim Jacket', 'Classic blue denim', 59.99, 60),
(4, 12, 'Women\'s Summer Dress', 'Floral print cotton dress', 39.99, 90),
(5, 2, 'Wireless Mechanical Keyboard', 'RGB backlit, hot-swappable', 89.99, 100),
(5, 3, 'Noise Cancelling Earbuds', '40h battery life', 149.99, 75);

INSERT INTO reviews (customer_id, product_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Amazing performance for gaming!', '2024-02-10'),
(2, 1, 4, 'Great laptop but runs hot.', '2024-02-15'),
(3, 2, 5, 'Best phone I have ever owned.', '2024-03-01'),
(4, 3, 4, 'Very comfortable for long hours.', '2024-01-20'),
(1, 4, 5, 'Changed my cooking game.', '2024-03-05'),
(2, 6, 5, 'Excellent for beginners.', '2024-03-10'),
(3, 7, 4, 'Fits well, good quality.', '2024-01-15'),
(4, 9, 5, 'Love the RGB lighting.', '2024-03-12'),
(5, 10, 4, 'Sound quality is impressive.', '2024-03-08');

INSERT INTO orders (customer_id, address_id, order_date, status, total_amount) VALUES
(1, 1, '2024-03-01 10:30:00', 'delivered', 1419.98),
(2, 3, '2024-03-05 14:15:00', 'shipped', 1299.99),
(3, 4, '2024-03-10 09:00:00', 'pending', 119.99),
(4, 5, '2024-03-12 16:45:00', 'delivered', 309.97),
(5, 6, '2024-03-15 11:20:00', 'delivered', 189.98),
(1, 1, '2024-03-18 13:00:00', 'processing', 59.99),
(2, 3, '2024-03-20 08:30:00', 'pending', 899.99),
(3, 4, '2024-02-25 17:10:00', 'delivered', 44.98);

INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 1299.99),
(1, 4, 1, 119.99),
(2, 1, 1, 1299.99),
(4, 3, 1, 249.99),
(4, 8, 1, 39.99),
(4, 6, 1, 19.99),
(5, 9, 1, 89.99),
(5, 10, 1, 99.99),
(6, 7, 1, 59.99),
(7, 2, 1, 899.99),
(8, 5, 2, 14.99),
(8, 6, 1, 15.00),
(3, 4, 1, 119.99);

UPDATE orders SET total_amount = (
    SELECT SUM(quantity * price_at_purchase) FROM order_items WHERE order_id = orders.order_id
)
WHERE order_id > 0;

INSERT INTO shipping (order_id, tracking_number, carrier, status, estimated_delivery, shipped_date, delivered_date) VALUES
(1, 'TRK123456789', 'FedEx', 'delivered', '2024-03-04', '2024-03-01', '2024-03-03'),
(2, 'TRK987654321', 'UPS', 'in_transit', '2024-03-08', '2024-03-06', NULL),
(3, 'TRK456789123', 'USPS', 'pending', '2024-03-15', NULL, NULL),
(4, 'TRK789123456', 'FedEx', 'delivered', '2024-03-15', '2024-03-13', '2024-03-14'),
(5, 'TRK321654987', 'UPS', 'delivered', '2024-03-18', '2024-03-16', '2024-03-17'),
(8, 'TRK654987321', 'USPS', 'delivered', '2024-02-28', '2024-02-26', '2024-02-27');

-- ============================================
-- VIEWS
-- ============================================

CREATE OR REPLACE VIEW vw_product_catalog AS
SELECT 
    p.product_id,
    p.name AS product_name,
    p.description,
    p.price,
    p.stock_quantity,
    c.name AS category,
    IFNULL(pc.name, 'Top Category') AS parent_category,
    s.store_name AS seller,
    s.rating AS seller_rating,
    ROUND(AVG(r.rating), 2) AS avg_product_rating,
    COUNT(r.review_id) AS total_reviews
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN categories pc ON c.parent_category_id = pc.category_id
JOIN sellers s ON p.seller_id = s.seller_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name, p.description, p.price, p.stock_quantity,
         c.name, pc.name, s.store_name, s.rating;

CREATE OR REPLACE VIEW vw_order_details AS
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS customer_email,
    a.street,
    a.city,
    a.state,
    a.zip_code,
    o.order_date,
    o.status AS order_status,
    o.total_amount,
    p.name AS product_name,
    oi.quantity,
    oi.price_at_purchase,
    (oi.quantity * oi.price_at_purchase) AS line_total,
    sh.tracking_number,
    sh.carrier,
    sh.status AS shipping_status,
    sh.estimated_delivery
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN addresses a ON o.address_id = a.address_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN shipping sh ON o.order_id = sh.order_id;
