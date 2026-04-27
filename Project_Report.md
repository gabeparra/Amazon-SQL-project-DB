Amazon-Style E-Commerce Platform Database

Project Report


1. Project Overview

Our team designed and implemented a simplified Amazon-like e-commerce database system using MySQL. The system models the core operations of an online marketplace, supporting the full lifecycle of an online purchase: product browsing, order placement, shipping tracking, and customer reviews. The database manages products across multiple categories, customer accounts with addresses and payment methods, seller storefronts, and shipping logistics. All tables are normalized to Third Normal Form (3NF) to ensure data integrity and minimize redundancy. We also built a Flask-based web application as a frontend interface that connects directly to the database and provides full CRUD functionality through a browser.


2. ER Diagram

[Insert ER Diagram here]

The ER diagram illustrates the following entities and their relationships:

- Customers have a one-to-many relationship with Addresses, Payment Methods, Orders, and Reviews.
- Sellers have a one-to-many relationship with Products.
- Categories use a self-referencing one-to-many relationship to support subcategories, and have a one-to-many relationship with Products.
- Products have a one-to-many relationship with Reviews and Order Items.
- Orders have a one-to-many relationship with Order Items, and a one-to-one relationship with Shipping.
- Order Items serves as a linking table between Orders and Products.


3. Description of Tables and Relationships

The database consists of 10 tables:

Customers stores user account information including first name, last name, email (unique), and phone number. Each customer can have multiple addresses stored in the Addresses table, which includes street, city, state, zip code, and a default flag. Payment Methods stores card type, last four digits, and expiry date for each customer.

Categories supports a hierarchical structure using a self-referencing foreign key (parent_category_id), allowing unlimited levels of subcategories such as Electronics > Computers or Home & Kitchen > Furniture.

Sellers stores marketplace vendor information including store name, rating, total reviews, and join date. Each seller can list multiple products in the Products table, which includes name, description, price, stock quantity, and references to both the seller and category.

Reviews links customers to products with a rating (1-5), comment, and date. A unique constraint on (customer_id, product_id) ensures each customer can only review a product once.

Orders records each purchase with a reference to the customer and shipping address, along with order date, status (pending, processing, shipped, delivered, or cancelled), and total amount. Order Items stores the individual line items for each order, capturing quantity and price at purchase to preserve historical pricing. Shipping tracks delivery information with tracking number, carrier, status, and relevant dates, linked one-to-one with orders.

All foreign key relationships use appropriate ON DELETE and ON UPDATE actions (CASCADE, RESTRICT, or SET NULL) to maintain referential integrity. CHECK constraints enforce valid values for ratings, prices, quantities, and status fields.


4. Implemented Operations

CRUD Operations:
- Insert: Adding new customers with addresses and payment methods, creating new products under sellers and categories, placing orders with multiple line items, and submitting product reviews.
- Update: Modifying customer information, updating product details and stock quantities, changing order status (e.g., from pending to shipped to delivered), and updating shipping tracking information.
- Delete: Removing reviews, cancelling orders with cascading deletion of related order items and shipping records, and deleting products with foreign key constraint error handling.

Search and Filtering Queries:
- Product search by partial name matching using LIKE queries.
- Filtering products by category, price range, and seller.
- Order search by customer and status.
- Customer search by name or email.

Reports (using aggregations and joins):
- Top-selling products ranked by total quantity sold.
- Revenue by seller report using SUM aggregation.
- Monthly sales trends with date-based grouping.
- Average product ratings using AVG aggregation.
- Full order details joining five tables (orders, customers, addresses, order items, products, and shipping).
- Low stock product alerts.

Views:
We created two views that provide meaningful business insights:

1. vw_product_catalog consolidates product information with the seller name, seller rating, category hierarchy (category and parent category), average product rating, and total number of reviews. This view joins four tables (products, categories, sellers, and reviews) and uses GROUP BY with aggregate functions.

2. vw_order_details provides a complete order view including customer name and email, shipping address, order date and status, individual product line items with quantities and prices, line totals, and shipping tracking information. This view joins six tables (orders, customers, addresses, order items, products, and shipping).


5. Challenges Faced

One challenge was deciding how to handle historical pricing. If a product's price changes after a customer places an order, the order total should still reflect the original price. We solved this by adding a price_at_purchase column to the order_items table, which captures the price at the time of purchase independently from the current product price.

Another challenge was modeling the category hierarchy. We needed to support multiple levels of subcategories (e.g., Electronics > Smartphones) without creating separate tables for each level. We used a self-referencing foreign key in the categories table, where parent_category_id references category_id in the same table, allowing unlimited depth.

A third challenge involved connecting the Flask frontend running in WSL (Windows Subsystem for Linux) to a MySQL server running on Windows. Because WSL operates as a separate network environment, we had to configure the MySQL user permissions to allow connections from the WSL IP address and identify the correct network adapter IP for the connection.


6. Future Improvements

Given more time, we would make the following improvements to the system:
- Implement a shopping cart table to allow customers to save items before placing an order, which is currently not modeled in the database.
- Add inventory transaction logging to track stock changes over time, providing better visibility into inventory movements beyond the current stock_quantity field.
- Create database triggers to automatically update seller ratings and total review counts when new reviews are submitted, rather than requiring manual updates.
- Implement a more complex shipping workflow supporting multiple packages per order and integration with carrier tracking APIs.
- Add user authentication and role-based access control to the frontend application to restrict operations based on user roles (customer, seller, admin).


7. AI Usage Declaration

We used ChatGPT to assist with brainstorming entity relationships, refining the scope of operations for the e-commerce model, and generating SQL query examples. We also used Claude (Anthropic) to assist with debugging the Flask frontend application and configuring the database connection between WSL and Windows MySQL.
