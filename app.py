from flask import Flask, request, jsonify, render_template, session, send_from_directory
import mysql.connector
import hashlib
import os
import re

app = Flask(__name__)
app.secret_key = 'foodrush_v3_secret_2024'

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'mysqlserver',   # 🔑 Change this to your MySQL password
    'database': 'zomato'
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

def hash_pass(p):
    return hashlib.sha256(p.encode()).hexdigest()


# ─── PAGES ───────────────────────────────────────────────────────────────────

@app.route('/')
def index():
    return render_template('index.html')


# ─── STATIC IMAGES ───────────────────────────────────────────────────────────

@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory('static', filename)


# ─── AUTH ─────────────────────────────────────────────────────────────────────

@app.route('/signup', methods=['POST'])
def signup():
    d = request.get_json()
    name     = d.get('name', '').strip()
    email    = d.get('email', '').strip().lower()
    phone    = d.get('phone', '').strip()
    password = d.get('password', '')

    if not all([name, email, phone, password]):
        return jsonify({'error': 'All fields are required'}), 400
    if not re.match(r'^[^\s@]+@[^\s@]+\.[^\s@]+$', email):
        return jsonify({'error': 'Invalid email address'}), 400
    if not re.match(r'^\d{10}$', phone):
        return jsonify({'error': 'Phone must be 10 digits'}), 400
    if len(password) < 6:
        return jsonify({'error': 'Password must be at least 6 characters'}), 400

    conn = get_db(); cur = conn.cursor()
    try:
        cur.execute("SELECT user_id FROM users WHERE email=%s", (email,))
        if cur.fetchone():
            return jsonify({'error': 'Email already registered! Please log in.'}), 409
        cur.execute(
            "INSERT INTO users (name, email, phone, password_hash) VALUES (%s,%s,%s,%s)",
            (name, email, phone, hash_pass(password))
        )
        conn.commit()
        uid = cur.lastrowid
        session['user_id']    = uid
        session['user_name']  = name
        session['user_email'] = email
        return jsonify({'message': 'Account created!', 'user': {'id': uid, 'name': name, 'email': email}}), 201
    finally:
        cur.close(); conn.close()


@app.route('/login', methods=['POST'])
def login():
    d = request.get_json()
    email    = d.get('email', '').strip().lower()
    password = d.get('password', '')

    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("SELECT * FROM users WHERE email=%s", (email,))
        user = cur.fetchone()
        if not user:
            return jsonify({'error': 'No account found with this email. Please sign up first.'}), 404
        if user['password_hash'] != hash_pass(password):
            return jsonify({'error': 'Wrong password! Please try again.'}), 401
        session['user_id']    = user['user_id']
        session['user_name']  = user['name']
        session['user_email'] = user['email']
        return jsonify({'message': 'Login successful!', 'user': {
            'id': user['user_id'], 'name': user['name'], 'email': user['email']
        }}), 200
    finally:
        cur.close(); conn.close()


@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'message': 'Logged out'}), 200


@app.route('/me', methods=['GET'])
def me():
    if 'user_id' not in session:
        return jsonify({'logged_in': False}), 200
    return jsonify({'logged_in': True, 'user': {
        'id':    session['user_id'],
        'name':  session['user_name'],
        'email': session['user_email']
    }}), 200


# ─── MENU ─────────────────────────────────────────────────────────────────────

