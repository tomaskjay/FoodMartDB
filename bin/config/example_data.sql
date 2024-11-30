-- Insert into Sections
INSERT INTO Sections (name) VALUES
('Beverages'),
('Snacks'),
('Produce'),
('Dairy'),
('Bakery'),
('Meat'),
('Seafood'),
('Frozen Foods'),
('Condiments'),
('Cleaning Supplies');

-- Insert into Contact
INSERT INTO Contact (email, phone, street, city, state, zip_code) VALUES
('supplier1@example.com', '555-1111', '123 Main St', 'Springfield', 'IL', '62701'),
('supplier2@example.com', '555-2222', '456 Oak St', 'Metropolis', 'NY', '10101'),
('customer1@example.com', '555-3333', '789 Pine St', 'Gotham', 'NJ', '07001'),
('customer2@example.com', '555-4444', '135 Maple Ave', 'Smallville', 'KS', '66002'),
('employee1@example.com', '555-5555', '246 Elm St', 'Central City', 'OH', '43002'),
('employee2@example.com', '555-6666', '357 Cedar St', 'Star City', 'CA', '94001'),
('supplier3@example.com', '555-7777', '468 Birch Rd', 'Bludhaven', 'TX', '77001'),
('customer3@example.com', '555-8888', '579 Palm St', 'Hub City', 'FL', '33002'),
('employee3@example.com', '555-9999', '680 Ash St', 'Keystone City', 'PA', '19001'),
('supplier4@example.com', '555-1010', '791 Fir Dr', 'Coast City', 'OR', '97001');

-- Insert into Supplier
INSERT INTO Supplier (name, contact_id) VALUES
('Global Beverages', 1),
('Snack Heaven', 2),
('Fresh Produce Co.', 7),
('Dairy Delights', 10),
('Bakery Bliss', 3),
('Meat Masters', 6),
('Ocean Harvest', 5),
('Frosty Foods', 4),
('Condiment Kings', 9),
('Clean Sweep Supplies', 8);

-- Insert into Customer
INSERT INTO Customer (fname, lname, age, contact_id) VALUES
('John', 'Doe', 30, 3),
('Jane', 'Smith', 25, 4),
('Alex', 'Brown', 40, 8),
('Chris', 'Johnson', 35, 9),
('Kelly', 'Green', 28, 7),
('Pat', 'White', 45, 10),
('Sam', 'Black', 32, 5),
('Jordan', 'Gray', 29, 6),
('Taylor', 'Blue', 22, 2),
('Morgan', 'Red', 38, 1);

-- Insert into Employee
INSERT INTO Employee (fname, lname, age, contact_id, position, beg_date, end_date, hourly_wage, hours_worked, status) VALUES
('Clark', 'Kent', 35, 5, 'Manager', '2022-01-01', NULL, 25.50, 500, 'active'),
('Bruce', 'Wayne', 45, 6, 'Supervisor', '2021-06-15', NULL, 30.00, 700, 'active'),
('Diana', 'Prince', 33, 9, 'Cashier', '2023-03-10', NULL, 15.00, 200, 'active'),
('Barry', 'Allen', 28, 8, 'Stocker', '2022-09-01', NULL, 18.00, 350, 'active'),
('Hal', 'Jordan', 32, 10, 'Driver', '2020-11-20', NULL, 20.00, 400, 'inactive'),
('Arthur', 'Curry', 40, 7, 'Butcher', '2019-08-05', '2023-02-28', 22.00, 1000, 'fired'),
('Victor', 'Stone', 25, 4, 'Cashier', '2022-05-14', NULL, 16.00, 300, 'active'),
('Oliver', 'Queen', 35, 3, 'Manager', '2021-01-01', NULL, 26.50, 600, 'active'),
('Kara', 'Danvers', 29, 2, 'Cashier', '2023-01-20', NULL, 15.50, 150, 'active'),
('John', 'Stewart', 38, 1, 'Supervisor', '2018-12-15', NULL, 28.00, 800, 'inactive');

-- Insert into Products
INSERT INTO Products (name, section_id, shelf_life) VALUES
('Coca Cola', 1, 365),
('Pepsi', 1, 365),
('Lays Chips', 2, 180),
('Doritos', 2, 180),
('Bananas', 3, 7),
('Apples', 3, 10),
('Milk', 4, 7),
('Bread', 5, 3),
('Chicken', 6, 5),
('Shrimp', 7, 2);

-- Insert into BulkOrders
INSERT INTO BulkOrders (product_id, supplier_id, total_quantity, order_date) VALUES
(1, 1, 1000, '2024-01-01'),
(2, 1, 800, '2024-01-02'),
(3, 2, 500, '2024-01-03'),
(4, 2, 600, '2024-01-04'),
(5, 3, 300, '2024-01-05'),
(6, 3, 400, '2024-01-06'),
(7, 4, 700, '2024-01-07'),
(8, 5, 200, '2024-01-08'),
(9, 6, 500, '2024-01-09'),
(10, 7, 150, '2024-01-10');

-- Insert into Inventory
INSERT INTO Inventory (bulk_order_id, location, quantity) VALUES
(1, 'storage', 500),
(1, 'shelf', 500),
(2, 'storage', 400),
(3, 'storage', 300),
(4, 'shelf', 600),
(5, 'shelf', 300),
(6, 'storage', 200),
(7, 'shelf', 700),
(8, 'storage', 200),
(9, 'shelf', 500);

-- Insert into Sales
INSERT INTO Sales (inventory_id, customer_id, sale_quantity, sale_date, sale_price, total_returned_quantity) VALUES
(2, 1, 100, '2024-01-15', 1.50, 0),
(4, 2, 200, '2024-01-16', 2.00, 20),
(5, 3, 50, '2024-01-17', 1.75, 0),
(7, 4, 300, '2024-01-18', 2.25, 0),
(9, 5, 100, '2024-01-19', 3.00, 10),
(1, 6, 150, '2024-01-20', 1.25, 0),
(2, 7, 200, '2024-01-21', 2.00, 0),
(3, 8, 50, '2024-01-22', 1.00, 0),
(4, 9, 100, '2024-01-23', 2.50, 0),
(6, 10, 250, '2024-01-24', 2.75, 30);

-- Insert into Returns
INSERT INTO Returns (sale_id, returned_quantity, return_date, reason) VALUES
(2, 20, '2024-01-25', 'Damaged packaging'),
(5, 10, '2024-01-26', 'Customer complaint'),
(10, 30, '2024-01-27', 'Expired product'),
(1, 5, '2024-01-28', 'Wrong item delivered'),
(7, 15, '2024-01-29', 'Customer dissatisfaction'),
(4, 10, '2024-01-30', 'Late delivery'),
(9, 5, '2024-01-31', 'Incorrect quantity'),
(3, 20, '2024-02-01', 'Customer error'),
(6, 10, '2024-02-02', 'Store policy'),
(8, 15, '2024-02-03', 'Broken seal');
