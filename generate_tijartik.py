"""
Tijartik E-Commerce Database — Full ETL Data Generation Script
==============================================================
Generates ≥500,000 total rows across all 15 tables with
100% referential integrity and constraint compliance.
"""

import os
import random
import numpy as np
import pandas as pd
from datetime import datetime, timedelta, date
from faker import Faker

fake = Faker("ar_AA")  # Arabic locale for realistic Middle-East names
fake_en = Faker("en_US")

OUTPUT_DIR = "/mnt/user-data/outputs"
os.makedirs(OUTPUT_DIR, exist_ok=True)

random.seed(42)
np.random.seed(42)

START_DATE = datetime(2022, 1, 1)
END_DATE   = datetime(2024, 12, 31)

def rand_date(start=START_DATE, end=END_DATE):
    delta = end - start
    return start + timedelta(seconds=random.randint(0, int(delta.total_seconds())))

def rand_date_only(start=date(2022,1,1), end=date(2024,12,31)):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

# ──────────────────────────────────────────────
# 1. LOCATION  (reference table — generate first)
# ──────────────────────────────────────────────
print("Generating Location …")
cities_regions = [
    ("Cairo", "Cairo"), ("Alexandria", "Alexandria"), ("Giza", "Giza"),
    ("Shubra El Kheima", "Qalyubia"), ("Port Said", "Port Said"),
    ("Suez", "Suez"), ("Luxor", "Luxor"), ("Aswan", "Aswan"),
    ("Asyut", "Asyut"), ("Ismailia", "Ismailia"), ("Faiyum", "Faiyum"),
    ("Zagazig", "Sharqia"), ("Damietta", "Damietta"), ("Mansoura", "Dakahlia"),
    ("Tanta", "Gharbia"), ("Beni Suef", "Beni Suef"), ("Qena", "Qena"),
    ("Sohag", "Sohag"), ("Kafr El Sheikh", "Kafr El Sheikh"), ("Minya", "Minya"),
    ("Hurghada", "Red Sea"), ("Marsa Matruh", "Matrouh"), ("Banha", "Qalyubia"),
    ("Damanhur", "Beheira"), ("Shibin El Kom", "Monufia"),
    ("10th of Ramadan City", "Sharqia"), ("New Cairo", "Cairo"),
    ("Heliopolis", "Cairo"), ("Maadi", "Cairo"), ("Dokki", "Giza"),
    ("Nasr City", "Cairo"), ("Zamalek", "Cairo"), ("Agami", "Alexandria"),
    ("Sidi Gaber", "Alexandria"), ("Smouha", "Alexandria"),
    ("Obour City", "Qalyubia"), ("6th of October City", "Giza"),
    ("Sheikh Zayed", "Giza"), ("Mokattam", "Cairo"), ("Mohandessin", "Giza"),
    ("Helwan", "Cairo"), ("Shoubra", "Cairo"), ("Ain Shams", "Cairo"),
    ("Madinaty", "Cairo"), ("El Gouna", "Red Sea"), ("Dahab", "South Sinai"),
    ("Sharm El Sheikh", "South Sinai"), ("El Arish", "North Sinai"),
    ("Beni Mazar", "Minya"), ("Mallawi", "Minya"),
]
N_LOC = len(cities_regions)
location_df = pd.DataFrame({
    "location_id": range(1, N_LOC + 1),
    "city":        [c for c, r in cities_regions],
    "region":      [r for c, r in cities_regions],
})
print(f"  → {len(location_df):,} rows")