@app.route('/menu', methods=['GET'])
def get_menu():
    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT i.*, c.category_name
            FROM items i
            JOIN categories c ON i.category_id = c.category_id
            ORDER BY i.is_bestseller DESC, i.item_name
        """)
        items = cur.fetchall()
        for it in items:
            it['price']  = float(it['price'])
            it['rating'] = float(it['rating']) if it['rating'] else 4.0
        return jsonify({'items': items}), 200
    finally:
        cur.close(); conn.close()


# ─── WISHLIST ─────────────────────────────────────────────────────────────────

@app.route('/wishlist', methods=['GET'])
def get_wishlist():
    if 'user_id' not in session:
        return jsonify({'wishlist': []}), 200
    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT w.item_id, i.item_name, i.price, i.image_file, i.rating, i.is_veg, i.badge
            FROM wishlist w JOIN items i ON w.item_id = i.item_id
            WHERE w.user_id = %s
            ORDER BY w.added_at DESC
        """, (session['user_id'],))
        items = cur.fetchall()
        for it in items:
            it['price']  = float(it['price'])
            it['rating'] = float(it['rating']) if it['rating'] else 4.0
        return jsonify({'wishlist': items}), 200
    finally:
        cur.close(); conn.close()


@app.route('/wishlist/toggle', methods=['POST'])
def toggle_wishlist():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in'}), 401
    item_id = request.get_json().get('item_id')
    conn = get_db(); cur = conn.cursor()
    try:
        cur.execute("SELECT wishlist_id FROM wishlist WHERE user_id=%s AND item_id=%s",
                    (session['user_id'], item_id))
        existing = cur.fetchone()
        if existing:
            cur.execute("DELETE FROM wishlist WHERE user_id=%s AND item_id=%s",
                        (session['user_id'], item_id))
            conn.commit()
            return jsonify({'action': 'removed'}), 200
        else:
            cur.execute("INSERT INTO wishlist (user_id, item_id) VALUES (%s,%s)",
                        (session['user_id'], item_id))
            conn.commit()
            return jsonify({'action': 'added'}), 200
    finally:
        cur.close(); conn.close()


# ─── COUPONS ─────────────────────────────────────────────────────────────────

@app.route('/apply_coupon', methods=['POST'])
def apply_coupon():
    d = request.get_json()
    code      = d.get('code', '').strip().upper()
    subtotal  = float(d.get('subtotal', 0))

    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("SELECT * FROM coupons WHERE code=%s AND is_active=1", (code,))
        c = cur.fetchone()
        if not c:
            return jsonify({'error': 'Invalid or expired coupon code'}), 400
        if subtotal < float(c['min_order']):
            return jsonify({'error': f"Minimum order ₹{c['min_order']:.0f} required for this coupon"}), 400
        discount = min(subtotal * c['discount_pct'] / 100, float(c['max_discount']))
        return jsonify({
            'code':         code,
            'discount_pct': c['discount_pct'],
            'discount':     round(discount, 2),
            'message':      f"{c['discount_pct']}% off applied! You save ₹{discount:.0f}"
        }), 200
    finally:
        cur.close(); conn.close()


# ─── ORDERS ──────────────────────────────────────────────────────────────────
import random, string

def generate_txn_id():
    chars = string.ascii_uppercase + string.digits
    return 'TXN' + ''.join(random.choices(chars, k=10))

@app.route('/create_payment', methods=['POST'])
def create_payment():
    if 'user_id' not in session:
        return jsonify({'error': 'Not logged in'}), 401
    d      = request.get_json()
    amount = d.get('amount', 0)
    method = d.get('method', '')
    if not amount or not method:
        return jsonify({'error': 'Invalid request'}), 400
    txn_id = generate_txn_id()
    return jsonify({'txn_id': txn_id, 'status': 'pending'}), 200
