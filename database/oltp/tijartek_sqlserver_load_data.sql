-- ============================================================================
-- TIJARTEK DATA LOADING SCRIPT - SQL SERVER
-- Bulk loading all CSV files in correct dependency order
-- ============================================================================

USE tijartek;
GO

-- Enable bulk insert for faster loading
SET NOCOUNT ON;
GO

-- ============================================================================
-- HELPER PROCEDURE: Safe data loading with error handling
-- ============================================================================

CREATE OR ALTER PROCEDURE sp_BulkLoadCSV
    @TableName NVARCHAR(128),
    @CSVPath NVARCHAR(MAX),
    @Format VARCHAR(20) = 'CSV'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ErrorMsg NVARCHAR(MAX);
    
    BEGIN TRY
        SET @SQL = 'BULK INSERT ' + @TableName + ' FROM ''' + @CSVPath + 
                   ''' WITH (
                       FORMAT = ''' + @Format + ''',
                       FIRSTROW = 2,
                       FIELDTERMINATOR = '','',
                       ROWTERMINATOR = ''\n'',
                       TABLOCK,
                       CODEPAGE = 65001
                   );';
        
        PRINT 'Loading: ' + @TableName + ' from ' + @CSVPath;
        EXEC sp_executesql @SQL;
        
        DECLARE @RowCount INT = @@ROWCOUNT;
        PRINT 'SUCCESS: ' + @TableName + ' - ' + CAST(@RowCount AS VARCHAR(20)) + ' rows loaded';
        
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = 'ERROR in ' + @TableName + ': ' + ERROR_MESSAGE();
        PRINT @ErrorMsg;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- DISABLE CONSTRAINTS TEMPORARILY FOR LOADING
-- ============================================================================

-- Disable foreign key constraints
ALTER TABLE dbo.Seller NOCHECK CONSTRAINT FK__Seller__location__1FCDBCEB;
ALTER TABLE dbo.Customer NOCHECK CONSTRAINT FK__Customer__locatio__29572725;
ALTER TABLE dbo.Product NOCHECK CONSTRAINT FK__Product__seller_i__33D4B598;
ALTER TABLE dbo.Product NOCHECK CONSTRAINT FK__Product__category__34C8D9D1;
ALTER TABLE dbo.Session NOCHECK CONSTRAINT FK__Session__customer__3B75D760;
ALTER TABLE dbo.User_Event NOCHECK CONSTRAINT FK__User_Event__sessi__412EB0B6;
ALTER TABLE dbo.User_Event NOCHECK CONSTRAINT FK__User_Event__produ__4222D4EF;
ALTER TABLE dbo.[Order] NOCHECK CONSTRAINT FK__Order__customer_i__44FF419A;
ALTER TABLE dbo.[Order] NOCHECK CONSTRAINT FK__Order__promotion__45F365D3;
ALTER TABLE dbo.Order_Item NOCHECK CONSTRAINT FK__Order_Item__order__49C3F6B7;
ALTER TABLE dbo.Order_Item NOCHECK CONSTRAINT FK__Order_Item__produ__4AB81AF0;
ALTER TABLE dbo.Payment NOCHECK CONSTRAINT FK__Payment__order_id__5070F446;
ALTER TABLE dbo.Shipment NOCHECK CONSTRAINT FK__Shipment__order_i__534D60F1;
ALTER TABLE dbo.Shipment NOCHECK CONSTRAINT FK__Shipment__locatio__5441852A;
ALTER TABLE dbo.Return NOCHECK CONSTRAINT FK__Return__order_ite__571DF1D5;
ALTER TABLE dbo.Review NOCHECK CONSTRAINT FK__Review__customer___5812160E;
ALTER TABLE dbo.Review NOCHECK CONSTRAINT FK__Review__product_i__59063A47;
ALTER TABLE dbo.Inventory_Log NOCHECK CONSTRAINT FK__Inventory__produ__5EBF139D;

GO

-- ============================================================================
-- LOADING DATA IN CORRECT ORDER (respecting FK dependencies)
-- ============================================================================

PRINT '========================================';
PRINT 'STARTING DATA LOAD - ' + CONVERT(VARCHAR(20), GETDATE(), 120);
PRINT '========================================';
GO

-- 1. LOCATION (no dependencies)
PRINT '';
PRINT '1. Loading LOCATION...';
BULK INSERT Location
FROM 'C:\Tijartek_Data\locations.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 2. CATEGORY (no dependencies)
PRINT '';
PRINT '2. Loading CATEGORY...';
BULK INSERT Category
FROM 'C:\Tijartek_Data\categories.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 3. SELLER (depends on Location)
PRINT '';
PRINT '3. Loading SELLER...';
BULK INSERT Seller
FROM 'C:\Tijartek_Data\sellers__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 4. CUSTOMER (depends on Location)
PRINT '';
PRINT '4. Loading CUSTOMER...';
BULK INSERT Customer
FROM 'C:\Tijartek_Data\customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 5. PRODUCT (depends on Seller, Category)
PRINT '';
PRINT '5. Loading PRODUCT...';
BULK INSERT Product
FROM 'C:\Tijartek_Data\products__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 6. PROMOTIONS (no dependencies)
PRINT '';
PRINT '6. Loading PROMOTIONS...';
BULK INSERT Promotions
FROM 'C:\Tijartek_Data\promotions__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 7. SESSION (depends on Customer)
PRINT '';
PRINT '7. Loading SESSION...';
BULK INSERT Session
FROM 'C:\Tijartek_Data\sessions__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 8. USER_EVENT (depends on Session, Product)
PRINT '';
PRINT '8. Loading USER_EVENT...';
BULK INSERT User_Event
FROM 'C:\Tijartek_Data\user_events__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 9. ORDER (depends on Customer, Promotions)
PRINT '';
PRINT '9. Loading ORDER...';
BULK INSERT [Order]
FROM 'C:\Tijartek_Data\orders__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 10. ORDER_ITEM (depends on Order, Product)
PRINT '';
PRINT '10. Loading ORDER_ITEM...';
BULK INSERT Order_Item
FROM 'C:\Tijartek_Data\order_items__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 11. PAYMENT (depends on Order)
PRINT '';
PRINT '11. Loading PAYMENT...';
BULK INSERT Payment
FROM 'C:\Tijartek_Data\payments__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 12. SHIPMENT (depends on Order, Location)
PRINT '';
PRINT '12. Loading SHIPMENT...';
BULK INSERT Shipment
FROM 'C:\Tijartek_Data\shipments__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 13. RETURN (depends on Order_Item)
PRINT '';
PRINT '13. Loading RETURN...';
BULK INSERT Return
FROM 'C:\Tijartek_Data\returns__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 14. REVIEW (depends on Customer, Product)
PRINT '';
PRINT '14. Loading REVIEW...';
BULK INSERT Review
FROM 'C:\Tijartek_Data\reviews__1_.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- 15. INVENTORY_LOG (depends on Product)
PRINT '';
PRINT '15. Loading INVENTORY_LOG...';
BULK INSERT Inventory_Log
FROM 'C:\Tijartek_Data\inventory_logs.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 65001
);
GO

-- ============================================================================
-- RE-ENABLE CONSTRAINTS
-- ============================================================================

PRINT '';
PRINT 'Re-enabling constraints...';

ALTER TABLE dbo.Seller WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Customer WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Product WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Session WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.User_Event WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.[Order] WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Order_Item WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Payment WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Shipment WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Return WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Review WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Inventory_Log WITH CHECK CHECK CONSTRAINT ALL;

GO

-- ============================================================================
-- DATA VERIFICATION AND VALIDATION
-- ============================================================================

PRINT '';
PRINT '========================================';
PRINT 'DATA LOAD VERIFICATION';
PRINT '========================================';
GO

-- Check row counts
SELECT 'Location' as table_name, COUNT(*) as row_count FROM Location
UNION ALL
SELECT 'Category', COUNT(*) FROM Category
UNION ALL
SELECT 'Seller', COUNT(*) FROM Seller
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'Product', COUNT(*) FROM Product
UNION ALL
SELECT 'Promotions', COUNT(*) FROM Promotions
UNION ALL
SELECT 'Session', COUNT(*) FROM Session
UNION ALL
SELECT 'User_Event', COUNT(*) FROM User_Event
UNION ALL
SELECT '[Order]', COUNT(*) FROM [Order]
UNION ALL
SELECT 'Order_Item', COUNT(*) FROM Order_Item
UNION ALL
SELECT 'Payment', COUNT(*) FROM Payment
UNION ALL
SELECT 'Shipment', COUNT(*) FROM Shipment
UNION ALL
SELECT 'Return', COUNT(*) FROM Return
UNION ALL
SELECT 'Review', COUNT(*) FROM Review
UNION ALL
SELECT 'Inventory_Log', COUNT(*) FROM Inventory_Log
ORDER BY table_name;
GO

-- Check for NULL values in critical columns
PRINT '';
PRINT 'Data Quality Checks:';
PRINT '';
SELECT 'NULL emails' as check_type, COUNT(*) as issue_count FROM Customer WHERE email IS NULL
UNION ALL
SELECT 'NULL customer names', COUNT(*) FROM Customer WHERE name IS NULL
UNION ALL
SELECT 'NULL product names', COUNT(*) FROM Product WHERE name IS NULL
UNION ALL
SELECT 'Zero or negative prices', COUNT(*) FROM Product WHERE price <= 0
UNION ALL
SELECT 'Negative stock', COUNT(*) FROM Product WHERE stock_quantity < 0
UNION ALL
SELECT 'Invalid ratings (>5)', COUNT(*) FROM Review WHERE rating > 5
UNION ALL
SELECT 'Invalid ratings (<1)', COUNT(*) FROM Review WHERE rating < 1;
GO

-- Check for orphaned foreign keys
PRINT '';
PRINT 'FK Validation (should return 0 rows):';
PRINT '';

-- Sellers with invalid locations
SELECT 'Seller with invalid location' as validation_issue, COUNT(*) as count
FROM Seller WHERE location_id NOT IN (SELECT location_id FROM Location);

-- Customers with invalid locations
SELECT 'Customer with invalid location', COUNT(*)
FROM Customer WHERE location_id IS NOT NULL AND location_id NOT IN (SELECT location_id FROM Location);

-- Products with invalid sellers
SELECT 'Product with invalid seller', COUNT(*)
FROM Product WHERE seller_id NOT IN (SELECT seller_id FROM Seller);

-- Products with invalid categories
SELECT 'Product with invalid category', COUNT(*)
FROM Product WHERE category_id NOT IN (SELECT category_id FROM Category);

-- Orders with invalid customers
SELECT 'Order with invalid customer', COUNT(*)
FROM [Order] WHERE customer_id NOT IN (SELECT customer_id FROM Customer);

-- Sessions with invalid customers
SELECT 'Session with invalid customer', COUNT(*)
FROM Session WHERE customer_id IS NOT NULL AND customer_id NOT IN (SELECT customer_id FROM Customer);

-- Order_Items with invalid orders
SELECT 'Order_Item with invalid order', COUNT(*)
FROM Order_Item WHERE order_id NOT IN (SELECT order_id FROM [Order]);

-- Order_Items with invalid products
SELECT 'Order_Item with invalid product', COUNT(*)
FROM Order_Item WHERE product_id NOT IN (SELECT product_id FROM Product);
GO

-- ============================================================================
-- UPDATE STATISTICS FOR QUERY OPTIMIZATION
-- ============================================================================

PRINT '';
PRINT 'Updating statistics...';
EXEC sp_updatestats;
PRINT 'Statistics updated.';
GO

-- ============================================================================
-- ENABLE QUERY OPTIMIZATION
-- ============================================================================

PRINT '';
PRINT '========================================';
PRINT 'DATA LOAD COMPLETE - ' + CONVERT(VARCHAR(20), GETDATE(), 120);
PRINT '========================================';
PRINT '';
PRINT 'Database is ready for Power BI and analysis!';
GO

-- ============================================================================
-- SAMPLE QUERIES TO TEST CONNECTIVITY
-- ============================================================================

-- Top 10 customers by spending
PRINT '';
PRINT 'TOP 10 CUSTOMERS BY SPENDING:';
SELECT TOP 10
    c.name,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value
FROM Customer c
LEFT JOIN [Order] o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;
GO

-- Order status distribution
PRINT '';
PRINT 'ORDER STATUS DISTRIBUTION:';
SELECT 
    status,
    COUNT(*) as order_count,
    SUM(total_amount) as revenue,
    AVG(total_amount) as avg_amount
FROM [Order]
GROUP BY status
ORDER BY order_count DESC;
GO

-- Payment method analysis
PRINT '';
PRINT 'PAYMENT METHOD ANALYSIS:';
SELECT 
    method,
    COUNT(*) as payment_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM Payment
GROUP BY method
ORDER BY total_amount DESC;
GO