# ──────────────────────────────────────────────
# 2. CATEGORY
# ──────────────────────────────────────────────
print("Generating Category …")
categories = [
    ("Electronics", 8.5), ("Mobile Phones", 7.0), ("Laptops & Computers", 9.0),
    ("Home Appliances", 6.5), ("Fashion - Men", 12.0), ("Fashion - Women", 12.0),
    ("Fashion - Kids", 11.0), ("Shoes", 10.0), ("Accessories", 13.0),
    ("Beauty & Personal Care", 14.0), ("Health & Wellness", 11.5),
    ("Groceries", 5.0), ("Books", 7.5), ("Toys & Games", 10.0),
    ("Sports & Outdoors", 9.5), ("Furniture", 6.0), ("Kitchen & Dining", 8.0),
    ("Automotive", 7.0), ("Garden & Outdoors", 8.5), ("Pet Supplies", 9.0),
    ("Baby Products", 10.5), ("Jewellery", 15.0), ("Watches", 11.0),
    ("Office Supplies", 8.0), ("Industrial & Scientific", 7.5),
]
category_df = pd.DataFrame({
    "category_id":      range(1, len(categories) + 1),
    "name":             [c for c, _ in categories],
    "commission_rate":  [r for _, r in categories],
})
print(f"  → {len(category_df):,} rows")

# ──────────────────────────────────────────────
# 3. SELLER  (1,000 sellers)
# ──────────────────────────────────────────────
print("Generating Seller …")
N_SELLERS = 1_000
seller_types = ["Own Platform", "Third Party"]
seller_df = pd.DataFrame({
    "seller_id":   range(1, N_SELLERS + 1),
    "name":        [fake_en.company() for _ in range(N_SELLERS)],
    "type":        np.random.choice(seller_types, N_SELLERS, p=[0.2, 0.8]),
    "join_date":   [rand_date_only(date(2019,1,1), date(2023,12,31)) for _ in range(N_SELLERS)],
    "location_id": np.random.choice(location_df["location_id"], N_SELLERS),
})
print(f"  → {len(seller_df):,} rows")

# ──────────────────────────────────────────────
# 4. PRODUCT  (50,000 products)
# ──────────────────────────────────────────────
print("Generating Product …")
N_PROD = 50_000
product_df = pd.DataFrame({
    "product_id":     range(1, N_PROD + 1),
    "seller_id":      np.random.choice(seller_df["seller_id"], N_PROD),
    "category_id":    np.random.choice(category_df["category_id"], N_PROD),
    "name":           [fake_en.catch_phrase()[:150] for _ in range(N_PROD)],
    "description":    [fake_en.text(max_nb_chars=200) for _ in range(N_PROD)],
    "price":          np.round(np.random.exponential(scale=250, size=N_PROD).clip(5, 50_000), 2),
    "stock_quantity": np.random.randint(0, 5001, N_PROD),
    "weight":         np.round(np.random.exponential(scale=2, size=N_PROD).clip(0.05, 200), 2),
    "is_fragile":     np.random.choice([True, False], N_PROD, p=[0.15, 0.85]),
})
print(f"  → {len(product_df):,} rows")

# ──────────────────────────────────────────────
# 5. CUSTOMER  (80,000 customers)
# ──────────────────────────────────────────────
print("Generating Customer …")
N_CUST = 80_000
genders = ["Male", "Female", "Prefer not to say"]
emails = list({fake_en.unique.email() for _ in range(N_CUST)})
while len(emails) < N_CUST:
    emails.append(fake_en.unique.email())
emails = emails[:N_CUST]

customer_df = pd.DataFrame({
    "customer_id":       range(1, N_CUST + 1),
    "name":              [fake_en.name() for _ in range(N_CUST)],
    "email":             emails,
    "phone":             [f"+20{random.randint(10,15)}{random.randint(10000000,99999999)}" for _ in range(N_CUST)],
    "dob":               [rand_date_only(date(1960,1,1), date(2005,12,31)) for _ in range(N_CUST)],
    "gender":            np.random.choice(genders, N_CUST, p=[0.48, 0.48, 0.04]),
    "registration_date": [rand_date_only(date(2022,1,1), date(2024,12,31)) for _ in range(N_CUST)],
    "location_id":       np.random.choice(location_df["location_id"], N_CUST),
})
print(f"  → {len(customer_df):,} rows")

