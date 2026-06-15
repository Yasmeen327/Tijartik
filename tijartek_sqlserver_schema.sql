-- ============================================================================
-- TIJARTEK E-COMMERCE DATABASE SCHEMA - SQL SERVER VERSION
-- Complete Physical Schema for SQL Server 2019+
-- ============================================================================

-- Create database
USE master;
GO

-- Drop if exists (use with caution)
-- IF DB_ID('tijartek') IS NOT NULL
-- BEGIN
--     ALTER DATABASE tijartek SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--     DROP DATABASE tijartek;
-- END
-- GO

-- CREATE DATABASE tijartek;
-- GO

-- Use the database
USE tijartek;
GO

-- ============================================================================
-- 1. LOCATION TABLE
-- ============================================================================
CREATE TABLE Location (
    location_id INT PRIMARY KEY IDENTITY(1,1),
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE()
);

CREATE NONCLUSTERED INDEX idx_location_city ON Location(city);
CREATE NONCLUSTERED INDEX idx_location_region ON Location(region);

-- ============================================================================
-- 2. CATEGORY TABLE
-- ============================================================================
CREATE TABLE Category (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL UNIQUE,
    commission_rate DECIMAL(5, 2) DEFAULT 0 CHECK (commission_rate >= 0 AND commission_rate <= 100),
    created_at DATETIME2 DEFAULT GETDATE()
);

CREATE NONCLUSTERED INDEX idx_category_name ON Category(name);

-- ============================================================================
-- 3. SELLER TABLE
-- ============================================================================
CREATE TABLE Seller (
    seller_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) CHECK (type IN ('Own Platform', 'Third Party')),
    join_date DATE NOT NULL,
    location_id INT NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (location_id) REFERENCES Location(location_id) ON DELETE NO ACTION
);

CREATE NONCLUSTERED INDEX idx_seller_location ON Seller(location_id);
CREATE NONCLUSTERED INDEX idx_seller_type ON Seller(type);
CREATE NONCLUSTERED INDEX idx_seller_join_date ON Seller(join_date);

-- ============================================================================
-- 4. PRODUCT TABLE
-- ============================================================================
CREATE TABLE Product (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    weight DECIMAL(8, 2),
    is_fragile BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE NO ACTION
);

CREATE NONCLUSTERED INDEX idx_product_seller ON Product(seller_id);
CREATE NONCLUSTERED INDEX idx_product_category ON Product(category_id);
CREATE NONCLUSTERED INDEX idx_product_name ON Product(name);
CREATE NONCLUSTERED INDEX idx_product_stock ON Product(stock_quantity);

-- ============================================================================
-- 5. CUSTOMER TABLE
-- ============================================================================
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    dob DATE,
    gender VARCHAR(20) CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer not to say')),
    registration_date DATE NOT NULL,
    location_id INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (location_id) REFERENCES Location(location_id) ON DELETE SET NULL
);

CREATE NONCLUSTERED INDEX idx_customer_email ON Customer(email);
CREATE NONCLUSTERED INDEX idx_customer_registration_date ON Customer(registration_date);
CREATE NONCLUSTERED INDEX idx_customer_location ON Customer(location_id);

-- ============================================================================
-- 6. SESSION TABLE
-- ============================================================================
CREATE TABLE Session (
    session_id BIGINT PRIMARY KEY IDENTITY(1,1),
    customer_id INT,
    device_type VARCHAR(50) NOT NULL CHECK (device_type IN ('mobile', 'desktop', 'tablet')),
    start_timestamp DATETIME2 NOT NULL,
    end_timestamp DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL
);

CREATE NONCLUSTERED INDEX idx_session_customer ON Session(customer_id);
CREATE NONCLUSTERED INDEX idx_session_start ON Session(start_timestamp);
CREATE NONCLUSTERED INDEX idx_session_device ON Session(device_type);

-- ============================================================================
-- 7. USER_EVENT TABLE
-- ============================================================================
CREATE TABLE User_Event (
    event_id BIGINT PRIMARY KEY IDENTITY(1,1),
    session_id BIGINT NOT NULL,
    product_id INT,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN (
        'page_view', 'click', 'add_to_cart', 'purchase', 'search', 'view_product',
        'remove_from_cart', 'checkout_start', 'review_submit', 'wishlist_add'
    )),
    page_type VARCHAR(50) CHECK (page_type IN (
        'home_page', 'search_page', 'category_page', 'product_page', 'checkout_page',
        'payment_page', 'order_confirmation_page', 'account_page'
    )),
    event_timestamp DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (session_id) REFERENCES Session(session_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE SET NULL
);

CREATE NONCLUSTERED INDEX idx_event_session ON User_Event(session_id);
CREATE NONCLUSTERED INDEX idx_event_product ON User_Event(product_id);
CREATE NONCLUSTERED INDEX idx_event_type ON User_Event(event_type);
CREATE NONCLUSTERED INDEX idx_event_timestamp ON User_Event(event_timestamp);

