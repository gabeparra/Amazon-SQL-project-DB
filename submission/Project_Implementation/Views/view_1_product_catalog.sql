USE amazon_ecommerce;

-- ============================================
-- VIEW 1: Product Catalog with Seller, Category, and Ratings
-- Useful for browsing products with all relevant info in one place
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

-- Example usage:
-- SELECT * FROM vw_product_catalog WHERE price < 100 ORDER BY avg_product_rating DESC;