# ──────────────────────────────────────────────
# 6. PROMOTIONS  (500 promos)
# ──────────────────────────────────────────────
print("Generating Promotions …")
N_PROMO = 500
disc_types = ["percentage", "fixed"]
platforms = ["Facebook", "Instagram", "TikTok", "Google", "Email", "SMS", "None"]
promo_starts = [rand_date_only(date(2022,1,1), date(2024,6,1)) for _ in range(N_PROMO)]
promo_df = pd.DataFrame({
    "promotion_id":  range(1, N_PROMO + 1),
    "name":          [f"Promo_{i}_{fake_en.word().capitalize()}" for i in range(1, N_PROMO + 1)],
    "discount_type": np.random.choice(disc_types, N_PROMO),
    "start_date":    promo_starts,
    "end_date":      [s + timedelta(days=random.randint(7,90)) for s in promo_starts],
    "budget":        np.round(np.random.uniform(1000, 500_000, N_PROMO), 2),
    "platform":      np.random.choice(platforms, N_PROMO),
})
print(f"  → {len(promo_df):,} rows")

# ──────────────────────────────────────────────
# 7. ORDER  (150,000 orders)
# ──────────────────────────────────────────────
print("Generating Order …")
N_ORDERS = 150_000
order_statuses = ["placed","paid","shipped","delivered","returned","cancelled"]
order_status_prob = [0.05, 0.10, 0.15, 0.55, 0.08, 0.07]

order_dates = [rand_date() for _ in range(N_ORDERS)]

# ~30% of orders have a promo, 70% NULL
promo_ids_nullable = list(promo_df["promotion_id"]) + [None]
promo_weights = [0.3/N_PROMO]*N_PROMO + [0.7]

order_promotion = [random.choices(promo_ids_nullable, weights=promo_weights)[0] for _ in range(N_ORDERS)]

shipping_fees = np.round(np.random.choice([0, 15, 25, 35, 50], N_ORDERS, p=[0.2,0.3,0.3,0.15,0.05]), 2)
discounts = np.round(np.random.exponential(scale=30, size=N_ORDERS).clip(0, 500), 2)
base_totals = np.round(np.random.exponential(scale=400, size=N_ORDERS).clip(50, 50_000), 2)

order_df = pd.DataFrame({
    "order_id":      range(1, N_ORDERS + 1),
    "customer_id":   np.random.choice(customer_df["customer_id"], N_ORDERS),
    "promotion_id":  order_promotion,
    "date":          order_dates,
    "status":        np.random.choice(order_statuses, N_ORDERS, p=order_status_prob),
    "total_amount":  base_totals,
    "discount":      discounts,
    "shipping_fee":  shipping_fees,
})
print(f"  → {len(order_df):,} rows")

# ──────────────────────────────────────────────
# 8. ORDER_ITEM  (400,000 items — largest table)
# ──────────────────────────────────────────────
print("Generating Order_Item …")
# Each order gets 1-5 items; target ~400k
items_per_order = np.random.choice([1,2,3,4,5], N_ORDERS, p=[0.30,0.35,0.20,0.10,0.05])
order_item_rows = []
oi_id = 1
for oid, n_items in zip(order_df["order_id"], items_per_order):
    used_products = set()
    for _ in range(n_items):
        pid = int(np.random.choice(product_df["product_id"]))
        while pid in used_products:
            pid = int(np.random.choice(product_df["product_id"]))
        used_products.add(pid)
        qty = random.randint(1, 10)
        price = float(product_df.loc[product_df["product_id"]==pid, "price"].values[0])
        tax = round(price * qty * 0.14, 2)
        order_item_rows.append((oi_id, oid, pid, qty, round(price,2), tax))
        oi_id += 1

order_item_df = pd.DataFrame(order_item_rows,
    columns=["order_item_id","order_id","product_id","quantity","unit_price","tax_amount"])
print(f"  → {len(order_item_df):,} rows")

