USE amazon_ecommerce;

-- ============================================
-- VIEW 2: Complete Order Details
-- Useful for customer service and order tracking
-- ============================================

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

-- Example usage:
-- SELECT * FROM vw_order_details WHERE order_id = 1;
-- SELECT * FROM vw_order_details WHERE shipping_status = 'in_transit';
