USE amazon_ecommerce;

-- ============================================
-- INSERT CATEGORIES
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

-- ============================================
-- INSERT SELLERS
-- ============================================
INSERT INTO sellers (store_name, rating, total_reviews, joined_date) VALUES
('TechWorld Store', 4.5, 1200, '2022-03-15'),
('HomeComfort', 4.2, 850, '2021-07-20'),
('BookHaven', 4.8, 3400, '2020-01-10'),
('FashionHub', 3.9, 560, '2023-05-05'),
('GadgetZone', 4.1, 920, '2022-11-30');

-- ============================================
-- INSERT CUSTOMERS
-- ============================================
INSERT INTO customers (first_name, last_name, email, phone) VALUES
('Alice', 'Johnson', 'alice.j@email.com', '555-0101'),
('Bob', 'Smith', 'bob.smith@email.com', '555-0102'),
('Carlos', 'Ruiz', 'carlos.r@email.com', '555-0103'),
('Diana', 'Lee', 'diana.lee@email.com', '555-0104'),
('Emma', 'Brown', 'emma.brown@email.com', '555-0105');

-- ============================================
-- INSERT ADDRESSES
-- ============================================
INSERT INTO addresses (customer_id, street, city, state, zip_code, country, is_default) VALUES
(1, '123 Maple St', 'Austin', 'TX', '78701', 'USA', TRUE),
(1, '456 Oak Ave', 'Dallas', 'TX', '75201', 'USA', FALSE),
(2, '789 Pine Rd', 'Seattle', 'WA', '98101', 'USA', TRUE),
(3, '321 Birch Ln', 'Miami', 'FL', '33101', 'USA', TRUE),
(4, '654 Cedar Blvd', 'Denver', 'CO', '80201', 'USA', TRUE),
(5, '987 Spruce Way', 'Boston', 'MA', '02101', 'USA', TRUE);

-- ============================================
-- INSERT PAYMENT METHODS
-- ============================================
INSERT INTO payment_methods (customer_id, card_type, last_four, expiry_date, is_default) VALUES
(1, 'Visa', '1234', '2027-05-01', TRUE),
(2, 'Mastercard', '5678', '2026-08-01', TRUE),
(3, 'Amex', '9012', '2028-12-01', TRUE),
(4, 'Visa', '3456', '2027-03-01', TRUE),
(5, 'Discover', '7890', '2026-11-01', TRUE);

-- ============================================
-- INSERT PRODUCTS
-- ============================================
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

-- ============================================
-- INSERT REVIEWS
-- ============================================
INSERT INTO reviews (customer_id, product_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Amazing performance for gaming!', '2024-02-10'),
(2, 1, 4, 'Great laptop but runs hot.', '2024-02-15'),
(3, 2, 5, 'Best phone I have ever owned.', '2024-03-01'),
(4, 3, 4, 'Very comfortable for long hours.', '2024-01-20'),
(1, 4, 5, 'Changed my cooking game.', '2024-03-05'),
(5, 5, 3, 'Good plot but slow start.', '2024-02-28'),
(2, 6, 5, 'Excellent for beginners.', '2024-03-10'),
(3, 7, 4, 'Fits well, good quality.', '2024-01-15'),
(4, 9, 5, 'Love the RGB lighting.', '2024-03-12'),
(5, 10, 4, 'Sound quality is impressive.', '2024-03-08');

-- ============================================
-- INSERT ORDERS
-- ============================================
INSERT INTO orders (customer_id, address_id, order_date, status, total_amount) VALUES
(1, 1, '2024-03-01 10:30:00', 'delivered', 1419.98),
(2, 3, '2024-03-05 14:15:00', 'shipped', 1299.99),
(3, 4, '2024-03-10 09:00:00', 'pending', 119.99),
(4, 5, '2024-03-12 16:45:00', 'delivered', 309.97),
(5, 6, '2024-03-15 11:20:00', 'delivered', 189.98),
(1, 1, '2024-03-18 13:00:00', 'processing', 59.99),
(2, 3, '2024-03-20 08:30:00', 'pending', 899.99),
(3, 4, '2024-02-25 17:10:00', 'delivered', 44.98);

-- ============================================
-- INSERT ORDER ITEMS
-- ============================================
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 1299.99),   -- Gaming Laptop
(1, 4, 1, 119.99),    -- Air Fryer
(2, 1, 1, 1299.99),   -- Gaming Laptop
(3, 2, 1, 899.99),    -- Smartphone
(4, 3, 1, 249.99),    -- Chair
(4, 8, 1, 39.99),     -- Dress
(4, 6, 1, 19.99),     -- Learn SQL (on sale)
(5, 9, 1, 89.99),     -- Keyboard
(5, 10, 1, 99.99),    -- Earbuds (on sale)
(6, 7, 1, 59.99),     -- Denim Jacket
(7, 2, 1, 899.99),    -- Smartphone
(8, 5, 2, 14.99),     -- The Lost City (x2)
(8, 6, 1, 15.00);     -- Learn SQL (on sale)

-- Fix order 3: Air Fryer
DELETE FROM order_items WHERE order_id = 3;
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(3, 4, 1, 119.99);    -- Air Fryer XL

-- Update order totals to match reality
UPDATE orders SET total_amount = (
    SELECT SUM(quantity * price_at_purchase) FROM order_items WHERE order_id = orders.order_id
)
WHERE order_id > 0;

-- ============================================
-- INSERT SHIPPING
-- ============================================
INSERT INTO shipping (order_id, tracking_number, carrier, status, estimated_delivery, shipped_date, delivered_date) VALUES
(1, 'TRK123456789', 'FedEx', 'delivered', '2024-03-04', '2024-03-01', '2024-03-03'),
(2, 'TRK987654321', 'UPS', 'in_transit', '2024-03-08', '2024-03-06', NULL),
(3, 'TRK456789123', 'USPS', 'pending', '2024-03-15', NULL, NULL),
(4, 'TRK789123456', 'FedEx', 'delivered', '2024-03-15', '2024-03-13', '2024-03-14'),
(5, 'TRK321654987', 'UPS', 'delivered', '2024-03-18', '2024-03-16', '2024-03-17'),
(8, 'TRK654987321', 'USPS', 'delivered', '2024-02-28', '2024-02-26', '2024-02-27');