# ──────────────────────────────────────────────
# 9. PAYMENT  (one payment per order)
# ──────────────────────────────────────────────
print("Generating Payment …")
pay_methods = ["Card","COD","Wallet","Bank Transfer"]
pay_method_p = [0.40, 0.35, 0.20, 0.05]
pay_statuses = ["pending","paid","failed","refunded"]

# Map order status → payment status
status_map = {
    "placed":    ("pending", 0.9, "paid", 0.1),
    "paid":      ("paid", 1.0,),
    "shipped":   ("paid", 1.0,),
    "delivered": ("paid", 1.0,),
    "returned":  ("refunded", 1.0,),
    "cancelled": ("failed", 0.6, "pending", 0.4),
}
def pick_pay_status(order_status):
    if order_status in ("paid","shipped","delivered"):
        return "paid"
    if order_status == "returned":
        return "refunded"
    if order_status == "cancelled":
        return random.choices(["failed","pending"], weights=[0.6,0.4])[0]
    return random.choices(["pending","paid"], weights=[0.9,0.1])[0]

order_dates_series = pd.Series(order_dates)
payment_df = pd.DataFrame({
    "payment_id":   range(1, N_ORDERS + 1),
    "order_id":     order_df["order_id"].values,
    "method":       np.random.choice(pay_methods, N_ORDERS, p=pay_method_p),
    "status":       [pick_pay_status(s) for s in order_df["status"]],
    "amount":       order_df["total_amount"].values,
    "payment_date": [d + timedelta(hours=random.randint(0,24)) for d in order_dates],
})
print(f"  → {len(payment_df):,} rows")

# ──────────────────────────────────────────────
# 10. SHIPMENT  (one per non-cancelled order)
# ──────────────────────────────────────────────
print("Generating Shipment …")
shippable = order_df[~order_df["status"].isin(["cancelled","placed"])].copy()
N_SHIP = len(shippable)
ship_statuses = ["processing","in_transit","delivered","failed"]

def get_ship_status(order_status):
    if order_status == "delivered": return "delivered"
    if order_status == "returned":  return "delivered"
    if order_status == "shipped":   return "in_transit"
    if order_status == "paid":      return random.choice(["processing","in_transit"])
    return "processing"

shipped_dates = [d.date() + timedelta(days=random.randint(1,3)) for d in shippable["date"]]
delivery_dates = [s + timedelta(days=random.randint(3,10)) for s in shipped_dates]
eta_dates = [s + timedelta(days=random.randint(3,7)) for s in shipped_dates]

shipment_df = pd.DataFrame({
    "shipment_id":      range(1, N_SHIP + 1),
    "order_id":         shippable["order_id"].values,
    "status":           [get_ship_status(s) for s in shippable["status"]],
    "shipped_date":     shipped_dates,
    "delivered_date":   [d if random.random()<0.85 else None for d in delivery_dates],
    "estimated_arrival":eta_dates,
    "location_id":      np.random.choice(location_df["location_id"], N_SHIP),
})
print(f"  → {len(shipment_df):,} rows")

# ──────────────────────────────────────────────
# 11. RETURN  (returns for returned order items)
# ──────────────────────────────────────────────
print("Generating Return …")
returned_order_ids = set(order_df[order_df["status"]=="returned"]["order_id"])
returned_items = order_item_df[order_item_df["order_id"].isin(returned_order_ids)].copy()

return_statuses = ["requested","approved","rejected","refunded"]
return_reasons = [
    "Damaged on arrival","Wrong item delivered","Changed my mind",
    "Product not as described","Defective product","Size/fit issue","Other"
]

return_df = pd.DataFrame({
    "return_id":      range(1, len(returned_items) + 1),
    "order_item_id":  returned_items["order_item_id"].values,
    "status":         np.random.choice(return_statuses, len(returned_items), p=[0.05,0.55,0.10,0.30]),
    "reason":         [random.choice(return_reasons) for _ in range(len(returned_items))],
    "refund_amount":  np.round(
        returned_items["unit_price"].values * returned_items["quantity"].values * np.random.uniform(0.5,1.0, len(returned_items)), 2),
    "date":           [rand_date_only(date(2022,1,1), date(2024,12,31)) for _ in range(len(returned_items))],
})
print(f"  → {len(return_df):,} rows")

