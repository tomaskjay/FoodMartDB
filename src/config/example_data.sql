-- Insert into Sections
INSERT INTO Sections (name) VALUES
('Electronics'),
('Grocery'),
('Clothing'),
('Books'),
('Furniture'),
('Toys'),
('Beauty'),
('Sports'),
('Office Supplies'),
('Automotive');

-- Insert into Contact
INSERT INTO Contact (email, phone, street, city, state, zip_code) VALUES
('supplier1_unique@example.com', '1234567890', '123 Main St', 'CityA', 'CA', '90001'),
('supplier2_unique@example.com', '1234567891', '456 Elm St', 'CityB', 'TX', '73301'),
('supplier3_unique@example.com', '1234567892', '789 Oak St', 'CityC', 'NY', '10001'),
('customer1_unique@example.com', '1234567893', '101 Pine St', 'CityD', 'FL', '32004'),
('customer2_unique@example.com', '1234567894', '202 Maple St', 'CityE', 'GA', '30004'),
('employee1_unique@example.com', '1234567895', '303 Birch St', 'CityF', 'WA', '98101'),
('employee2_unique@example.com', '1234567896', '404 Cedar St', 'CityG', 'IL', '60007'),
('employee3_unique@example.com', '1234567897', '505 Spruce St', 'CityH', 'PA', '19019'),
('customer3_unique@example.com', '1234567898', '606 Palm St', 'CityI', 'OH', '43004'),
('customer4_unique@example.com', '1234567899', '707 Willow St', 'CityJ', 'MI', '48001');

-- Insert into Supplier
INSERT INTO Supplier (name, contact_id) VALUES
('Tech Supplies Inc.', 1),
('Food Distributors LLC', 2),
('Fashion Corp.', 3);

-- Insert into Customer
INSERT INTO Customer (fname, lname, age, contact_id) VALUES
('John', 'Doe', 30, 4),
('Jane', 'Smith', 25, 5),
('Mike', 'Johnson', 40, 9),
('Emily', 'Brown', 22, 10),
('Alice', 'Davis', 35, 4),
('Bob', 'Wilson', 29, 5),
('Chris', 'Moore', 33, 9),
('Anna', 'Taylor', 28, 10),
('Tom', 'Anderson', 41, 4),
('Lucy', 'Jackson', 26, 5);

-- Insert into Employee
INSERT INTO Employee (fname, lname, age, contact_id, position, beg_date, end_date, hourly_wage, hours_worked, status) VALUES
('James', 'Williams', 35, 6, 'Manager', '2022-01-01', NULL, 50.00, 1000, 'active'),
('Linda', 'Miller', 28, 7, 'Cashier', '2023-03-15', NULL, 20.00, 500, 'active'),
('Robert', 'Garcia', 30, 8, 'Stock Associate', '2021-06-01', '2023-12-31', 15.50, 800, 'inactive'),
('Karen', 'Martinez', 26, 6, 'Assistant Manager', '2023-02-01', NULL, 30.00, 400, 'active'),
('Michael', 'Hernandez', 40, 7, 'Technician', '2019-10-01', NULL, 35.00, 1200, 'active'),
('Sarah', 'Lopez', 23, 8, 'Sales Associate', '2023-07-15', NULL, 18.00, 300, 'active'),
('David', 'Gonzalez', 32, 6, 'Delivery Driver', '2020-01-01', '2022-12-31', 25.00, 600, 'inactive'),
('Jessica', 'Clark', 27, 7, 'Receptionist', '2021-11-01', NULL, 22.00, 700, 'active'),
('Daniel', 'Lewis', 29, 8, 'Warehouse Associate', '2022-05-01', NULL, 19.50, 400, 'active'),
('Ashley', 'Young', 31, 6, 'Cleaner', '2020-02-01', NULL, 16.00, 1000, 'active');

-- Insert into Products
INSERT INTO Products (name, section_id, shelf_life) VALUES
('Smartphone', 1, 730),
('Laptop', 1, 1095),
('Bread', 2, 7),
('Milk', 2, 5),
('Jeans', 3, 365),
('T-shirt', 3, 365),
('Novel', 4, 1825),
('Desk', 5, 3650),
('Soccer Ball', 8, 1825),
('Shampoo', 7, 730);

-- Insert into BulkOrders
INSERT INTO BulkOrders (product_id, supplier_id, total_quantity, order_price, order_date) VALUES
(1, 1, 100, 900.00, '2023-01-01'),
(2, 1, 50, 1500.00, '2023-02-15'),
(3, 2, 200, 4.99, '2020-03-10'),
(4, 2, 150, 2.99, '2023-04-20'),
(5, 3, 100, 80.00, '2023-05-05'),
(6, 3, 120, 12.00, '2023-06-01'),
(7, 1, 80, 20.00, '2023-07-15'),
(8, 2, 60, 200.00, '2023-08-20'),
(9, 3, 90, 110.00, '2023-09-25'),
(10, 1, 70, 15.00, '2023-10-10');

-- Insert into Inventory
INSERT INTO Inventory (bulk_order_id, location, quantity) VALUES
(1, 'storage', 100),
(2, 'shelf', 24),
(3, 'expired', 200),
(4, 'sold', 150),
(5, 'shelf', 88),
(6, 'storage', 120),
(7, 'shelf', 78),
(8, 'storage', 60),
(9, 'shelf', 90),
(10, 'sold', 70),
(2, 'storage', 20);

-- Insert into Sales
INSERT INTO Sales (inventory_id, customer_id, sale_quantity, sale_date, sale_price, total_returned_quantity) VALUES
(2, 1, 5, '2023-11-01', 1700.00, 2),
(2, 2, 3, '2023-11-02', 1700.00, 0),
(5, 3, 2, '2023-11-03', 110.00, 0),
(5, 4, 6, '2023-11-04', 110.00, 0),
(5, 5, 4, '2023-11-05', 110.00, 0),
(7, 6, 2, '2023-11-06', 25.00, 0),
(9, 7, 70, '2023-11-07', 18.00, 0);

-- Insert into Returns
INSERT INTO Returns (sale_id, returned_quantity, return_date, reason) VALUES
(2, 1, '2023-11-15', 'Damaged item'),
(2, 1, '2023-11-16', 'Wrong size');