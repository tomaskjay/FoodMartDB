--CREATE STATEMENTS--
/*
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
    order_price INT NOT NULL CHECK (order_price >= 0),
    order_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY IDENTITY(1,1),
    bulk_order_id INT NOT NULL,
    location VARCHAR(20) NOT NULL CHECK (location IN ('storage', 'shelf', 'sold', 'expired')),
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (bulk_order_id) REFERENCES BulkOrders(bulk_order_id)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY IDENTITY(1,1),
    inventory_id INT NULL,
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
*/

--STORED PROCEDURES--

--for contacts (used in other procedures so put here first)

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
    @OrderDate DATE,
    @OrderPrice NUMERIC(10, 2) -- New parameter for order price
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        -- Insert into BulkOrders with the new attribute `order_price`
        INSERT INTO BulkOrders (product_id, supplier_id, total_quantity, order_date, order_price)
        VALUES (@ProductID, @SupplierID, @TotalQuantity, @OrderDate, @OrderPrice);

        -- Get the BulkOrderID of the newly inserted order
        DECLARE @BulkOrderID INT = SCOPE_IDENTITY();

        -- Insert into Inventory with location as 'storage'
        INSERT INTO Inventory (bulk_order_id, location, quantity)
        VALUES (@BulkOrderID, 'storage', @TotalQuantity);

        -- If everything succeeds, commit the transaction
        COMMIT TRANSACTION;

        PRINT 'Order and associated inventory created successfully.';
    END TRY
    BEGIN CATCH
        -- Rollback the transaction on error
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Retrieve error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- Raise the error to the calling application
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


CREATE PROCEDURE GetLastCustomerId AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 customer_id
    FROM Customer
    ORDER BY customer_id DESC;
END;
GO


CREATE PROCEDURE GetInventoryById
    @InventoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        inventory_id,
        bulk_order_id,
        location,
        quantity
    FROM Inventory
    WHERE inventory_id = @InventoryID;
END;
GO