# ──────────────────────────────────────────────
# 12. REVIEW  (60,000 reviews)
# ──────────────────────────────────────────────
print("Generating Review …")
N_REV = 60_000
review_df = pd.DataFrame({
    "review_id":   range(1, N_REV + 1),
    "customer_id": np.random.choice(customer_df["customer_id"], N_REV),
    "product_id":  np.random.choice(product_df["product_id"], N_REV),
    "rating":      np.round(np.random.uniform(1.0, 5.0, N_REV), 1).clip(1.0, 5.0),
    "text":        [fake_en.text(max_nb_chars=300) for _ in range(N_REV)],
    "date":        [rand_date_only(date(2022,1,1), date(2024,12,31)) for _ in range(N_REV)],
})
print(f"  → {len(review_df):,} rows")

# ──────────────────────────────────────────────
# 13. INVENTORY_LOG  (100,000 logs)
# ──────────────────────────────────────────────
print("Generating Inventory_Log …")
N_INV = 100_000
tx_types = ["sale","restock","return"]
tx_weights = [0.55, 0.30, 0.15]
quantity_changes = []
for tt in np.random.choice(tx_types, N_INV, p=tx_weights):
    if tt == "sale":
        quantity_changes.append(-random.randint(1, 20))
    elif tt == "restock":
        quantity_changes.append(random.randint(10, 500))
    else:
        quantity_changes.append(random.randint(1, 10))

inventory_log_df = pd.DataFrame({
    "log_id":           range(1, N_INV + 1),
    "product_id":       np.random.choice(product_df["product_id"], N_INV),
    "log_date":         [rand_date() for _ in range(N_INV)],
    "quantity_change":  quantity_changes,
    "transaction_type": np.random.choice(tx_types, N_INV, p=tx_weights),
})
print(f"  → {len(inventory_log_df):,} rows")

# ──────────────────────────────────────────────
# 14. SESSION  (120,000 sessions)
# ──────────────────────────────────────────────
print("Generating Session …")
N_SESS = 120_000
device_types = ["mobile","desktop","tablet"]
device_probs  = [0.60, 0.30, 0.10]
session_starts = [rand_date() for _ in range(N_SESS)]
session_df = pd.DataFrame({
    "session_id":      range(1, N_SESS + 1),
    "customer_id":     np.random.choice(customer_df["customer_id"], N_SESS),
    "device_type":     np.random.choice(device_types, N_SESS, p=device_probs),
    "start_timestamp": session_starts,
    "end_timestamp":   [s + timedelta(minutes=random.randint(1, 120)) for s in session_starts],
})
print(f"  → {len(session_df):,} rows")

# ──────────────────────────────────────────────
# 15. USER_EVENT  (500,000 events — biggest table)
# ──────────────────────────────────────────────
print("Generating User_Event …")
N_EVENTS = 500_000
event_types = ["page_view","click","add_to_cart","purchase","search","wishlist","remove_from_cart"]
event_probs  = [0.35, 0.25, 0.15, 0.08, 0.10, 0.04, 0.03]
page_types   = ["home_page","search_page","category_page","product_page",
                "checkout_page","payment_page","order_confirmation_page","account_page"]

# Products are nullable (70% have product_id)
prod_ids_with_none = list(product_df["product_id"]) + [None]
prod_weights = [0.70/N_PROD]*N_PROD + [0.30]

user_event_df = pd.DataFrame({
    "event_id":        range(1, N_EVENTS + 1),
    "session_id":      np.random.choice(session_df["session_id"], N_EVENTS),
    "product_id":      random.choices(prod_ids_with_none, weights=prod_weights, k=N_EVENTS),
    "event_type":      np.random.choice(event_types, N_EVENTS, p=event_probs),
    "page_type":       np.random.choice(page_types,  N_EVENTS),
    "event_timestamp": [rand_date() for _ in range(N_EVENTS)],
})
print(f"  → {len(user_event_df):,} rows")

