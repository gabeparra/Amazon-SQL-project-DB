USE amazon_ecommerce;

-- ============================================
-- UPDATE OPERATIONS
-- ============================================

-- 1. Update customer phone number
UPDATE customers 
SET phone = '555-0202' 
WHERE customer_id = 6;

-- 2. Update product stock after a sale
UPDATE products 
SET stock_quantity = stock_quantity - 2 
WHERE product_id = 11;

-- 3. Update order status to "shipped"
UPDATE orders 
SET status = 'shipped' 
WHERE order_id = 6;

-- Also update shipping record
UPDATE shipping 
SET status = 'in_transit', shipped_date = CURDATE(), tracking_number = 'TRK999888777'
WHERE order_id = 6;
