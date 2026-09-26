-- ============================================================
--  FoodRush v3 – Full Database Schema & Seed Data
--  HOW TO RUN:
--    mysql -u root -p < data_sql.sql
--  OR paste in MySQL Workbench → Run (Lightning bolt ⚡)
-- ============================================================

DROP DATABASE IF EXISTS zomato;
CREATE DATABASE zomato CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE zomato;

-- ─── USERS ───────────────────────────────────────────────────
CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(15),
    password_hash VARCHAR(64) NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Demo accounts: demo@food.com / demo123   |   gowtham@example.com / 123456
INSERT INTO users (name, email, phone, password_hash) VALUES
('Demo User',  'demo@food.com',        '9876543210',
 '9a4c4c8f5a0d7cbf6a6e6a81cd9c27c1a49ef76e3e25484d3547c0e24fcee5d3'),
('Gowtham K',  'gowtham@example.com',  '8888888888',
 '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92');


-- ─── CATEGORIES ──────────────────────────────────────────────
CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    emoji         VARCHAR(10)
);

INSERT INTO categories (category_name, emoji) VALUES
('Rice & Biryani',   '🍚'),   -- 1
('Vegetarian',       '🥗'),   -- 2
('Non-Vegetarian',   '🍗'),   -- 3
('Breakfast',        '🌅'),   -- 4
('Noodles',          '🍜'),   -- 5
('Desserts',         '🍮'),   -- 6
('Soups & Starters', '🍲'),   -- 7
('Celebration',      '🎉');   -- 8