@app.route('/place_order', methods=['POST'])
def place_order():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in to place an order'}), 401

    uid = session['user_id']
    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("SELECT user_id FROM users WHERE user_id=%s", (uid,))
        if not cur.fetchone():
            session.clear()
            return jsonify({'error': 'Session expired. Please log in again.'}), 401
    finally:
        cur.close(); conn.close()

    d           = request.get_json()
    cart        = d.get('cart', [])
    address     = d.get('address', '').strip()
    payment     = d.get('payment_method', '')
    phone       = d.get('phone', '').strip()
    notes       = d.get('notes', '').strip()
    coupon_code = d.get('coupon_code', '').strip().upper()
    discount    = float(d.get('discount_amount', 0))
    txn_id      = d.get('txn_id', '').strip() if d.get('txn_id') else None

    if not cart:
        return jsonify({'error': 'Cart is empty'}), 400
    if not address or len(address) < 10:
        return jsonify({'error': 'Please enter a valid delivery address'}), 400
    if not payment:
        return jsonify({'error': 'Please select a payment method'}), 400
    if payment in ('upi', 'card', 'nb') and not txn_id:
        return jsonify({'error': 'Payment not completed. Please try again.'}), 400

    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        subtotal = 0
        for item in cart:
            cur.execute("SELECT price FROM items WHERE item_id=%s", (item['item_id'],))
            row = cur.fetchone()
            if row:
                subtotal += float(row['price']) * item['quantity']

        delivery_charge = 0 if subtotal >= 300 else 40
        total = max(subtotal + delivery_charge - discount, 0)

        payment_status = 'Pending' if payment == 'cod' else 'Paid'

        cur.execute("""
            INSERT INTO orders
              (user_id, delivery_address, phone, notes, payment_method,
               total_amount, discount_amount, coupon_code, status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,'Confirmed')
        """, (uid, address, phone, notes, payment,
              total, discount, coupon_code or None))
        conn.commit()
        order_id = cur.lastrowid

        for item in cart:
            cur.execute("SELECT price FROM items WHERE item_id=%s", (item['item_id'],))
            row = cur.fetchone()
            if row:
                cur.execute("""
                    INSERT INTO order_items (order_id, item_id, quantity, price)
                    VALUES (%s,%s,%s,%s)
                """, (order_id, item['item_id'], item['quantity'], float(row['price'])))

        cur.execute("""
            INSERT INTO payments (order_id, payment_method, payment_status, amount, txn_id)
            VALUES (%s,%s,%s,%s,%s)
        """, (order_id, payment, payment_status, total, txn_id))
        conn.commit()

        return jsonify({
            'message':  'Order placed!',
            'order_id': f'FR{order_id:08d}',
            'total':    total
        }), 200

    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close(); conn.close()


@app.route('/my_orders', methods=['GET'])
def my_orders():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in'}), 401

    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT o.order_id, o.delivery_address, o.payment_method, o.total_amount,
                   o.discount_amount, o.coupon_code, o.status, o.created_at,
                   GROUP_CONCAT(CONCAT(i.item_name,' x',oi.quantity) SEPARATOR ', ') AS items_summary
            FROM orders o
            JOIN order_items oi ON o.order_id = oi.order_id
            JOIN items i ON oi.item_id = i.item_id
            WHERE o.user_id = %s
            GROUP BY o.order_id
            ORDER BY o.created_at DESC
        """, (session['user_id'],))
        orders = cur.fetchall()
        for o in orders:
            o['total_amount']    = float(o['total_amount'])
            o['discount_amount'] = float(o['discount_amount'] or 0)
            o['created_at']      = str(o['created_at'])
        return jsonify({'orders': orders}), 200
    finally:
        cur.close(); conn.close()
@app.route('/cancel_order', methods=['POST'])
def cancel_order():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in'}), 401

    d        = request.get_json()
    order_id = d.get('order_id', '').strip()

    # Strip the FR prefix to get numeric id
    numeric_id = order_id.replace('FR', '').lstrip('0') or '0'

    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        # Make sure order belongs to this user and is cancellable
        cur.execute("""
            SELECT status, payment_method FROM orders
            WHERE order_id = %s AND user_id = %s
        """, (numeric_id, session['user_id']))
        order = cur.fetchone()

        if not order:
            return jsonify({'error': 'Order not found'}), 404
        if order['status'] in ('Cancelled', 'Delivered', 'Out for Delivery'):
            return jsonify({'error': f"Order cannot be cancelled (status: {order['status']})"}), 400

        # Cancel the order
        cur.execute("""
            UPDATE orders SET status = 'Cancelled' WHERE order_id = %s
        """, (numeric_id,))

        # Refund only if it was already marked Paid (non-COD)
        if order['payment_method'] != 'cod':
            cur.execute("""
                UPDATE payments SET payment_status = 'Refunded'
                WHERE order_id = %s
            """, (numeric_id,))

        conn.commit()
        return jsonify({'message': 'Order cancelled successfully'}), 200

    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close(); conn.close()

# ─── RATINGS ─────────────────────────────────────────────────────────────────

@app.route('/rate_item', methods=['POST'])
def rate_item():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in to rate'}), 401

    d       = request.get_json()
    item_id = d.get('item_id')
    stars   = d.get('stars')

    if not item_id or not stars or not (1 <= int(stars) <= 5):
        return jsonify({'error': 'Invalid rating'}), 400

    conn = get_db(); cur = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO ratings (user_id, item_id, stars) VALUES (%s,%s,%s)
            ON DUPLICATE KEY UPDATE stars=%s
        """, (session['user_id'], item_id, stars, stars))
        cur.execute("""
            UPDATE items SET rating = (
                SELECT ROUND(AVG(stars),1) FROM ratings WHERE item_id=%s
            ) WHERE item_id=%s
        """, (item_id, item_id))
        conn.commit()
        return jsonify({'message': 'Rating saved!'}), 200
    finally:
        cur.close(); conn.close()