ALTER PROCEDURE RecordSale
    @InventoryID INT,
    @CustomerID INT,
    @SaleQuantity INT,
    @SaleDate DATE,
    @SalePrice NUMERIC(10, 2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insert the sale record
        INSERT INTO Sales (inventory_id, customer_id, sale_quantity, sale_date, sale_price)
        VALUES (@InventoryID, @CustomerID, @SaleQuantity, @SaleDate, @SalePrice);

        PRINT 'Sale recorded successfully.';

        -- Commit the transaction if everything succeeds
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of error
        ROLLBACK TRANSACTION;

        -- Re-throw the error
        THROW;
    END CATCH;
END;
GO


CREATE PROCEDURE DecrementInventory
    @InventoryID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Inventory
    SET quantity = quantity - @Quantity
    WHERE inventory_id = @InventoryID;

    PRINT 'Inventory decremented successfully.';
END;
GO


CREATE PROCEDURE UpdateInventory
    @InventoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the inventory record exists
    IF NOT EXISTS (SELECT 1 FROM Inventory WHERE inventory_id = @InventoryID)
    BEGIN
        RAISERROR ('Error: Inventory ID not found.', 16, 1);
        RETURN;
    END

    -- Update the inventory location to 'sold' and set quantity to 0
    UPDATE Inventory
    SET location = 'sold',
        quantity = 0
    WHERE inventory_id = @InventoryID;

    PRINT 'Inventory updated to sold with quantity set to 0.';
END;
GO


--for orders

CREATE PROCEDURE GetAllOrders AS BEGIN
    SELECT * FROM BulkOrders;
END;
GO


CREATE PROCEDURE UpdateOrder
    @OrderID INT,
    @OrderDate DATE = NULL,
    @OrderPrice NUMERIC(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the order exists
    IF NOT EXISTS (SELECT 1 FROM BulkOrders WHERE bulk_order_id = @OrderID)
    BEGIN
        RAISERROR ('Error: Order ID not found.', 16, 1);
        RETURN;
    END

    -- Update attributes other than total_quantity
    UPDATE BulkOrders
    SET 
        order_date = ISNULL(@OrderDate, order_date),
        order_price = ISNULL(@OrderPrice, order_price)
    WHERE bulk_order_id = @OrderID;

    PRINT 'Order updated successfully.';
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
    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        SET NOCOUNT ON;

        -- Fetch inventory details
        SELECT 
            i.inventory_id,
            i.bulk_order_id,
            p.name AS product_name,
            i.location,
            i.quantity
        FROM Inventory i
        INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
        INNER JOIN Products p ON b.product_id = p.product_id
        WHERE i.location IN ('storage', 'shelf') -- Only include storage and shelf locations
        ORDER BY i.location, p.name;

        -- Commit the transaction if successful
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Raise an error with a meaningful message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--moving products to shelf
CREATE PROCEDURE MoveProductToShelf
    @InventoryID INT,
    @QuantityToMove INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
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
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if the quantity to move exceeds storage quantity
        IF @StorageQuantity < @QuantityToMove
        BEGIN
            RAISERROR ('Not enough quantity in storage to move.', 16, 1);
            ROLLBACK TRANSACTION;
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
            ROLLBACK TRANSACTION;
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

            COMMIT TRANSACTION;
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

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Declare and retrieve error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Raise the captured error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
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

CREATE PROCEDURE GetAllEmployees AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.employee_id,
        e.fname AS first_name,
        e.lname AS last_name,
        e.age,
        e.position,
        e.hourly_wage,
        e.beg_date AS start_date,
        e.end_date AS end_date,
        e.hours_worked,
        e.status,
        c.email,
        c.phone,
        c.street,
        c.city,
        c.state,
        c.zip_code
    FROM Employee e
    INNER JOIN Contact c ON e.contact_id = c.contact_id
    ORDER BY e.employee_id;
END;
GO


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

--for returns
CREATE PROCEDURE GetSaleById
    @SaleID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve the sale details by SaleID
    SELECT 
        sale_id,
        inventory_id,
        customer_id,
        sale_quantity,
        sale_date,
        sale_price,
        total_returned_quantity
    FROM Sales
    WHERE sale_id = @SaleID;

    -- Check if the SaleID exists
    IF NOT EXISTS (SELECT 1 FROM Sales WHERE sale_id = @SaleID)
    BEGIN
        THROW 50000, 'Error: Sale ID not found.', 1;
    END;
END;
GO

CREATE PROCEDURE MakeReturn
    @SaleID INT,
    @ReturnedQuantity INT,
    @ReturnDate DATE,
    @Reason NVARCHAR(100) = 'No reason provided'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SaleQuantity INT;
    DECLARE @TotalReturnedQuantity INT;
    DECLARE @InventoryID INT;
    DECLARE @CurrentLocation NVARCHAR(20);

    -- Validate the sale ID and fetch related data
    SELECT 
        @SaleQuantity = sale_quantity,
        @TotalReturnedQuantity = total_returned_quantity,
        @InventoryID = inventory_id
    FROM Sales
    WHERE sale_id = @SaleID;

    IF @SaleQuantity IS NULL
    BEGIN
        RAISERROR ('Error: Sale ID not found.', 16, 1);
        RETURN;
    END

    -- Validate the returned quantity
    IF @ReturnedQuantity < 1
    BEGIN
        RAISERROR ('Error: Returned quantity must be at least 1.', 16, 1);
        RETURN;
    END

    IF (@TotalReturnedQuantity + @ReturnedQuantity) > @SaleQuantity
    BEGIN
        RAISERROR ('Error: Returned quantity exceeds the sale quantity.', 16, 1);
        RETURN;
    END

    -- Insert into Returns table
    INSERT INTO Returns (sale_id, returned_quantity, return_date, reason)
    VALUES (@SaleID, @ReturnedQuantity, @ReturnDate, @Reason);

    -- Update the Sales table to increment total returned quantity
    UPDATE Sales
    SET total_returned_quantity = total_returned_quantity + @ReturnedQuantity
    WHERE sale_id = @SaleID;

    -- If the inventory ID exists, update the inventory
    IF @InventoryID IS NOT NULL
    BEGIN
        -- Fetch the current location of the inventory
        SELECT @CurrentLocation = location
        FROM Inventory
        WHERE inventory_id = @InventoryID;

        -- If the current location is 'sold', change it back to 'shelf'
        IF @CurrentLocation = 'sold'
        BEGIN
            UPDATE Inventory
            SET location = 'shelf',
                quantity = @ReturnedQuantity -- Reset quantity to the returned amount
            WHERE inventory_id = @InventoryID;
        END
        ELSE
        BEGIN
            -- Increment the quantity in the inventory
            UPDATE Inventory
            SET quantity = quantity + @ReturnedQuantity
            WHERE inventory_id = @InventoryID;
        END
    END

    PRINT 'Return processed successfully.';
END;
GO

--for finding expired products
CREATE PROCEDURE MarkExpiredProducts
AS
BEGIN
    SET NOCOUNT ON;

    -- Begin transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Temporary table to store expired products for output
        CREATE TABLE #ExpiredProducts (
            inventory_id INT,
            bulk_order_id INT,
            product_name NVARCHAR(100),
            location NVARCHAR(20),
            quantity INT,
            bulk_order_date DATE
        );

        -- Identify and mark expired products
        INSERT INTO #ExpiredProducts (inventory_id, bulk_order_id, product_name, location, quantity, bulk_order_date)
        SELECT 
            i.inventory_id,
            i.bulk_order_id,
            p.name AS product_name,
            i.location,
            i.quantity,
            b.order_date
        FROM Inventory i
        INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
        INNER JOIN Products p ON b.product_id = p.product_id
        WHERE i.location IN ('shelf', 'storage') -- Only consider shelf or storage
          AND DATEDIFF(DAY, b.order_date, GETDATE()) > p.shelf_life; -- Expired based on shelf life

        -- Update the location of expired products
        UPDATE Inventory
        SET location = 'expired'
        WHERE inventory_id IN (SELECT inventory_id FROM #ExpiredProducts);

        -- Output the expired products
        SELECT * FROM #ExpiredProducts;

        -- Drop the temporary table
        DROP TABLE #ExpiredProducts;

        -- Commit transaction
        COMMIT TRANSACTION;

        PRINT 'Expired products have been marked successfully.';
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of an error
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Re-throw the error to the caller
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE DetectShoplifting
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Begin a transaction
        BEGIN TRANSACTION;

        -- Identify discrepancies in product quantities
        SELECT 
            p.name AS product_name,
            bos.total_ordered AS total_ordered,
            COALESCE(ss.total_sold, 0) AS total_sold,
            COALESCE(isum.total_inventory, 0) AS total_inventory,
            bos.total_ordered - (COALESCE(ss.total_sold, 0) + COALESCE(isum.total_inventory, 0)) AS discrepancy
        FROM (
            -- Total quantity ordered
            SELECT 
                b.product_id,
                SUM(b.total_quantity) AS total_ordered
            FROM BulkOrders b
            GROUP BY b.product_id
        ) bos
        LEFT JOIN (
            -- Total quantity sold
            SELECT 
                b.product_id,
                SUM(s.sale_quantity) AS total_sold
            FROM Sales s
            INNER JOIN Inventory i ON s.inventory_id = i.inventory_id
            INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
            GROUP BY b.product_id
        ) ss ON bos.product_id = ss.product_id
        LEFT JOIN (
            -- Total quantity remaining in inventory
            SELECT 
                b.product_id,
                SUM(i.quantity) AS total_inventory
            FROM Inventory i
            INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
            GROUP BY b.product_id
        ) isum ON bos.product_id = isum.product_id
        INNER JOIN Products p ON bos.product_id = p.product_id
        WHERE bos.total_ordered <> (COALESCE(ss.total_sold, 0) + COALESCE(isum.total_inventory, 0));

        -- Print message upon successful execution
        PRINT 'Shoplifting detection completed.';

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Raise an error message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


CREATE PROCEDURE GetPopularProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.name AS product_name,
        SUM(s.sale_quantity) AS total_sold,
        SUM(s.sale_quantity * s.sale_price) AS total_revenue
    FROM Sales s
    INNER JOIN Inventory i ON s.inventory_id = i.inventory_id
    INNER JOIN BulkOrders b ON i.bulk_order_id = b.bulk_order_id
    INNER JOIN Products p ON b.product_id = p.product_id
    GROUP BY p.name
    ORDER BY total_sold DESC, total_revenue DESC;

    PRINT 'Popular products fetched successfully.';
END;
GO

-- TRIGGERS

-- make that that tuples in sales have locatino of either shelf or sold
CREATE TRIGGER trg_CheckInventoryLocationForSales
ON Sales
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check that all referenced inventory_id values have a valid location ('shelf' or 'sold')
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Inventory inv ON i.inventory_id = inv.inventory_id
        WHERE inv.location NOT IN ('shelf', 'sold')
    )
    BEGIN
        RAISERROR ('Error: Inventory location must be either ''shelf'' or ''sold''.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
