import os
import secrets
from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY') or secrets.token_hex(32)

# MySQL Connection Config (configure via environment variables; see .env.example)
DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', '127.0.0.1'),
    'port': int(os.getenv('MYSQL_PORT', '3306')),
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('MYSQL_PASSWORD', ''),
    'database': os.getenv('MYSQL_DATABASE', 'amazon_ecommerce'),
}

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/products')
def products():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vw_product_catalog")
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('products.html', products=products)

@app.route('/orders')
def orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vw_order_details ORDER BY order_date DESC")
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('orders.html', orders=orders)

@app.route('/add_product', methods=['GET', 'POST'])
def add_product():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT seller_id, store_name FROM sellers ORDER BY store_name")
    sellers = cursor.fetchall()
    
    cursor.execute("SELECT category_id, name FROM categories ORDER BY name")
    categories = cursor.fetchall()
    
    if request.method == 'POST':
        seller_id = request.form['seller_id']
        category_id = request.form['category_id']
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        stock_quantity = request.form['stock_quantity']
        
        insert_cursor = conn.cursor()
        insert_cursor.execute(
            """INSERT INTO products (seller_id, category_id, name, description, price, stock_quantity)
               VALUES (%s, %s, %s, %s, %s, %s)""",
            (seller_id, category_id, name, description, price, stock_quantity)
        )
        conn.commit()
        insert_cursor.close()
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
        seller_id = request.form['seller_id']
        category_id = request.form['category_id']
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        stock_quantity = request.form['stock_quantity']
        cursor.execute(
            """UPDATE products SET seller_id=%s, category_id=%s, name=%s,
               description=%s, price=%s, stock_quantity=%s WHERE product_id=%s""",
            (seller_id, category_id, name, description, price, stock_quantity, id)
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
        flash('Product deleted successfully!', 'success')
    except mysql.connector.Error as e:
        flash(f'Cannot delete product: it is referenced by existing orders or reviews.', 'error')
    finally:
        cursor.close()
        conn.close()
    return redirect(url_for('products'))

@app.route('/update_order_status/<int:id>', methods=['POST'])
def update_order_status(id):
    new_status = request.form['status']
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE orders SET status = %s WHERE order_id = %s", (new_status, id))
    conn.commit()
    cursor.close()
    conn.close()
    flash(f'Order #{id} status updated to {new_status}.', 'success')
    return redirect(url_for('orders'))

@app.route('/delete_order/<int:id>', methods=['POST'])
def delete_order(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM orders WHERE order_id = %s", (id,))
        conn.commit()
        flash(f'Order #{id} cancelled successfully.', 'success')
    except mysql.connector.Error as e:
        flash(f'Cannot cancel order: {e}', 'error')
    finally:
        cursor.close()
        conn.close()
    return redirect(url_for('orders'))

@app.route('/search_products', methods=['GET'])
def search_products():
    query = request.args.get('q', '')
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT * FROM vw_product_catalog WHERE product_name LIKE %s",
        (f'%{query}%',)
    )
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('products.html', products=products, search_query=query)

if __name__ == '__main__':
    app.run(debug=os.getenv('FLASK_DEBUG', '').lower() in ('1', 'true', 'yes'))
