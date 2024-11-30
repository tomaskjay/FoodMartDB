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

-- to create a new contact
CREATE PROCEDURE AddContact
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Street NVARCHAR(100),
    @City NVARCHAR(50),
    @State CHAR(2),
    @ZipCode NVARCHAR(10),
    @ContactID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert the contact information into the Contact table
    INSERT INTO Contact (email, phone, street, city, state, zip_code)
    VALUES (@Email, @Phone, @Street, @City, @State, @ZipCode);

    -- Retrieve the newly inserted contact_id
    SET @ContactID = SCOPE_IDENTITY();

    PRINT 'Contact added successfully.';
END;
GO

--to update a contact
CREATE PROCEDURE UpdateContact
    @ContactID INT,
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Street NVARCHAR(100),
    @City NVARCHAR(50),
    @State CHAR(2),
    @ZipCode NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the contact exists
    IF NOT EXISTS (SELECT 1 FROM Contact WHERE contact_id = @ContactID)
    BEGIN
        RAISERROR ('Error: Contact ID not found.', 16, 1);
        RETURN;
    END

    -- Update the contact details
    UPDATE Contact
    SET 
        email = @Email,
        phone = @Phone,
        street = @Street,
        city = @City,
        state = @State,
        zip_code = @ZipCode
    WHERE contact_id = @ContactID;

    PRINT 'Contact updated successfully.';
END;
GO

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

--listing and removing expired products

CREATE PROCEDURE TossExpiredProducts AS
BEGIN
    SET NOCOUNT ON;

    -- Temporary table to store expired products for listing
    CREATE TABLE #ExpiredProducts (
        inventory_id INT,
        product_name NVARCHAR(100),
        location NVARCHAR(20),
        quantity INT,
        bulk_order_date DATE
    );

    -- Insert expired products into the temporary table
    INSERT INTO #ExpiredProducts (inventory_id, product_name, location, quantity, bulk_order_date)
    SELECT 
        i.inventory_id,
        p.name AS product_name,
        i.location,
        i.quantity,
        b.order_date AS bulk_order_date
    FROM Inventory i
    INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
    INNER JOIN Products p ON b.product_id = p.product_id
    WHERE i.location = 'shelf' 
      AND DATEDIFF(DAY, b.order_date, GETDATE()) > p.shelf_life;

    -- Select the expired products for listing
    SELECT * FROM #ExpiredProducts;

    -- Delete the expired products from the inventory
    DELETE FROM Inventory
    WHERE inventory_id IN (SELECT inventory_id FROM #ExpiredProducts);

    PRINT 'Expired products have been listed and removed from inventory.';

    -- Drop the temporary table
    DROP TABLE #ExpiredProducts;
END;
GO

--for customers

--viewing all customers

CREATE PROCEDURE GetAllCustomers AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.customer_id,
        c.fname AS first_name,
        c.lname AS last_name,
        c.age,
        contact.email,
        contact.phone,
        contact.street,
        contact.city,
        contact.state,
        contact.zip_code
    FROM Customer c
    INNER JOIN Contact contact ON c.contact_id = contact.contact_id
    ORDER BY c.customer_id;
END;
GO

--adding a customer

CREATE PROCEDURE AddCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Age INT,
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Street NVARCHAR(100),
    @City NVARCHAR(50),
    @State CHAR(2),
    @ZipCode NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ContactID INT;

    -- Use AddContact to create a new contact record
    EXEC AddContact 
        @Email = @Email,
        @Phone = @Phone,
        @Street = @Street,
        @City = @City,
        @State = @State,
        @ZipCode = @ZipCode,
        @ContactID = @ContactID OUTPUT;

    -- Insert the new customer using the generated contact_id
    INSERT INTO Customer (fname, lname, age, contact_id)
    VALUES (@FirstName, @LastName, @Age, @ContactID);

    PRINT 'Customer added successfully.';
END;
GO

--updating a customer


CREATE PROCEDURE EditCustomer
    @CustomerID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Age INT,
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Street NVARCHAR(100),
    @City NVARCHAR(50),
    @State CHAR(2),
    @ZipCode NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ContactID INT;

    -- Retrieve the contact ID for the customer
    SELECT @ContactID = contact_id FROM Customer WHERE customer_id = @CustomerID;

    IF @ContactID IS NULL
    BEGIN
        RAISERROR ('Error: Customer ID not found.', 16, 1);
        RETURN;
    END

    -- Update the contact using the UpdateContact procedure
    EXEC UpdateContact 
        @ContactID = @ContactID,
        @Email = @Email,
        @Phone = @Phone,
        @Street = @Street,
        @City = @City,
        @State = @State,
        @ZipCode = @ZipCode;

    -- Update the Customer table
    UPDATE Customer
    SET 
        fname = @FirstName,
        lname = @LastName,
        age = @Age
    WHERE customer_id = @CustomerID;

    PRINT 'Customer updated successfully.';
END;
GO

--remove a customer

CREATE PROCEDURE RemoveCustomer
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the customer exists
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE customer_id = @CustomerID)
    BEGIN
        RAISERROR ('Error: Customer ID not found.', 16, 1);
        RETURN;
    END

    DECLARE @ContactID INT;

    -- Retrieve the contact ID associated with the customer
    SELECT @ContactID = contact_id FROM Customer WHERE customer_id = @CustomerID;

    -- Delete the customer record
    DELETE FROM Customer
    WHERE customer_id = @CustomerID;

    -- Delete the associated contact record
    DELETE FROM Contact
    WHERE contact_id = @ContactID;

    PRINT 'Customer and associated contact removed successfully.';
