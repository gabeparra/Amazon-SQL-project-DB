FRONTEND SETUP
==============

1. INSTALL DEPENDENCIES
   Run from the repository root (or inside frontend/):
      pip install -r frontend/requirements.txt

2. CONFIGURE MYSQL CONNECTION
   Set environment variables (see frontend/.env.example):
      MYSQL_HOST=127.0.0.1
      MYSQL_PORT=3306
      MYSQL_USER=root
      MYSQL_PASSWORD=your_mysql_password
      MYSQL_DATABASE=amazon_ecommerce
      FLASK_SECRET_KEY=change-me-local-dev

3. RUN THE APP
      python frontend/app.py

4. OPEN IN BROWSER
   Go to: http://127.0.0.1:5000

FEATURES
--------
- /                          -> Home page with navigation
- /products                  -> Browse product catalog (with search)
- /search_products           -> Partial-name search
- /orders                    -> View all order details
- /add_product               -> Form to add new products to the database
- /edit_product/<id>         -> Edit an existing product (UPDATE)
- /delete_product/<id>       -> Delete a product (with FK error handling)
- /update_order_status/<id>  -> Change order status (inline dropdown)
- /delete_order/<id>         -> Cancel an order (CASCADE deletes items + shipping)
