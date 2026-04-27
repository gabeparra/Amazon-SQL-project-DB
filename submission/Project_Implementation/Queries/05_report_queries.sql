USE amazon_ecommerce;

-- ============================================
-- REPORT QUERIES
-- ============================================

-- 1. Top-Selling Products (by quantity sold)
SELECT 
    p.product_id,
    p.name,
    s.store_name AS seller,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
FROM products p
JOIN sellers s ON p.seller_id = s.seller_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.name, s.store_name
ORDER BY total_sold DESC
LIMIT 5;

-- 2. Revenue by Seller
SELECT 
    s.seller_id,
    s.store_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
    AVG(s.rating) AS seller_rating
FROM sellers s
LEFT JOIN products p ON s.seller_id = p.seller_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status != 'cancelled'
GROUP BY s.seller_id, s.store_name
ORDER BY total_revenue DESC;

-- 3. Monthly Sales Trends
SELECT 
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(o.total_amount) AS monthly_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM orders o
WHERE o.status != 'cancelled'
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year, month;

-- 4. Average Product Ratings with Review Count
SELECT 
    p.product_id,
    p.name,
    c.name AS category,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name, c.name
ORDER BY avg_rating DESC, review_count DESC;

-- 5. Order Full Details (Joining 5 tables)
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    a.city,
    o.order_date,
    o.status AS order_status,
    p.name AS product,
    oi.quantity,
    oi.price_at_purchase,
    (oi.quantity * oi.price_at_purchase) AS item_total,
    sh.tracking_number,
    sh.carrier,
    sh.status AS shipping_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN addresses a ON o.address_id = a.address_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN shipping sh ON o.order_id = sh.order_id
ORDER BY o.order_date DESC;
