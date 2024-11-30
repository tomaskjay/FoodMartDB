--CREATE STATEMENTS--

CREATE TABLE Sections (
    section_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) NOT NULL
);

CREATE TABLE Contact (
    contact_id INT PRIMARY KEY IDENTITY(1,1),
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL
);

CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    contact_id INT NOT NULL,
    FOREIGN KEY (contact_id) REFERENCES Contact(contact_id)
);

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    age INT DEFAULT NULL,
    contact_id INT NOT NULL,
    FOREIGN KEY (contact_id) REFERENCES Contact(contact_id)
);

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    age INT NOT NULL CHECK (age > 16),
    contact_id INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    beg_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    hourly_wage NUMERIC(10, 2) NOT NULL CHECK (hourly_wage > 0),
    hours_worked INT DEFAULT 0,
    status VARCHAR(10) NOT NULL CHECK (status IN ('fired', 'inactive', 'active')),
    FOREIGN KEY (contact_id) REFERENCES Contact(contact_id),
    CONSTRAINT CHK_EndDate_After_BegDate CHECK (end_date IS NULL OR end_date >= beg_date)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL UNIQUE,
    section_id INT NOT NULL,
    shelf_life INT NOT NULL CHECK (shelf_life > 0),
    FOREIGN KEY (section_id) REFERENCES Sections(section_id)
);

