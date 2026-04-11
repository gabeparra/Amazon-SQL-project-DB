# Normalization to 3NF - Amazon E-Commerce Database

## 1NF (First Normal Form)
All attributes are atomic:
- Customer addresses are stored in a separate `addresses` table instead of multiple address columns in `customers`
- Payment methods are stored in `payment_methods` table
- Product categories support hierarchy through self-referencing `categories` table
- Order items are stored individually in `order_items`, not as repeated groups in `orders`

## 2NF (Second Normal Form)
All tables have simple primary keys (single-column AUTO_INCREMENT), eliminating partial dependencies:
- `products` depends entirely on `product_id`, not on any part of a composite key
- `order_items` uses its own surrogate key while referencing `order_id` and `product_id`
- No non-key attribute depends on only a portion of the primary key

## 3NF (Third Normal Form)
No transitive dependencies exist:
- Seller information (store_name, rating) is in `sellers`, not duplicated in `products`
- Category hierarchy is in `categories`, not embedded in `products`
- `price_at_purchase` in `order_items` captures the historical price, avoiding dependency on current `products.price`
- Shipping details are in a separate `shipping` table, avoiding transitive dependency through `orders`
- Customer profile data is in `customers`; address and payment details are in separate tables
