from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = 'amazon_db_secret_key'

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'root',  # CHANGE THIS TO YOUR MYSQL ROOT PASSWORD
    'database': 'amazon_ecommerce'
}

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

# ─── DASHBOARD ───────────────────────────────────────────────
@app.route('/')
def home():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT COUNT(*) AS total FROM customers")
    total_customers = cursor.fetchone()['total']
    cursor.execute("SELECT COUNT(*) AS total FROM products")
    total_products = cursor.fetchone()['total']
    cursor.execute("SELECT COUNT(*) AS total FROM orders")
    total_orders = cursor.fetchone()['total']
    cursor.execute("SELECT IFNULL(SUM(total_amount), 0) AS revenue FROM orders WHERE status != 'cancelled'")
    total_revenue = cursor.fetchone()['revenue']
    cursor.execute("SELECT COUNT(*) AS total FROM sellers")
    total_sellers = cursor.fetchone()['total']
    cursor.execute("""
        SELECT o.order_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
               o.total_amount, o.status, o.order_date
        FROM orders o JOIN customers c ON o.customer_id = c.customer_id
        ORDER BY o.order_date DESC LIMIT 5
    """)
    recent_orders = cursor.fetchall()
    cursor.execute("""
        SELECT name, stock_quantity FROM products
        ORDER BY stock_quantity ASC LIMIT 5
    """)
    low_stock = cursor.fetchall()
    cursor.execute("""
        SELECT p.name, SUM(oi.quantity) AS units_sold
        FROM products p JOIN order_items oi ON p.product_id = oi.product_id
        GROUP BY p.product_id ORDER BY units_sold DESC LIMIT 5
    """)
    top_products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html',
        total_customers=total_customers, total_products=total_products,
        total_orders=total_orders, total_revenue=total_revenue,
        total_sellers=total_sellers, recent_orders=recent_orders,
        low_stock=low_stock, top_products=top_products)

# ─── PRODUCTS ────────────────────────────────────────────────
@app.route('/products')
def products():
    search = request.args.get('q', '')
    category = request.args.get('category', '')
    min_price = request.args.get('min_price', '')
    max_price = request.args.get('max_price', '')
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT category_id, name FROM categories ORDER BY name")
    categories = cursor.fetchall()
    query = "SELECT * FROM vw_product_catalog WHERE 1=1"
    params = []
    if search:
        query += " AND product_name LIKE %s"
        params.append(f'%{search}%')
    if category:
        query += " AND category = %s"
        params.append(category)
    if min_price:
        query += " AND price >= %s"
        params.append(float(min_price))
    if max_price:
        query += " AND price <= %s"
        params.append(float(max_price))
    cursor.execute(query, params)
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('products.html', products=products, categories=categories,
        search_query=search, selected_category=category,
        min_price=min_price, max_price=max_price)