-- ============================================================================
-- 8. PROMOTIONS TABLE
-- ============================================================================
CREATE TABLE Promotions (
    promotion_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    discount_type VARCHAR(50) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(12, 2),
    platform VARCHAR(50),
    created_at DATETIME2 DEFAULT GETDATE(),
    CHECK (end_date >= start_date)
);

CREATE NONCLUSTERED INDEX idx_promotion_start_date ON Promotions(start_date);
CREATE NONCLUSTERED INDEX idx_promotion_end_date ON Promotions(end_date);

-- ============================================================================
-- 9. ORDER TABLE
-- ============================================================================
CREATE TABLE [Order] (
    order_id BIGINT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    promotion_id INT,
    date DATETIME2 NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'placed' CHECK (status IN (
        'placed', 'paid', 'shipped', 'delivered', 'returned', 'cancelled'
    )),
    total_amount DECIMAL(12, 2) NOT NULL CHECK (total_amount >= 0),
    discount DECIMAL(10, 2) DEFAULT 0 CHECK (discount >= 0),
    shipping_fee DECIMAL(10, 2) DEFAULT 0 CHECK (shipping_fee >= 0),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE NO ACTION,
    FOREIGN KEY (promotion_id) REFERENCES Promotions(promotion_id) ON DELETE SET NULL
);

CREATE NONCLUSTERED INDEX idx_order_customer ON [Order](customer_id);
CREATE NONCLUSTERED INDEX idx_order_date ON [Order](date);
CREATE NONCLUSTERED INDEX idx_order_status ON [Order](status);
CREATE NONCLUSTERED INDEX idx_order_promotion ON [Order](promotion_id);

-- ============================================================================
-- 10. ORDER_ITEM TABLE
-- ============================================================================
CREATE TABLE Order_Item (
    order_item_id BIGINT PRIMARY KEY IDENTITY(1,1),
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    tax_amount DECIMAL(10, 2) DEFAULT 0 CHECK (tax_amount >= 0),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE NO ACTION
);

CREATE NONCLUSTERED INDEX idx_order_item_order ON Order_Item(order_id);
CREATE NONCLUSTERED INDEX idx_order_item_product ON Order_Item(product_id);

-- ============================================================================
-- 11. PAYMENT TABLE
-- ============================================================================
CREATE TABLE Payment (
    payment_id BIGINT PRIMARY KEY IDENTITY(1,1),
    order_id BIGINT NOT NULL,
    method VARCHAR(50) NOT NULL CHECK (method IN ('Card', 'COD', 'Wallet', 'Bank Transfer')),
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN (
        'pending', 'paid', 'failed', 'refunded'
    )),
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    payment_date DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE NO ACTION
);

CREATE NONCLUSTERED INDEX idx_payment_order ON Payment(order_id);
CREATE NONCLUSTERED INDEX idx_payment_status ON Payment(status);
CREATE NONCLUSTERED INDEX idx_payment_date ON Payment(payment_date);
CREATE NONCLUSTERED INDEX idx_payment_method ON Payment(method);

-- ============================================================================
-- 12. SHIPMENT TABLE
-- ============================================================================
CREATE TABLE Shipment (
    shipment_id BIGINT PRIMARY KEY IDENTITY(1,1),
    order_id BIGINT NOT NULL,
    location_id INT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'processing' CHECK (status IN (
        'processing', 'in_transit', 'delivered', 'failed'
    )),
    shipped_date DATE,
    delivered_date DATE,
    estimated_arrival DATE,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES Location(location_id) ON DELETE NO ACTION
);

CREATE NONCLUSTERED INDEX idx_shipment_order ON Shipment(order_id);
CREATE NONCLUSTERED INDEX idx_shipment_status ON Shipment(status);
CREATE NONCLUSTERED INDEX idx_shipment_location ON Shipment(location_id);
CREATE NONCLUSTERED INDEX idx_shipment_date ON Shipment(shipped_date);

-- ============================================================================
-- 13. RETURN TABLE
-- ============================================================================
CREATE TABLE Return (
    return_id BIGINT PRIMARY KEY IDENTITY(1,1),
    order_item_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'requested' CHECK (status IN (
        'requested', 'approved', 'rejected', 'refunded'
    )),
    reason NVARCHAR(MAX),
    refund_amount DECIMAL(10, 2),
    date DATE NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (order_item_id) REFERENCES Order_Item(order_item_id) ON DELETE CASCADE
);

CREATE NONCLUSTERED INDEX idx_return_order_item ON Return(order_item_id);
CREATE NONCLUSTERED INDEX idx_return_status ON Return(status);
CREATE NONCLUSTERED INDEX idx_return_date ON Return(date);

