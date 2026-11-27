USE amazon_ecommerce;

-- ============================================
-- SEARCH & FILTER QUERIES
-- ============================================

-- 1. Search products by name (partial match)
SELECT product_id, name, price, stock_quantity
FROM products
WHERE name LIKE '%Laptop%';

-- 2. Filter products by price range
SELECT p.name, p.price, c.name AS category, s.store_name AS seller
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN sellers s ON p.seller_id = s.seller_id
WHERE p.price BETWEEN 100 AND 500
ORDER BY p.price DESC;

-- 3. Filter products by category and minimum stock
SELECT p.name, p.price, p.stock_quantity, c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE (
    c.name = 'Electronics'
    OR c.parent_category_id = (SELECT category_id FROM categories WHERE name = 'Electronics')
)
  AND p.stock_quantity > 50;

-- 4. Search orders by customer name and status
SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS customer,
       o.order_date, o.status, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.last_name LIKE '%son%'
  AND o.status = 'delivered';

-- 5. Find all products with average rating >= 4
SELECT p.name, AVG(r.rating) AS avg_rating, COUNT(r.review_id) AS total_reviews
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
HAVING avg_rating >= 4
ORDER BY avg_rating DESC;
