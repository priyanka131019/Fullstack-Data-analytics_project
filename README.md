# Fullstack-Data-analytics_project
Food Rush is a full-stack food ordering application built with HTML, CSS, JavaScript, Python Flask, and MySQL. It integrates Power BI for data analytics and interactive dashboards, enabling analysis of orders, revenue, sales trends, and food item performance through database-driven visualizations.

==================================================
  FOOD ORDERING APP — SETUP & RUN GUIDE
==================================================

PROJECT STRUCTURE
-----------------
foodordering/
├── app.py               ← Flask backend (all routes + API)
├── database.sql         ← MySQL schema + seed data + all queries
├── requirements.txt     ← Python packages
├── README.txt           ← This file
└── templates/
    ├── index.html       ← Landing page
    ├── auth.html        ← Login / Register
    ← menu.html          ← Browse menu + cart
    ├── checkout.html    ← Place order
    ├── orders.html      ← Order history
    ├── tracking.html    ← Live delivery tracking
    └── admin.html       ← Admin dashboard


STEP 1 — Install dependencies
-------------------------------
Open terminal in VS Code and run:

    pip install flask flask-mysqldb werkzeug


STEP 2 — Set up MySQL database
--------------------------------
Option A (MySQL Workbench):
  1. Open MySQL Workbench
  2. File → Open SQL Script → select database.sql
  3. Press Ctrl+Shift+Enter (Execute All)

Option B (Terminal):
    mysql -u root -p < database.sql


STEP 3 — Configure MySQL in app.py
-------------------------------------
Open app.py and edit lines 22-25:

    app.config['MYSQL_HOST']     = 'localhost'
    app.config['MYSQL_USER']     = 'root'
    app.config['MYSQL_PASSWORD'] = 'YOUR_PASSWORD_HERE'
    app.config['MYSQL_DB']       = 'food_ordering_db'


STEP 4 — Run the app
----------------------
    python app.py

Open browser: http://localhost:5000


MODULES & ROUTES
-----------------
┌──────────────────┬─────────────────────────────────────────┐
│ Module           │ URL / Route                             │
├──────────────────┼─────────────────────────────────────────┤
│ Landing Page     │ /                                       │
│ Login            │ /login                                  │
│ Register         │ /register                               │
│ Menu             │ /menu                                   │
│ Cart (API)       │ /api/cart                               │
│ Checkout         │ /checkout                               │
│ Place Order      │ /api/order/place  (POST)                │
│ Order History    │ /orders                                 │
│ Delivery Track   │ /track/<order_id>                       │
│ Admin Dashboard  │ /admin                                  │
└──────────────────┴─────────────────────────────────────────┘

ADMIN LOGIN
-----------
Email:    admin@foodapp.com
Password: (set via MySQL — update the hashed password)

To generate hash, run in Python:
    from werkzeug.security import generate_password_hash
    print(generate_password_hash('Admin@123'))

Then in MySQL:
    UPDATE users SET password='<paste_hash>' WHERE email='admin@foodapp.com';


COMMON ERRORS & FIXES
-----------------------
❌ ModuleNotFoundError: No module named 'flask_mysqldb'
   → Run: pip install flask-mysqldb

❌ Access denied for user 'root'@'localhost'
   → Wrong password in app.py — fix MYSQL_PASSWORD

❌ Unknown database 'food_ordering_db'
   → Run database.sql first in MySQL

❌ Table 'users' doesn't exist
   → Run database.sql again completely
==================================================