@app.route('/product/<int:id>/analytics')
def product_analytics(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM products WHERE product_id = %s", (id,))
    product = cursor.fetchone()
    cursor.execute("""
        SELECT SUM(oi.quantity) AS total_units_sold,
               COUNT(DISTINCT o.order_id) AS total_orders,
               SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = %s AND o.status != 'cancelled'
    """, (id,))
    sales = cursor.fetchone()
    cursor.execute("""
        SELECT COUNT(*) AS total_reviews,
               ROUND(AVG(rating), 2) AS avg_rating,
               SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) AS five_star,
               SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) AS four_star,
               SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) AS three_star,
               SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) AS two_star,
               SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) AS one_star
        FROM reviews WHERE product_id = %s
    """, (id,))
    ratings = cursor.fetchone()
    cursor.execute("""
        SELECT COUNT(DISTINCT o.customer_id) AS repeat_buyers
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE oi.product_id = %s
        AND o.customer_id IN (
            SELECT customer_id FROM orders
            GROUP BY customer_id HAVING COUNT(*) > 1
        )
    """, (id,))
    repeat = cursor.fetchone()
    cursor.execute("""
        SELECT r.rating, r.comment, r.created_at,
               CONCAT(c.first_name, ' ', c.last_name) AS customer_name
        FROM reviews r JOIN customers c ON r.customer_id = c.customer_id
        WHERE r.product_id = %s ORDER BY r.created_at DESC
    """, (id,))
    reviews = cursor.fetchall()
    cursor.execute("""
        SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
               SUM(oi.quantity) AS units
        FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = %s AND o.status != 'cancelled'
        GROUP BY month ORDER BY month ASC
    """, (id,))
    monthly = cursor.fetchall()
    cursor.close()
    conn.close()
    total_buyers = sales['total_orders'] or 0
    repeat_buyers = repeat['repeat_buyers'] or 0
    repeat_rate = round((repeat_buyers / total_buyers * 100), 1) if total_buyers > 0 else 0
    return render_template('product_analytics.html',
        product=product, sales=sales, ratings=ratings,
        repeat_rate=repeat_rate, reviews=reviews, monthly=monthly)

@app.route('/add_product', methods=['GET', 'POST'])
def add_product():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT seller_id, store_name FROM sellers ORDER BY store_name")
    sellers = cursor.fetchall()
    cursor.execute("SELECT category_id, name FROM categories ORDER BY name")
    categories = cursor.fetchall()
    if request.method == 'POST':
        cursor2 = conn.cursor()
        cursor2.execute(
            "INSERT INTO products (seller_id, category_id, name, description, price, stock_quantity) VALUES (%s,%s,%s,%s,%s,%s)",
            (request.form['seller_id'], request.form['category_id'], request.form['name'],
             request.form['description'], request.form['price'], request.form['stock_quantity'])
        )
        conn.commit()
        cursor2.close()
        cursor.close()
        conn.close()
        flash('Product added successfully!', 'success')
        return redirect(url_for('products'))
    cursor.close()
    conn.close()
    return render_template('add_product.html', sellers=sellers, categories=categories)

@app.route('/edit_product/<int:id>', methods=['GET', 'POST'])
def edit_product(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    if request.method == 'POST':
        cursor.execute(
            "UPDATE products SET seller_id=%s, category_id=%s, name=%s, description=%s, price=%s, stock_quantity=%s WHERE product_id=%s",
            (request.form['seller_id'], request.form['category_id'], request.form['name'],
             request.form['description'], request.form['price'], request.form['stock_quantity'], id)
        )
        conn.commit()
        cursor.close()
        conn.close()
        flash('Product updated successfully!', 'success')
        return redirect(url_for('products'))
    cursor.execute("SELECT * FROM products WHERE product_id = %s", (id,))
    product = cursor.fetchone()
    cursor.execute("SELECT seller_id, store_name FROM sellers ORDER BY store_name")
    sellers = cursor.fetchall()
    cursor.execute("SELECT category_id, name FROM categories ORDER BY name")
    categories = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('edit_product.html', product=product, sellers=sellers, categories=categories)

@app.route('/delete_product/<int:id>', methods=['POST'])
def delete_product(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM products WHERE product_id = %s", (id,))
        conn.commit()
        flash('Product deleted.', 'success')
    except mysql.connector.Error:
        flash('Cannot delete: product is referenced by existing orders or reviews.', 'error')
    finally:
        cursor.close()
        conn.close()
    return redirect(url_for('products'))

# ─── ORDERS ──────────────────────────────────────────────────
@app.route('/orders')
def orders():
    status_filter = request.args.get('status', '')
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    query = "SELECT * FROM vw_order_details"
    params = []
    if status_filter:
        query += " WHERE order_status = %s"
        params.append(status_filter)
    query += " ORDER BY order_date DESC"
    cursor.execute(query, params)
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('orders.html', orders=orders, status_filter=status_filter)

@app.route('/new_order', methods=['GET', 'POST'])
def new_order():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT customer_id, first_name, last_name, email FROM customers ORDER BY first_name")
    customers = cursor.fetchall()
    cursor.execute("SELECT p.product_id, p.name, p.price, p.stock_quantity FROM products p WHERE p.stock_quantity > 0 ORDER BY p.name")
    products = cursor.fetchall()
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        product_ids = request.form.getlist('product_id[]')
        quantities = request.form.getlist('quantity[]')
        cursor2 = conn.cursor(dictionary=True)
        cursor2.execute("SELECT address_id FROM addresses WHERE customer_id = %s LIMIT 1", (customer_id,))
        addr = cursor2.fetchone()
        if not addr:
            flash('Selected customer has no address on file. Please add an address first.', 'error')
            cursor.close()
            cursor2.close()
            conn.close()
            return render_template('new_order.html', customers=customers, products=products)
        address_id = addr['address_id']
        total = 0
        line_items = []
        for pid, qty in zip(product_ids, quantities):
            if pid and qty and int(qty) > 0:
                cursor2.execute("SELECT price, stock_quantity FROM products WHERE product_id = %s", (pid,))
                p = cursor2.fetchone()
                if p and p['stock_quantity'] >= int(qty):
                    total += float(p['price']) * int(qty)
                    line_items.append((int(pid), int(qty), float(p['price'])))
        if not line_items:
            flash('Please add at least one valid product with quantity.', 'error')
            cursor.close()
            cursor2.close()
            conn.close()
            return render_template('new_order.html', customers=customers, products=products)
        cursor2.execute(
            "INSERT INTO orders (customer_id, address_id, status, total_amount) VALUES (%s,%s,'pending',%s)",
            (customer_id, address_id, round(total, 2))
        )
        conn.commit()
        order_id = cursor2.lastrowid
        for pid, qty, price in line_items:
            cursor2.execute(
                "INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES (%s,%s,%s,%s)",
                (order_id, pid, qty, price)
            )
            cursor2.execute(
                "UPDATE products SET stock_quantity = stock_quantity - %s WHERE product_id = %s",
                (qty, pid)
            )
        conn.commit()
        cursor2.close()
        cursor.close()
        conn.close()
        flash(f'Order #{order_id} created successfully! Total: ${round(total,2)}', 'success')
        return redirect(url_for('orders'))
    cursor.close()
    conn.close()
    return render_template('new_order.html', customers=customers, products=products)

@app.route('/update_order_status/<int:id>', methods=['POST'])
def update_order_status(id):
    new_status = request.form['status']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE orders SET status = %s WHERE order_id = %s", (new_status, id))
    conn.commit()
    cursor.close()
    conn.close()
    flash(f'Order #{id} updated to {new_status}.', 'success')
    return redirect(url_for('orders'))

@app.route('/delete_order/<int:id>', methods=['POST'])
def delete_order(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM orders WHERE order_id = %s", (id,))
        conn.commit()
        flash(f'Order #{id} cancelled.', 'success')
    except mysql.connector.Error as e:
        flash(f'Cannot cancel order: {e}', 'error')
    finally:
        cursor.close()
        conn.close()
    return redirect(url_for('orders'))

# ─── CUSTOMERS ───────────────────────────────────────────────
@app.route('/customers')
def customers():
    search = request.args.get('q', '')
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    query = """
        SELECT c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.created_at,
               COUNT(DISTINCT o.order_id) AS total_orders,
               IFNULL(SUM(o.total_amount), 0) AS total_spent
        FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        WHERE 1=1
    """
    params = []
    if search:
        query += " AND (c.first_name LIKE %s OR c.last_name LIKE %s OR c.email LIKE %s)"
        params += [f'%{search}%', f'%{search}%', f'%{search}%']
    query += " GROUP BY c.customer_id ORDER BY c.created_at DESC"
    cursor.execute(query, params)
    customers = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('customers.html', customers=customers, search_query=search)

@app.route('/customer/<int:id>')
def customer_profile(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM customers WHERE customer_id = %s", (id,))
    customer = cursor.fetchone()
    cursor.execute("""
        SELECT COUNT(DISTINCT o.order_id) AS total_orders,
               IFNULL(SUM(o.total_amount), 0) AS total_spent,
               IFNULL(AVG(o.total_amount), 0) AS avg_order_value,
               MAX(o.order_date) AS last_order_date
        FROM orders o WHERE o.customer_id = %s AND o.status != 'cancelled'
    """, (id,))
    stats = cursor.fetchone()
    cursor.execute("""
        SELECT o.order_id, o.order_date, o.status, o.total_amount,
               p.name AS product_name, oi.quantity, oi.price_at_purchase,
               s.tracking_number, s.carrier, s.delivery_status
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        LEFT JOIN shipping s ON o.order_id = s.order_id
        WHERE o.customer_id = %s
        ORDER BY o.order_date DESC
    """, (id,))
    order_history = cursor.fetchall()
    cursor.execute("""
        SELECT p.name, SUM(oi.quantity) AS times_purchased
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.customer_id = %s AND o.status != 'cancelled'
        GROUP BY p.product_id ORDER BY times_purchased DESC LIMIT 5
    """, (id,))
    fav_products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('customer_profile.html',
        customer=customer, stats=stats,
        order_history=order_history, fav_products=fav_products)

@app.route('/add_customer', methods=['GET', 'POST'])
def add_customer():
    if request.method == 'POST':
        conn = get_db_connection()
        cursor = conn.cursor()
        try:
            cursor.execute(
                "INSERT INTO customers (first_name, last_name, email, phone) VALUES (%s,%s,%s,%s)",
                (request.form['first_name'], request.form['last_name'],
                 request.form['email'], request.form['phone'])
            )
            conn.commit()
            flash('Customer added successfully!', 'success')
            return redirect(url_for('customers'))
        except mysql.connector.IntegrityError:
            flash('Email already exists.', 'error')
        finally:
            cursor.close()
            conn.close()
    return render_template('add_customer.html')

@app.route('/edit_customer/<int:id>', methods=['GET', 'POST'])
def edit_customer(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    if request.method == 'POST':
        try:
            cursor.execute(
                "UPDATE customers SET first_name=%s, last_name=%s, email=%s, phone=%s WHERE customer_id=%s",
                (request.form['first_name'], request.form['last_name'],
                 request.form['email'], request.form['phone'], id)
            )
            conn.commit()
            flash('Customer updated.', 'success')
            return redirect(url_for('customers'))
        except mysql.connector.IntegrityError:
            flash('Email already in use by another customer.', 'error')
        finally:
            cursor.close()
            conn.close()
    cursor.execute("SELECT * FROM customers WHERE customer_id = %s", (id,))
    customer = cursor.fetchone()
    cursor.close()
    conn.close()
    return render_template('edit_customer.html', customer=customer)

@app.route('/delete_customer/<int:id>', methods=['POST'])
def delete_customer(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM customers WHERE customer_id = %s", (id,))
        conn.commit()
        flash('Customer deleted.', 'success')
    except mysql.connector.Error:
        flash('Cannot delete: customer has existing orders.', 'error')
    finally:
        cursor.close()
        conn.close()
    return redirect(url_for('customers'))

# ─── SELLERS ─────────────────────────────────────────────────
@app.route('/sellers')
def sellers():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT s.seller_id, s.store_name, s.rating, s.total_reviews, s.joined_date,
               COUNT(DISTINCT p.product_id) AS total_products,
               IFNULL(SUM(oi.quantity * oi.price_at_purchase), 0) AS total_revenue
        FROM sellers s
        LEFT JOIN products p ON s.seller_id = p.seller_id
        LEFT JOIN order_items oi ON p.product_id = oi.product_id
        GROUP BY s.seller_id ORDER BY total_revenue DESC
    """)
    sellers = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('sellers.html', sellers=sellers)

@app.route('/edit_seller/<int:id>', methods=['GET', 'POST'])
def edit_seller(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    if request.method == 'POST':
        cursor.execute(
            "UPDATE sellers SET store_name=%s, rating=%s WHERE seller_id=%s",
            (request.form['store_name'], request.form['rating'], id)
        )
        conn.commit()
        cursor.close()
        conn.close()
        flash('Seller updated.', 'success')
        return redirect(url_for('sellers'))
    cursor.execute("SELECT * FROM sellers WHERE seller_id = %s", (id,))
    seller = cursor.fetchone()
    cursor.close()
    conn.close()
    return render_template('edit_seller.html', seller=seller)

# ─── REPORTS ─────────────────────────────────────────────────
@app.route('/reports')
def reports():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT p.name AS product_name, cat.name AS category,
               SUM(oi.quantity) AS units_sold,
               SUM(oi.quantity * oi.price_at_purchase) AS revenue,
               COUNT(DISTINCT o.order_id) AS order_count,
               ROUND(AVG(r.rating), 2) AS avg_rating
        FROM products p
        JOIN order_items oi ON p.product_id = oi.product_id
        JOIN orders o ON oi.order_id = o.order_id
        JOIN categories cat ON p.category_id = cat.category_id
        LEFT JOIN reviews r ON p.product_id = r.product_id
        WHERE o.status != 'cancelled'
        GROUP BY p.product_id ORDER BY units_sold DESC
    """)
    top_products = cursor.fetchall()
    cursor.execute("""
        SELECT cat.name AS category,
               COUNT(DISTINCT p.product_id) AS total_products,
               SUM(oi.quantity) AS units_sold,
               SUM(oi.quantity * oi.price_at_purchase) AS revenue
        FROM categories cat
        JOIN products p ON cat.category_id = p.category_id
        JOIN order_items oi ON p.product_id = oi.product_id
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.status != 'cancelled'
        GROUP BY cat.category_id ORDER BY revenue DESC
    """)
    category_revenue = cursor.fetchall()
    cursor.execute("""
        SELECT s.store_name,
               COUNT(DISTINCT p.product_id) AS total_products,
               SUM(oi.quantity) AS units_sold,
               SUM(oi.quantity * oi.price_at_purchase) AS revenue,
               ROUND(s.rating, 1) AS rating
        FROM sellers s
        JOIN products p ON s.seller_id = p.seller_id
        JOIN order_items oi ON p.product_id = oi.product_id
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.status != 'cancelled'
        GROUP BY s.seller_id ORDER BY revenue DESC
    """)
    seller_revenue = cursor.fetchall()
    cursor.execute("""
        SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
               COUNT(*) AS total_orders,
               SUM(total_amount) AS revenue
        FROM orders WHERE status != 'cancelled'
        GROUP BY month ORDER BY month ASC
    """)
    monthly_sales = cursor.fetchall()
    cursor.execute("""
        SELECT CONCAT(c.first_name,' ',c.last_name) AS customer_name,
               COUNT(DISTINCT o.order_id) AS total_orders,
               SUM(o.total_amount) AS total_spent
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.status != 'cancelled'
        GROUP BY c.customer_id ORDER BY total_spent DESC LIMIT 5
    """)
    top_customers = cursor.fetchall()
    cursor.execute("""
        SELECT COUNT(*) AS total FROM orders WHERE status = 'pending'
    """)
    pending = cursor.fetchone()['total']
    cursor.execute("""
        SELECT COUNT(*) AS total FROM orders WHERE status = 'cancelled'
    """)
    cancelled = cursor.fetchone()['total']
    cursor.execute("""
        SELECT COUNT(*) AS total FROM orders WHERE status = 'delivered'
    """)
    delivered = cursor.fetchone()['total']
    cursor.close()
    conn.close()
    return render_template('reports.html',
        top_products=top_products, category_revenue=category_revenue,
        seller_revenue=seller_revenue, monthly_sales=monthly_sales,
        top_customers=top_customers,
        pending=pending, cancelled=cancelled, delivered=delivered)

if __name__ == '__main__':
    app.run(debug=True)