CREATE TABLE BulkOrders (
    bulk_order_id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    total_quantity INT NOT NULL CHECK (total_quantity >= 0),
    order_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY IDENTITY(1,1),
    bulk_order_id INT NOT NULL,
    location VARCHAR(20) NOT NULL CHECK (location IN ('storage', 'shelf')),
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (bulk_order_id) REFERENCES BulkOrders(bulk_order_id)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY IDENTITY(1,1),
    inventory_id INT NOT NULL,
    customer_id INT NOT NULL,
    sale_quantity INT NOT NULL CHECK (sale_quantity > 0),
    sale_date DATE NOT NULL,
    sale_price NUMERIC(10, 2) NOT NULL,
    total_returned_quantity INT DEFAULT 0 CHECK (total_returned_quantity >= 0),
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Returns (
    return_id INT PRIMARY KEY IDENTITY(1,1),
    sale_id INT NOT NULL,
    returned_quantity INT NOT NULL CHECK (returned_quantity > 0),
    return_date DATE NOT NULL,
    reason VARCHAR(100) DEFAULT 'No reason provided',
    FOREIGN KEY (sale_id) REFERENCES Sales(sale_id)
);

--INDEXES--

CREATE INDEX idx_products_shelf_life ON Products(shelf_life);
CREATE INDEX idx_bulkorders_total_quantity ON BulkOrders(total_quantity);
CREATE INDEX idx_bulkorders_order_date ON BulkOrders(order_date);
CREATE INDEX idx_inventory_quantity ON Inventory(quantity);
CREATE INDEX idx_sales_sale_quantity ON Sales(sale_quantity);
CREATE INDEX idx_sales_sale_price ON Sales(sale_price);
CREATE INDEX idx_sales_sale_date ON Sales(sale_date);


--STORED PROCEDURES--

--basic operations--

-- Create Stored Procedure to Get All Products
CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT * FROM Products;
END;
GO

-- Create Stored Procedure to Add a New Product
CREATE PROCEDURE AddProduct
    @Name NVARCHAR(100),
    @SectionID INT,
    @ShelfLife INT
AS
BEGIN
    INSERT INTO Products (name, section_id, shelf_life)
    VALUES (@Name, @SectionID, @ShelfLife);
END;
GO

-- Create Stored Procedure to Update a Product
CREATE PROCEDURE UpdateProduct
    @ProductID INT,
    @Name NVARCHAR(100),
    @SectionID INT,
    @ShelfLife INT
AS
BEGIN
    UPDATE Products
    SET name = @Name, section_id = @SectionID, shelf_life = @ShelfLife
    WHERE product_id = @ProductID;
END;
GO

-- Create Stored Procedure to Delete a Product
CREATE PROCEDURE DeleteProduct
    @ProductID INT
AS
BEGIN
    DELETE FROM Products
    WHERE product_id = @ProductID;
END;
GO

-- Create Stored Procedure to Get Product By ID
CREATE PROCEDURE GetProductByID
    @ProductID INT
AS
BEGIN
    SELECT * FROM Products
    WHERE product_id = @ProductID;
END;
GO

-- Ensure Necessary Permissions for Stored Procedures
GRANT EXECUTE ON GetAllProducts TO PUBLIC;
GRANT EXECUTE ON AddProduct TO PUBLIC;
GRANT EXECUTE ON UpdateProduct TO PUBLIC;
GRANT EXECUTE ON DeleteProduct TO PUBLIC;
GRANT EXECUTE ON GetProductByID TO PUBLIC;
GO

-- For orders
CREATE PROCEDURE MakeOrder
    @ProductID INT,
    @SupplierID INT,
    @TotalQuantity INT,
    @OrderDate DATE
AS
BEGIN
    -- Insert into BulkOrders
    INSERT INTO BulkOrders (product_id, supplier_id, total_quantity, order_date)
    VALUES (@ProductID, @SupplierID, @TotalQuantity, @OrderDate);

    -- Get the BulkOrderID of the newly inserted order
    DECLARE @BulkOrderID INT = SCOPE_IDENTITY();

    -- Insert into Inventory with location as 'storage'
    INSERT INTO Inventory (bulk_order_id, location, quantity)
    VALUES (@BulkOrderID, 'storage', @TotalQuantity);
END;
GO

--for sales

CREATE PROCEDURE GetAllSales AS BEGIN
    SELECT * FROM Sales;
END;
GO

CREATE PROCEDURE UpdateSale
    @SaleID INT,
    @NewQuantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentQuantity INT;
    DECLARE @InventoryID INT;
    DECLARE @InventoryQuantity INT;
    DECLARE @QuantityChange INT;

    -- Retrieve the current sale and inventory details
    SELECT @CurrentQuantity = sale_quantity, @InventoryID = inventory_id
    FROM Sales
    WHERE sale_id = @SaleID;

    IF @CurrentQuantity IS NULL
    BEGIN
        PRINT 'Sale ID not found.';
        RETURN;
    END

    SELECT @InventoryQuantity = quantity
    FROM Inventory
    WHERE inventory_id = @InventoryID;

    IF @InventoryQuantity IS NULL
    BEGIN
        PRINT 'Inventory ID not found.';
        RETURN;
    END

    -- Calculate the quantity change
    SET @QuantityChange = @NewQuantity - @CurrentQuantity;

    -- Handle deletion if new quantity is zero
    IF @NewQuantity = 0
    BEGIN
        DELETE FROM Sales WHERE sale_id = @SaleID;

        -- Increment inventory by the entire sale quantity
        UPDATE Inventory
        SET quantity = quantity + @CurrentQuantity
        WHERE inventory_id = @InventoryID;

        PRINT 'Sale deleted and inventory updated successfully.';
        RETURN;
    END

    -- Handle increase in sale quantity
    IF @QuantityChange > 0
    BEGIN
        IF @InventoryQuantity < @QuantityChange
        BEGIN
            PRINT 'Error: Not enough stock in inventory to increase the sale quantity.';
            RETURN;
        END

        -- Decrease inventory
        UPDATE Inventory
        SET quantity = quantity - @QuantityChange
        WHERE inventory_id = @InventoryID;
    END

    -- Handle decrease in sale quantity
    IF @QuantityChange < 0
    BEGIN
        -- Increase inventory
        UPDATE Inventory
        SET quantity = quantity + ABS(@QuantityChange)
        WHERE inventory_id = @InventoryID;
    END

    -- Update the sale quantity
    UPDATE Sales
    SET sale_quantity = @NewQuantity
    WHERE sale_id = @SaleID;

    PRINT 'Sale and inventory updated successfully.';
END;
GO

CREATE PROCEDURE DeleteSale
    @SaleID INT
AS BEGIN
    DELETE FROM Sales WHERE sale_id = @SaleID;
END;
GO

--for orders

CREATE PROCEDURE GetAllOrders AS BEGIN
    SELECT * FROM BulkOrders;
END;
GO

CREATE PROCEDURE UpdateOrder
    @OrderID INT,
    @Quantity INT
AS BEGIN
    UPDATE BulkOrders SET total_quantity = @Quantity WHERE bulk_order_id = @OrderID;
END;
GO

CREATE PROCEDURE DeleteOrderWithConflicts
    @OrderID INT
AS
BEGIN
    -- Fetch conflicting tuples from Inventory
    SELECT 
        inventory_id, bulk_order_id, location, quantity 
    FROM Inventory
    WHERE bulk_order_id = @OrderID;

    -- Fetch conflicting tuples from Sales
    SELECT 
        sale_id, inventory_id, customer_id, sale_quantity, sale_date, sale_price 
    FROM Sales
    WHERE inventory_id IN (SELECT inventory_id FROM Inventory WHERE bulk_order_id = @OrderID);

    -- Delete related rows from Sales
    DELETE FROM Sales
    WHERE inventory_id IN (SELECT inventory_id FROM Inventory WHERE bulk_order_id = @OrderID);

    -- Delete related rows from Inventory
    DELETE FROM Inventory
    WHERE bulk_order_id = @OrderID;

    -- Finally, delete the order from BulkOrders
    DELETE FROM BulkOrders WHERE bulk_order_id = @OrderID;
END;
GO

--for inventory

--viewing all inventory
CREATE PROCEDURE GetInventory AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        i.inventory_id,
        i.bulk_order_id,
        p.name AS product_name,
        i.location,
        i.quantity
    FROM Inventory i
    INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
    INNER JOIN Products p ON b.product_id = p.product_id
    ORDER BY i.location, p.name;
END;
GO

--moving products to shelf
CREATE PROCEDURE MoveProductToShelf
    @InventoryID INT,
    @QuantityToMove INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables for inventory tracking
    DECLARE @StorageQuantity INT;
    DECLARE @BulkOrderID INT;
    DECLARE @ShelfInventoryID INT;
    DECLARE @ShelfQuantity INT;

    -- Fetch storage details for the given inventory ID
    SELECT 
        @StorageQuantity = quantity, 
        @BulkOrderID = bulk_order_id
    FROM Inventory
    WHERE inventory_id = @InventoryID AND location = 'storage';

    -- Check if the record exists in storage
    IF @StorageQuantity IS NULL
    BEGIN
        RAISERROR ('No products found in storage for the given inventory ID.', 16, 1);
        RETURN;
    END

    -- Check if the quantity to move exceeds storage quantity
    IF @StorageQuantity < @QuantityToMove
    BEGIN
        RAISERROR ('Not enough quantity in storage to move.', 16, 1);
        RETURN;
    END

    -- Check if a record for the bulk order already exists on the shelf
    SELECT 
        @ShelfInventoryID = inventory_id, 
        @ShelfQuantity = quantity
    FROM Inventory
    WHERE bulk_order_id = @BulkOrderID AND location = 'shelf';

    -- If the inventory ID is already on the shelf
    IF @InventoryID = @ShelfInventoryID
    BEGIN
        RAISERROR ('The specified inventory ID is already on the shelf.', 16, 1);
        RETURN;
    END

    -- Handle full quantity move
    IF @QuantityToMove = @StorageQuantity
    BEGIN
        IF @ShelfInventoryID IS NOT NULL
        BEGIN
            -- Combine with existing shelf record and delete the storage record
            UPDATE Inventory
            SET quantity = quantity + @StorageQuantity
            WHERE inventory_id = @ShelfInventoryID;

            DELETE FROM Inventory
            WHERE inventory_id = @InventoryID;

            PRINT 'All products moved to shelf and combined with existing inventory.';
        END
        ELSE
        BEGIN
            -- Change location of storage record to shelf
            UPDATE Inventory
            SET location = 'shelf'
            WHERE inventory_id = @InventoryID;

            PRINT 'All products moved to shelf successfully.';
        END
        RETURN;
    END

    -- Handle partial quantity move
    IF @ShelfInventoryID IS NOT NULL
    BEGIN
        -- Combine with existing shelf record
        UPDATE Inventory
        SET quantity = quantity + @QuantityToMove
        WHERE inventory_id = @ShelfInventoryID;

        -- Decrement storage quantity
        UPDATE Inventory
        SET quantity = quantity - @QuantityToMove
        WHERE inventory_id = @InventoryID;

        PRINT 'Products moved and combined with existing shelf inventory.';
    END
    ELSE
    BEGIN
        -- Create a new shelf record for the partial quantity
        INSERT INTO Inventory (bulk_order_id, location, quantity)
        VALUES (@BulkOrderID, 'shelf', @QuantityToMove);

        -- Decrement storage quantity
        UPDATE Inventory
        SET quantity = quantity - @QuantityToMove
        WHERE inventory_id = @InventoryID;

        PRINT 'Products moved and new shelf inventory created.';
    END
END;
GO