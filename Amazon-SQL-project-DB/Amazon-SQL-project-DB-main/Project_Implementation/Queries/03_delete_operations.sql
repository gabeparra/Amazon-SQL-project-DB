USE amazon_ecommerce;

-- ============================================
-- DELETE OPERATIONS
-- ============================================

-- 1. Delete a specific review
DELETE FROM reviews 
WHERE review_id = 6;

-- 2. Cancel an order and cascade delete its items and shipping
-- (Demonstrating ON DELETE CASCADE)
DELETE FROM orders 
WHERE order_id = 3;

-- Note: order_items and shipping for order_id 3 are automatically deleted
-- due to CASCADE constraints.
