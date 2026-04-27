FRONTEND SETUP (Windows)
=========================

1. EDIT PASSWORD IN app.py
   Open app.py and change this line:
      'password': 'rootpass123',
   to your actual MySQL root password.

2. INSTALL DEPENDENCIES
   Open CMD or PowerShell and run:
      pip install flask mysql-connector-python

3. RUN THE APP
   In CMD/PowerShell, navigate to this folder and run:
      python app.py

4. OPEN IN BROWSER
   Go to: http://127.0.0.1:5000

FEATURES
--------
- Home page with navigation
- /products         → Browse product catalog (with search)
- /orders           → View all order details
- /add_product      → Form to add new products to the database
- /edit_product/<id> → Edit an existing product (UPDATE)
- /delete_product/<id> → Delete a product (with FK error handling)
- /update_order_status/<id> → Change order status (inline dropdown)
- /delete_order/<id> → Cancel an order (CASCADE deletes items + shipping)

All operations display success/error flash messages.
Delete actions require JavaScript confirmation before executing.

SCREENSHOTS FOR EXTRA CREDIT
-----------------------------
Take screenshots of:
1. Home page
2. Product catalog page (with Actions column)
3. Order details page (with Actions column)
4. Add Product form (before and after adding)
5. Edit Product form (showing pre-populated fields)
6. Delete confirmation dialog
7. Flash message after a successful operation
8. MySQL Workbench showing the changes reflected in the database