-- ============================================================================
-- 14. REVIEW TABLE
-- ============================================================================
CREATE TABLE Review (
    review_id BIGINT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text NVARCHAR(MAX),
    date DATE NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

CREATE NONCLUSTERED INDEX idx_review_customer ON Review(customer_id);
CREATE NONCLUSTERED INDEX idx_review_product ON Review(product_id);
CREATE NONCLUSTERED INDEX idx_review_rating ON Review(rating);
CREATE NONCLUSTERED INDEX idx_review_date ON Review(date);

-- ============================================================================
-- 15. INVENTORY_LOG TABLE
-- ============================================================================
CREATE TABLE Inventory_Log (
    log_id BIGINT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    log_date DATETIME2 NOT NULL,
    quantity_change INT NOT NULL,
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN (
        'sale', 'restock', 'return', 'adjustment', 'damage'
    )),
    notes NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);

CREATE NONCLUSTERED INDEX idx_inventory_log_product ON Inventory_Log(product_id);
CREATE NONCLUSTERED INDEX idx_inventory_log_date ON Inventory_Log(log_date);
CREATE NONCLUSTERED INDEX idx_inventory_log_type ON Inventory_Log(transaction_type);

-- ============================================================================
-- TRIGGERS FOR AUTO-UPDATING TIMESTAMPS
-- ============================================================================

CREATE TRIGGER tr_product_updated
ON Product
AFTER UPDATE
AS
BEGIN
    UPDATE Product SET updated_at = GETDATE()
    WHERE product_id IN (SELECT product_id FROM inserted);
END;
GO

CREATE TRIGGER tr_order_updated
ON [Order]
AFTER UPDATE
AS
BEGIN
    UPDATE [Order] SET updated_at = GETDATE()
    WHERE order_id IN (SELECT order_id FROM inserted);
END;
GO

CREATE TRIGGER tr_payment_updated
ON Payment
AFTER UPDATE
AS
BEGIN
    UPDATE Payment SET updated_at = GETDATE()
    WHERE payment_id IN (SELECT payment_id FROM inserted);
END;
GO

CREATE TRIGGER tr_shipment_updated
ON Shipment
AFTER UPDATE
AS
BEGIN
    UPDATE Shipment SET updated_at = GETDATE()
    WHERE shipment_id IN (SELECT shipment_id FROM inserted);
END;
GO

CREATE TRIGGER tr_return_updated
ON Return
AFTER UPDATE
AS
BEGIN
    UPDATE Return SET updated_at = GETDATE()
    WHERE return_id IN (SELECT return_id FROM inserted);
END;
GO

-- ============================================================================
-- STATISTICS & OPTIMIZATION
-- ============================================================================

-- Update statistics (run after data load)
-- EXEC sp_updatestats;

-- ============================================================================
-- USEFUL VIEWS FOR ANALYSIS
-- ============================================================================

-- Customer Purchase Summary
CREATE VIEW vw_customer_purchases AS
SELECT 
    c.customer_id,
    c.name,
    c.email,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.date) as last_purchase_date,
    l.city,
    l.region
FROM Customer c
LEFT JOIN [Order] o ON c.customer_id = o.customer_id
LEFT JOIN Location l ON c.location_id = l.location_id
GROUP BY c.customer_id, c.name, c.email, l.city, l.region;
GO

-- Product Performance
CREATE VIEW vw_product_performance AS
SELECT 
    p.product_id,
    p.name,
    s.name as seller_name,
    cat.name as category,
    p.price,
    p.stock_quantity,
    COUNT(DISTINCT oi.order_item_id) as units_sold,
    SUM(oi.quantity) as total_quantity,
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as review_count,
    COALESCE(SUM(ret.refund_amount), 0) as total_refunded
FROM Product p
LEFT JOIN Seller s ON p.seller_id = s.seller_id
LEFT JOIN Category cat ON p.category_id = cat.category_id
LEFT JOIN Order_Item oi ON p.product_id = oi.product_id
LEFT JOIN Review r ON p.product_id = r.product_id
LEFT JOIN Return ret ON oi.order_item_id = ret.order_item_id
GROUP BY p.product_id, p.name, s.name, cat.name, p.price, p.stock_quantity;
GO

-- Order Status Dashboard
CREATE VIEW vw_order_status_summary AS
SELECT 
    o.status,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    MIN(o.date) as earliest_order,
    MAX(o.date) as latest_order
FROM [Order] o
GROUP BY o.status;
GO

-- Payment Analytics
CREATE VIEW vw_payment_analytics AS
SELECT 
    p.method,
    p.status,
    COUNT(p.payment_id) as payment_count,
    SUM(p.amount) as total_amount,
    AVG(p.amount) as avg_amount
FROM Payment p
GROUP BY p.method, p.status;
GO

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