-- ─── ITEMS ───────────────────────────────────────────────────
CREATE TABLE items (
    item_id       INT AUTO_INCREMENT PRIMARY KEY,
    item_name     VARCHAR(255) NOT NULL,
    price         DECIMAL(10,2) NOT NULL,
    category_id   INT,
    image_file    VARCHAR(255),
    description   TEXT,
    badge         VARCHAR(30),
    is_bestseller TINYINT(1) DEFAULT 0,
    is_veg        TINYINT(1) DEFAULT 0,
    rating        DECIMAL(3,1) DEFAULT 4.0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

INSERT INTO items (item_name, price, category_id, image_file, description, badge, is_bestseller, is_veg, rating) VALUES
-- RICE & BIRYANI (cat 1)
('Chicken Biryani', 220.00, 1, 'Chicken_Biryani.jpg', 'Fragrant basmati with tender chicken, saffron and whole spices.',       'bestseller', 1, 0, 4.7),
('Mutton Biryani', 280.00, 1, 'Mutton_Biryani.jpg', 'Slow-cooked tender mutton with dum biryani technique.',                  'spicy',      0, 0, 4.6),
('Egg Biryani', 160.00, 1, 'Egg_Biryani.jpg',    'Layered biryani with perfectly spiced boiled eggs.',                     NULL,         0, 0, 4.2),
('Veg Biryani', 150.00, 1, 'Veg_Biryani.jpg',       'Aromatic basmati rice cooked with fresh seasonal vegetables.',           'veg',        0, 1, 4.1),
('Chicken Fried Rice', 180.00, 1, 'Chicken_Fried_Rice.jpg',   'Wok-tossed rice with chicken, eggs and spring onions.',                  NULL,         0, 0, 4.3),
('Veg Fried Rice', 140.00, 1, 'Veg_Fried_Rice.jpg',       'Light and flavourful rice with fresh seasonal vegetables.',              'veg',        0, 1, 4.0),
('Mushroom Rice', 160.00, 1, 'Mushroom_Rice.jpg',       'Earthy mushrooms with basmati rice and aromatic spices.',                'veg',        0, 1, 4.2),
('Egg Fried Rice', 140.00, 1, 'Egg_Fried_Rice.jpg',       'Fluffy wok-tossed rice with scrambled eggs and veggies.',                NULL,         0, 0, 4.0),
('Paneer Fried Rice', 160.00, 1, 'Paneer_Fried_Rice.jpg',         'Wok-tossed rice with crispy paneer and bell peppers.',                   'veg',        0, 1, 4.1),
('Prawn Biryani', 320.00, 1, 'Prawn_Biryani.jpg', 'Juicy prawns layered with saffron-infused basmati rice.',                'spicy',      0, 0, 4.5),

-- VEGETARIAN (cat 2)
('Paneer Butter Masala', 180.00, 2, 'Paneer_Butter_Masala.jpg',  'Creamy tomato-based curry with soft paneer cubes. Best with naan.',        'veg',        1, 1, 4.5),
('Paneer Tikka (6 pcs)', 200.00, 2, 'Paneer_Tikka.jpg',   'Marinated paneer grilled in tandoor with mint chutney.',                   'veg',        0, 1, 4.4),
('Dal Makhani', 140.00, 2, 'Dal_Makhani.webp',   'Slow-cooked black lentils in creamy butter-tomato gravy.',                 'veg',        0, 1, 4.3),
('Mini Meals', 130.00, 2, 'Mini_Meals.jpg',   'Full South Indian meal: rice, sambar, rasam, 3 curries and papad.',        'bestseller', 1, 1, 4.6),
('Chana Masala', 120.00, 2, 'Chole_Bhature.jpg',   'Spicy chickpea curry served with fluffy deep-fried bread.',               'veg',        0, 1, 4.2),
('Mushroom Masala', 160.00, 2, 'Mushroom_Masala.jpg','Button mushrooms in rich onion-tomato gravy with cream.',                  'veg',        0, 1, 4.1),

-- NON-VEGETARIAN (cat 3)
('Butter Chicken', 220.00, 3, 'Butter_Chicken.jpg',  'Silky makhani gravy with juicy chicken tikka. A timeless classic.',  'spicy',      1, 0, 4.8),
('Chicken 65 (6 pcs)', 200.00, 3, 'Chicken_65.jpg', 'Crispy deep-fried chicken in Indo-Chinese spiced batter.',           'spicy',      0, 0, 4.4),
('Chicken Curry', 190.00, 3, 'Chicken_Curry.jpg',  'Home-style chicken curry with thick masala gravy.',                  NULL,         0, 0, 4.2),
('Egg Curry', 140.00, 3, 'Egg_Curry.jpg',     'Boiled eggs in tangy onion-tomato masala gravy.',                   NULL,         0, 0, 4.0),
('Fish Fry (2 pcs)', 250.00, 3, 'Fish_Fry.jpg',    'Crispy batter-fried fish with lemon and green chutney.',             'spicy',      0, 0, 4.3),

-- BREAKFAST (cat 4)
('Masala Dosa', 80.00, 4, 'Masala_Dosa.jpg',  'Crispy rice crepe filled with spiced potato masala and chutney.',             'veg',        1, 1, 4.5),
('Idli Sambar (6 pcs)', 70.00, 4, 'Idli_Sambar.jpg',  'Steamed rice cakes with tangy sambar and three chutneys.',                   'veg',        0, 1, 4.4),
('Onion Uttapam', 90.00, 4, 'Onion_Uttapam.jpg',  'Thick rice pancake topped with onions, tomato and green chilli.',            'veg',        0, 1, 4.2),
('Pongal', 75.00, 4, 'Pongal.jpg',  'Soft rice and lentil dish seasoned with ghee, pepper and curry leaves.',     'veg',        0, 1, 4.3),
('Poori Bhaji (3 pcs)', 90.00, 4, 'Poori_Bhaji.jpg', 'Fluffy deep-fried bread with spiced potato curry.',                          'veg',        0, 1, 4.1),
('Rava Upma', 65.00, 4, 'Rava_Upma.jpg',  'Semolina cooked with vegetables, mustard seeds and curry leaves.',           'veg',        0, 1, 4.0),
('Bread Omelette', 80.00, 4, 'Bread_Omelette.jpg','Fluffy egg omelette with toasted bread, veggies and cheese.',              NULL,         0, 0, 4.2),
('Medu Vada (4 pcs)', 70.00, 4, 'Medu_Vada.jpg',  'Crispy lentil donuts served with sambar and coconut chutney.',               'veg',        0, 1, 4.3),

-- NOODLES (cat 5)
('Chicken Noodles', 160.00, 5, 'Chicken_Noodles.jpg', 'Street-style hakka noodles with shredded chicken and veggies.',      NULL,         0, 0, 4.2),
('Veg Noodles', 130.00, 5, 'Veg_Noodles.jpg',         'Tossed hakka noodles with colourful fresh vegetables.',             'veg',        0, 1, 4.0),
('Egg Noodles', 140.00, 5, 'Egg_Noodles.jpg', 'Hakka noodles tossed with scrambled eggs and spring onions.',       NULL,         0, 0, 4.1),
('Prawn Noodles', 200.00, 5, 'Prawn_Noodles.jpg', 'Stir-fried noodles with juicy prawns in spicy soy sauce.',          'spicy',      0, 0, 4.3),
('Manchow Soup', 100.00, 7, 'Manchow_Soup.jpg',         'Spicy Indo-Chinese soup with veggies and crispy noodles on top.',  'spicy',      0, 0, 4.2),

-- DESSERTS (cat 6)
('Gulab Jamun (4 pcs)', 60.00,  6, 'Gulab_Jamun.jpg',   'Soft milk-solid balls soaked in rose-cardamom sugar syrup.',               'veg',        0, 1, 4.5),
('Ice Cream Sundae', 80.00, 6, 'Ice_Cream_Sundae.jpg', 'Two scoops of vanilla ice cream with chocolate sauce and dry fruits.',    'veg',        0, 1, 4.3),
('Rasgulla (4 pcs)', 70.00, 6, 'Rasgulla.jpg',   'Soft spongy cottage cheese balls in light sugar syrup.',                   'veg',        0, 1, 4.2),
('Kheer', 80.00, 6, 'Kheer.jpg',    'Creamy rice pudding with cardamom, saffron and dry fruits.',               'veg',        0, 1, 4.4),
('Chocolate Brownie', 90.00, 6, 'Chocolate_Brownie.jpg', 'Warm fudgy chocolate brownie served with vanilla ice cream.',             'veg',        0, 1, 4.6),

-- STARTERS (cat 7)
('Veg Manchurian (6 pcs)', 140.00, 7, 'Veg_Manchurian.jpg',         'Fried vegetable balls in spicy Manchurian sauce.',             'veg',        0, 1, 4.2),
('Chicken Lollipop (6 pcs)', 200.00, 7, 'Chicken_Lollipop.jpg', 'Marinated chicken wings deep-fried and tossed in hot sauce.',  'spicy',      0, 0, 4.4),
('Spring Rolls (4 pcs)', 120.00, 7, 'Spring_Rolls.jpg',            'Crispy rolls filled with mixed vegetables and chilli sauce.',  'veg',        0, 1, 4.1),
('Samosa (4 pcs)', 80.00, 7, 'Samosa.jpg',            'Golden crispy pastry filled with spiced potato and peas.',    'veg',        0, 1, 4.3),

-- CELEBRATION CAKES (cat 8)
('Black Forest Cake', 450.00, 8, 'Black_Forest.jpg',       'Classic German cake with layers of chocolate sponge, whipped cream and cherries.',        'bestseller', 1, 1, 4.8),
('Butterscotch Cake', 380.00, 8, 'Butterscotch.jpg',       'Moist sponge layered with rich butterscotch cream and crunchy caramel bits.',             'new',        0, 1, 4.6),
('Red Velvet Cake', 420.00, 8, 'Red_velvet.jpg',           'Velvety red cocoa sponge with smooth cream cheese frosting and a hint of vanilla.',        'new',        0, 1, 4.7),
('Chocolate Truffle Cake', 480.00, 8, 'Chocolate_Truffle.jpg', 'Decadent dark chocolate cake with silky truffle ganache and chocolate shavings.',      'bestseller', 1, 1, 4.9),
('Pineapple Cake', 350.00, 8, 'Pineapple.jpg',             'Light vanilla sponge layered with fresh pineapple cream and juicy pineapple chunks.',      'veg',        0, 1, 4.5),
('Blueberry Cheesecake', 520.00, 8, 'Blueberry.jpg',       'Creamy New York-style cheesecake topped with fresh blueberry compote on a buttery crust.', 'new',        0, 1, 4.8);


-- ─── WISHLIST ─────────────────────────────────────────────────
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    item_id     INT NOT NULL,
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_wish (user_id, item_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);


-- ─── RATINGS ─────────────────────────────────────────────────
CREATE TABLE ratings (
    rating_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    item_id    INT NOT NULL,
    stars      TINYINT NOT NULL CHECK (stars BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_item (user_id, item_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);


-- ─── COUPONS ─────────────────────────────────────────────────
CREATE TABLE coupons (
    coupon_id    INT AUTO_INCREMENT PRIMARY KEY,
    code         VARCHAR(30) NOT NULL UNIQUE,
    discount_pct TINYINT NOT NULL,
    max_discount DECIMAL(10,2) DEFAULT 100.00,
    min_order    DECIMAL(10,2) DEFAULT 0.00,
    is_active    TINYINT(1) DEFAULT 1
);

INSERT INTO coupons (code, discount_pct, max_discount, min_order) VALUES
('RUSH50',   50, 100.00,   0.00),
('SAVE20',   20,  60.00, 200.00),
('FIRSTBITE',30,  80.00, 100.00);


-- ─── ORDERS ──────────────────────────────────────────────────
CREATE TABLE orders (
    order_id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT NOT NULL,
    delivery_address VARCHAR(500) NOT NULL,
    phone            VARCHAR(15),
    notes            TEXT,
    payment_method   VARCHAR(50),
    total_amount     DECIMAL(10,2) DEFAULT 0,
    discount_amount  DECIMAL(10,2) DEFAULT 0,
    coupon_code      VARCHAR(30),
    status           VARCHAR(30) DEFAULT 'Confirmed',
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT,
    item_id       INT,
    quantity      INT NOT NULL,
    price         DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id)  REFERENCES items(item_id)
);

CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'Pending',
    amount         DECIMAL(10,2),
    paid_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Sample orders for demo user
INSERT INTO orders (user_id, delivery_address, phone, payment_method, total_amount, status, created_at) VALUES
(1, '12, Anna Nagar, Chennai - 600040', '9876543210', 'upi',  480.00, 'Delivered',       NOW() - INTERVAL 5 DAY),
(1, '12, Anna Nagar, Chennai - 600040', '9876543210', 'cod',  260.00, 'Delivered',       NOW() - INTERVAL 2 DAY),
(1, '12, Anna Nagar, Chennai - 600040', '9876543210', 'card', 660.00, 'Out for Delivery',NOW() - INTERVAL 1 HOUR);

INSERT INTO order_items (order_id, item_id, quantity, price) VALUES
(1,  1, 2, 220.00), (1, 11, 1, 180.00),
(2, 22, 2,  80.00), (2, 23, 1,  70.00), (2, 24, 1, 90.00),
(3,  1, 1, 220.00), (3, 17, 1, 220.00), (3, 36, 2, 60.00);

INSERT INTO payments (order_id, payment_method, payment_status, amount) VALUES
(1, 'upi',  'Paid', 480.00),
(2, 'cod',  'Paid', 260.00),
(3, 'card', 'Paid', 660.00);

SELECT CONCAT('✅ FoodRush v3 ready! Total dishes: ', COUNT(*)) AS RESULT FROM items;