# ──────────────────────────────────────────────
# VALIDATION
# ──────────────────────────────────────────────
print("\n" + "="*60)
print("RUNNING VALIDATION CHECKS …")
print("="*60)

tables = {
    "Location":      (location_df,     "location_id",  []),
    "Category":      (category_df,     "category_id",  []),
    "Seller":        (seller_df,        "seller_id",    [("location_id", location_df, "location_id")]),
    "Product":       (product_df,       "product_id",   [("seller_id",   seller_df,   "seller_id"),
                                                          ("category_id", category_df, "category_id")]),
    "Customer":      (customer_df,      "customer_id",  [("location_id", location_df, "location_id")]),
    "Promotions":    (promo_df,         "promotion_id", []),
    "Order":         (order_df,         "order_id",     [("customer_id",  customer_df, "customer_id")]),
    "Order_Item":    (order_item_df,    "order_item_id",[("order_id",    order_df,    "order_id"),
                                                          ("product_id",  product_df,  "product_id")]),
    "Payment":       (payment_df,       "payment_id",   [("order_id",    order_df,    "order_id")]),
    "Shipment":      (shipment_df,      "shipment_id",  [("order_id",    order_df,    "order_id"),
                                                          ("location_id", location_df, "location_id")]),
    "Return":        (return_df,        "return_id",    [("order_item_id",order_item_df,"order_item_id")]),
    "Review":        (review_df,        "review_id",    [("customer_id", customer_df, "customer_id"),
                                                          ("product_id",  product_df,  "product_id")]),
    "Inventory_Log": (inventory_log_df, "log_id",       [("product_id",  product_df,  "product_id")]),
    "Session":       (session_df,       "session_id",   [("customer_id", customer_df, "customer_id")]),
    "User_Event":    (user_event_df,    "event_id",     [("session_id",  session_df,  "session_id")]),
}

validation_report = []
all_pass = True

for tname, (df, pk, fks) in tables.items():
    pk_ok  = df[pk].nunique() == len(df)
    fk_ok  = True
    for fk_col, ref_df, ref_pk in fks:
        non_null = df[fk_col].dropna()
        valid = non_null.isin(ref_df[ref_pk])
        if not valid.all():
            fk_ok = False
            all_pass = False
    status = "✔ PASS" if (pk_ok and fk_ok) else "✘ FAIL"
    validation_report.append({
        "Table": tname,
        "Rows": len(df),
        "PK Unique": "✔" if pk_ok else "✘",
        "FK Valid":  "✔" if fk_ok else "✘",
        "Status": status,
    })

val_df = pd.DataFrame(validation_report)
print(val_df.to_string(index=False))

total_rows = sum(v["Rows"] for v in validation_report)
print(f"\nTotal rows generated : {total_rows:,}")
print(f"All validations pass : {'✔ YES' if all_pass else '✘ NO'}")

# ──────────────────────────────────────────────
# EXPORT TO CSV
# ──────────────────────────────────────────────
print("\nExporting CSV files …")
exports = {
    "locations.csv":      location_df,
    "categories.csv":     category_df,
    "sellers.csv":        seller_df,
    "products.csv":       product_df,
    "customers.csv":      customer_df,
    "promotions.csv":     promo_df,
    "orders.csv":         order_df,
    "order_items.csv":    order_item_df,
    "payments.csv":       payment_df,
    "shipments.csv":      shipment_df,
    "returns.csv":        return_df,
    "reviews.csv":        review_df,
    "inventory_logs.csv": inventory_log_df,
    "sessions.csv":       session_df,
    "user_events.csv":    user_event_df,
}

for fname, df in exports.items():
    path = os.path.join(OUTPUT_DIR, fname)
    df.to_csv(path, index=False)
    print(f"  ✔  {fname:30s}  ({len(df):>10,} rows)")

print("\nAll files written to:", OUTPUT_DIR)
print("Done ✔")
