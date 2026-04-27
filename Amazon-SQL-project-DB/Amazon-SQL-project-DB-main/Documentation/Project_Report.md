# Amazon-Style E-Commerce Platform Database

## 1. Project Overview
Our team designed and implemented a simplified Amazon-like e-commerce database system using MySQL. The system supports the full lifecycle of an online purchase, including product browsing, order placement, payment processing, shipping tracking, and customer reviews. The database is normalized to Third Normal Form (3NF) to ensure data integrity and minimize redundancy.

## 2. Entity-Relationship Diagram
Our ER diagram includes the following entities and relationships:

- **Customers** (1:N) → Addresses, Payment_Methods, Orders, Reviews
- **Sellers** (1:N) → Products
- **Categories** (self-referencing 1:N) → Subcategories → Products
- **Products** (1:N) → Reviews, Order_Items
- **Orders** (1:N) → Order_Items; (1:1) → Shipping
- **Order_Items** links Orders and Products

### Key Attributes:
- Customers: customer_id (PK), first_name, last_name, email (UNIQUE), phone
- Addresses: address_id (PK), customer_id (FK), street, city, state, zip_code
- Payment_Methods: payment_id (PK), customer_id (FK), card_type, last_four, expiry_date
- Sellers: seller_id (PK), store_name, rating, total_reviews
- Categories: category_id (PK), name, parent_category_id (FK, self-ref)
- Products: product_id (PK), seller_id (FK), category_id (FK), name, description, price, stock_quantity
- Reviews: review_id (PK), customer_id (FK), product_id (FK), rating, comment
- Orders: order_id (PK), customer_id (FK), address_id (FK), order_date, status, total_amount
- Order_Items: order_item_id (PK), order_id (FK), product_id (FK), quantity, price_at_purchase
- Shipping: shipping_id (PK), order_id (FK, UNIQUE), tracking_number, carrier, status, estimated_delivery

## 3. Relational Schema and Normalization

### 3.1 Tables
| Table | Purpose | Key Constraints |
|-------|---------|-----------------|
| customers | Store user accounts | PK: customer_id, UNIQUE: email |
| addresses | Store multiple addresses per customer | PK: address_id, FK: customer_id |
| payment_methods | Store payment options | PK: payment_id, FK: customer_id |
| categories | Product categories and subcategories | PK: category_id, self-referencing FK |
| sellers | Store seller storefronts | PK: seller_id |
| products | Product catalog | PK: product_id, FKs: seller_id, category_id |
| reviews | Customer product reviews | PK: review_id, FKs: customer_id, product_id, UNIQUE combo |
| orders | Purchase records | PK: order_id, FKs: customer_id, address_id |
| order_items | Line items per order | PK: order_item_id, FKs: order_id, product_id |
| shipping | Delivery tracking | PK: shipping_id, FK: order_id (UNIQUE) |

### 3.2 Normalization Process
**1NF:** All attributes are atomic. Multi-valued data (addresses, payments, order items) were moved to separate tables.

**2NF:** All tables use a single-column surrogate key (AUTO_INCREMENT), eliminating partial dependencies.

**3NF:** No transitive dependencies exist:
- Seller details are in `sellers`, not in `products`
- Category hierarchy is in `categories`, not embedded in products
- `price_at_purchase` in `order_items` captures historical prices, avoiding dependency on current product price
- Shipping tracking is in a separate table, avoiding transitive dependency through orders

## 4. Implementation

### 4.1 Table Creation
All 10 tables were created in MySQL Workbench with appropriate data types, primary keys, foreign keys, and constraints including CHECK and UNIQUE constraints.

### 4.2 CRUD Operations
- **Insert:** Adding new customers, products, and order items
- **Update:** Modifying customer phone numbers, product stock, and order/shipping status
- **Delete:** Removing reviews and cancelling orders (with CASCADE deletion of related items and shipping)

### 4.3 Queries and Reports
Implemented search/filter queries and business reports:
- Product search by partial name matching
- Price range and category filtering
- Order search by customer and status
- Top-selling products report
- Revenue by seller report
- Monthly sales trends with aggregation
- Average product ratings
- Full order details joining 5 tables

### 4.4 Views
Two meaningful views were created:
1. **vw_product_catalog:** Consolidates product info with seller, category hierarchy, and average rating
2. **vw_order_details:** Provides a complete order view including customer, address, items, and shipping status

## 5. Frontend Web Application
We built a Flask-based web interface that connects to the MySQL database and provides full CRUD functionality through a browser.

### 5.1 Technology Stack
- **Backend:** Python Flask web framework
- **Database Connector:** mysql-connector-python
- **Frontend:** HTML with inline CSS (Amazon-themed styling)

### 5.2 Routes and Features
| Route | Method | Operation | Description |
|-------|--------|-----------|-------------|
| `/` | GET | — | Home page with navigation links |
| `/products` | GET | READ | Browse product catalog using `vw_product_catalog` view |
| `/search_products` | GET | READ | Search products by name (LIKE query) |
| `/add_product` | GET/POST | CREATE | Form to insert a new product |
| `/edit_product/<id>` | GET/POST | UPDATE | Edit form pre-populated with current product data |
| `/delete_product/<id>` | POST | DELETE | Remove a product (with FK error handling) |
| `/orders` | GET | READ | View all orders using `vw_order_details` view |
| `/update_order_status/<id>` | POST | UPDATE | Change order status via inline dropdown |
| `/delete_order/<id>` | POST | DELETE | Cancel an order (CASCADE removes items and shipping) |

### 5.3 Error Handling
- Foreign key constraint violations are caught and displayed as user-friendly flash messages (e.g., attempting to delete a product referenced by existing orders)
- JavaScript confirmation dialogs prevent accidental deletions
- Flash messages provide feedback for all create, update, and delete operations

## 6. Challenges Faced
One challenge was deciding how to handle historical pricing. We solved this by adding `price_at_purchase` to `order_items`, ensuring order totals remain accurate even if product prices change later. Another challenge was modeling the category hierarchy; we used a self-referencing foreign key in the `categories` table to support unlimited subcategory levels.

## 7. Future Improvements
Given more time, we would:
- Implement a shopping cart table (currently not modeled)
- Add inventory transaction logging for better stock tracking
- Add triggers to automatically update seller ratings when new reviews are submitted
- Implement a more complex shipping workflow with multiple packages per order

## 8. AI Usage Declaration
We used ChatGPT to assist with brainstorming entity relationships, refining the scope of operations, and generating SQL query examples for the e-commerce model.