# ─── PROFILE ─────────────────────────────────────────────────────────────────

@app.route('/update_profile', methods=['POST'])
def update_profile():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in'}), 401

    d     = request.get_json()
    name  = d.get('name', '').strip()
    phone = d.get('phone', '').strip()

    if not name:
        return jsonify({'error': 'Name is required'}), 400

    conn = get_db(); cur = conn.cursor()
    try:
        cur.execute("UPDATE users SET name=%s, phone=%s WHERE user_id=%s",
                    (name, phone, session['user_id']))
        conn.commit()
        session['user_name'] = name
        return jsonify({'message': 'Profile updated!'}), 200
    finally:
        cur.close(); conn.close()


@app.route('/change_password', methods=['POST'])
def change_password():
    if 'user_id' not in session:
        return jsonify({'error': 'Please log in'}), 401

    d     = request.get_json()
    old_p = d.get('old_password', '')
    new_p = d.get('new_password', '')

    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("SELECT password_hash FROM users WHERE user_id=%s", (session['user_id'],))
        row = cur.fetchone()
        if not row or row['password_hash'] != hash_pass(old_p):
            return jsonify({'error': 'Current password is incorrect'}), 401
        if len(new_p) < 6:
            return jsonify({'error': 'New password must be at least 6 characters'}), 400
        cur.execute("UPDATE users SET password_hash=%s WHERE user_id=%s",
                    (hash_pass(new_p), session['user_id']))
        conn.commit()
        return jsonify({'message': 'Password changed!'}), 200
    finally:
        cur.close(); conn.close()


# ─── SEARCH SUGGESTIONS ──────────────────────────────────────────────────────

@app.route('/search', methods=['GET'])
def search():
    q = request.args.get('q', '').strip()
    if len(q) < 2:
        return jsonify({'items': []}), 200
    conn = get_db(); cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT item_id, item_name, price, image_file, rating, is_veg, badge, category_id
            FROM items
            WHERE item_name LIKE %s OR description LIKE %s
            ORDER BY is_bestseller DESC, rating DESC
            LIMIT 8
        """, (f'%{q}%', f'%{q}%'))
        items = cur.fetchall()
        for it in items:
            it['price']  = float(it['price'])
            it['rating'] = float(it['rating']) if it['rating'] else 4.0
        return jsonify({'items': items}), 200
    finally:
        cur.close(); conn.close()


if __name__ == '__main__':
    app.run(debug=True, port=5000)