END;
GO

--for suppliers

CREATE PROCEDURE GetAllSuppliers AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.supplier_id,
        s.name AS supplier_name,
        c.email,
        c.phone,
        c.street,
        c.city,
        c.state,
        c.zip_code
    FROM Supplier s
    INNER JOIN Contact c ON s.contact_id = c.contact_id
    ORDER BY s.supplier_id;
END;
GO

CREATE PROCEDURE AddSupplier
    @Name NVARCHAR(100),
    @ContactID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Supplier (name, contact_id)
    VALUES (@Name, @ContactID);

    PRINT 'Supplier added successfully.';
END;
GO


CREATE PROCEDURE UpdateSupplier
    @SupplierID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Supplier
    SET name = @Name
    WHERE supplier_id = @SupplierID;

    PRINT 'Supplier updated successfully.';
END;
GO

CREATE PROCEDURE GetContactBySupplier
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT contact_id
    FROM Supplier
    WHERE supplier_id = @SupplierID;
END;
GO

--for employee submenu

CREATE PROCEDURE CheckEmployeeStatus
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT status
    FROM Employee
    WHERE employee_id = @EmployeeID;
END;
GO

CREATE PROCEDURE AddEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Age INT,
    @ContactID INT,
    @Position NVARCHAR(50),
    @HourlyWage NUMERIC(10, 2),
    @StartDate DATE,
    @EndDate DATE = NULL,
    @HoursWorked INT = 0,
    @Status NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Employee (fname, lname, age, contact_id, position, hourly_wage, beg_date, end_date, hours_worked, status)
    VALUES (@FirstName, @LastName, @Age, @ContactID, @Position, @HourlyWage, @StartDate, @EndDate, @HoursWorked, @Status);

    PRINT 'Employee added successfully.';
END;
GO

CREATE PROCEDURE UpdateEmployee
    @EmployeeID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Age INT,
    @Position NVARCHAR(50),
    @HourlyWage NUMERIC(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Employee
    SET 
        fname = @FirstName,
        lname = @LastName,
        age = @Age,
        position = @Position,
        hourly_wage = @HourlyWage
    WHERE employee_id = @EmployeeID;

    PRINT 'Employee updated successfully.';
END;
GO


CREATE PROCEDURE GetContactByEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT contact_id
    FROM Employee
    WHERE employee_id = @EmployeeID;
END;
GO

