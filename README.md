# Fullstack-Data-analytics_project
Food Rush is a full-stack food ordering application built with HTML, CSS, JavaScript, Python Flask, and MySQL. It integrates Power BI for data analytics and interactive dashboards, enabling analysis of orders, revenue, sales trends, and food item performance through database-driven visualizations.

# 🔥 FoodRush v3 – Setup Guide

## ✅ பண்ண வேண்டியது (Step by Step)

### STEP 1: பழைய Database Delete பண்ணு + புதுதா Create பண்ணு

MySQL Workbench திற்று → File → Open SQL Script → `data_sql.sql` தேர்ந்தெடு

```
⚡ Lightning bolt button அழுத்து (Run All)
```

கடைசியில் இந்த message வரணும்:
```
✅ FoodRush v3 ready! Total dishes: 45
```

---

### STEP 2: MySQL Password மாத்து

`app.py` file திற்று → line 14:
```python
'password': 'ishu214',   # 👈 உன் MySQL password வை இங்க மாத்து
```

---

### STEP 3: Flask + MySQL Library Install

```bash
pip install flask mysql-connector-python
```

---

### STEP 4: App Run பண்ணு

```bash
cd foodrush_v3
python app.py
```

Browser ல திற்று: **http://127.0.0.1:5000**

---

## 🆕 புதுசா Add ஆன Features (v3)

| Feature | Description |
|---------|-------------|
| ❤️ **Wishlist** | Dish card ல heart button — save பண்ண, remove பண்ண |
| 🎟️ **Coupon Codes** | Cart ல coupon box — RUSH50, SAVE20, FIRSTBITE |
| ⭐ **Star Rating** | Dish card ல click பண்ணி rate பண்ணலாம் |
| 💚 **Discount in Cart** | Coupon discount, delivery charge live update |
| 🎟️ **Banner Coupons** | Offer banner click பண்ணா auto apply |
| 📦 **Orders shows discount** | "Saved ₹XX" order history ல காட்டும் |
| 🔐 **Better Auth Errors** | Clear error messages for login/signup |

---

## 🎟️ Coupon Codes (Test பண்ண)

| Code | Discount | Min Order |
|------|----------|-----------|
| RUSH50 | 50% off (max ₹100) | No minimum |
| SAVE20 | 20% off (max ₹60) | ₹200+ |
| FIRSTBITE | 30% off (max ₹80) | ₹100+ |

---

## 📁 Folder Structure

```
foodrush_v3/
├── app.py              ← Flask backend
├── data_sql.sql        ← Fresh database (Run this first!)
├── templates/
│   └── index.html      ← Complete frontend
└── static/
    ├── butter chicken.jpg
    ├── biriyani_img1.webp
    ├── paneer.jpg
    ├── dosa.jpg
    ├── idli.jpg
    ├── meals.jpg
    ├── mushroom.jpg
    ├── veg rice.jpg
    ├── chicken rice.jpg
    ├── chicken noodels.jpg
    └── Egg biryani.jpg
```

---

## ❌ Previous Errors — Fixed!

| Error | Cause | Fix |
|-------|-------|-----|
| Error 1175 Safe Update Mode | UPDATE without WHERE key | `data_sql.sql` fresh create — no UPDATE needed |
| Duplicate column `is_bestseller` | Ran ALTER twice | Fresh DROP + CREATE — no ALTER at all |
| `null` descriptions showing | Old data had nulls | New seed data has all descriptions |
| Only 3 dishes | Old items table wrong | 45 dishes now, all categories |

---

## 🔑 Demo Login

- Email: `demo@food.com` | Password: `demo123`
- Email: `gowtham@example.com` | Password: `123456`
