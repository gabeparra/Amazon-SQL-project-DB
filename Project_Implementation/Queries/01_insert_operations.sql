USE amazon_ecommerce;

-- ============================================
-- INSERT OPERATIONS
-- ============================================

-- 1. Insert a new customer
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Frank', 'Miller', 'frank.miller@email.com', '555-0201');

-- 2. Insert a new product listing (seller adds product)
INSERT INTO products (seller_id, category_id, name, description, price, stock_quantity)
VALUES (1, 2, 'UltraWide Monitor 34"', '3440x1440 curved display', 549.99, 25);

-- 3. Insert multiple order items at once
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(6, 11, 1, 549.99),
(6, 9, 1, 89.99);

-- Update order total after adding items
UPDATE orders 
SET total_amount = (
    SELECT SUM(quantity * price_at_purchase) 
    FROM order_items 
    WHERE order_id = 6
)
WHERE order_id = 6;
