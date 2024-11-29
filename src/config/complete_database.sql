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


/*
--for use case #1--

CREATE PROCEDURE sp_add_customer
    @contact_id INT,
    @fname VARCHAR(50),
    @lname VARCHAR(50),
    @age INT = NULL -- Optional parameter, default is NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate age if provided
    IF @age IS NOT NULL AND @age <= 0
    BEGIN
        PRINT 'Invalid age. Age must be a positive number.';
        RETURN;
    END

    INSERT INTO Customer (fname, lname, contact_id, age)
    VALUES (@fname, @lname, @contact_id, @age);

    PRINT 'Customer added successfully.';
END;

CREATE PROCEDURE sp_add_contact
    @email VARCHAR(100),
    @phone VARCHAR(15),
    @street VARCHAR(100),
    @city VARCHAR(50),
    @state CHAR(2),
    @zip_code VARCHAR(10),
    @new_contact_id INT OUTPUT -- Optional output parameter to return the new contact ID
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate required fields
    IF @email IS NULL OR LEN(@email) = 0
    BEGIN
        PRINT 'Email is required.';
        RETURN;
    END

    IF @phone IS NULL OR LEN(@phone) = 0
    BEGIN
        PRINT 'Phone is required.';
        RETURN;
    END

    IF @street IS NULL OR LEN(@street) = 0
    BEGIN
        PRINT 'Street address is required.';
        RETURN;
    END

    IF @city IS NULL OR LEN(@city) = 0
    BEGIN
        PRINT 'City is required.';
        RETURN;
    END

    IF @state IS NULL OR LEN(@state) != 2
    BEGIN
        PRINT 'State must be a valid two-character code.';
        RETURN;
    END

    IF @zip_code IS NULL OR LEN(@zip_code) = 0
    BEGIN
        PRINT 'Zip code is required.';
        RETURN;
    END

    -- Insert new contact into the Contact table
    INSERT INTO Contact (email, phone, street, city, state, zip_code)
    VALUES (@email, @phone, @street, @city, @state, @zip_code);

    -- Retrieve the ID of the newly inserted contact
    SET @new_contact_id = SCOPE_IDENTITY();

    PRINT 'Contact added successfully.';
END;

--for use case #2--

*/