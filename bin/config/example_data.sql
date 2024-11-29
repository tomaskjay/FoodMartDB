--example data for every table--

INSERT INTO Sections (name) VALUES
('Beverages'),
('Snacks'),
('Fruits'),
('Vegetables'),
('Dairy'),
('Bakery'),
('Meat'),
('Seafood'),
('Frozen Foods'),
('Household Items');

INSERT INTO Contact (email, phone, street, city, state, zip_code) VALUES
('supplier1@example.com', '1234567890', '123 Main St', 'Springfield', 'IL', '62701'),
('supplier2@example.com', '9876543210', '456 Oak Ave', 'Chicago', 'IL', '60601'),
('supplier3@example.com', '5551234567', '789 Pine Blvd', 'Peoria', 'IL', '61601'),
('customer1@example.com', '3216549870', '101 Maple Dr', 'Naperville', 'IL', '60540'),
('customer2@example.com', '6549873210', '202 Birch Ln', 'Rockford', 'IL', '61101'),
('customer3@example.com', '7893216540', '303 Cedar Ct', 'Aurora', 'IL', '60506'),
('employee1@example.com', '1112223333', '404 Elm St', 'Joliet', 'IL', '60431'),
('employee2@example.com', '4445556666', '505 Walnut Rd', 'Springfield', 'IL', '62701'),
('employee3@example.com', '7778889999', '606 Ash St', 'Champaign', 'IL', '61820'),
('general1@example.com', '2223334444', '707 Chestnut Blvd', 'Decatur', 'IL', '62521');

INSERT INTO Supplier (name, contact_id) VALUES
('ABC Beverages', 1),
('Snacks & Co.', 2),
('Fresh Fruits Supply', 3),
('Dairy Delight', 10),
('Best Bakery', 7),
('Prime Meats', 8),
('Seafood Market', 9),
('Frozen Goods', 6),
('Household Wholesale', 4),
('Gourmet Foods', 5);

INSERT INTO Customer (fname, lname, age, contact_id) VALUES
('John', 'Doe', 30, 4),
('Jane', 'Smith', 25, 5),
('Alice', 'Johnson', 40, 6),
('Bob', 'Brown', 28, 7),
('Charlie', 'Davis', 35, 8),
('Eve', 'Clark', 32, 9),
('Frank', 'Adams', 27, 10),
('Grace', 'Taylor', 31, 1),
('Hank', 'White', 29, 2),
('Ivy', 'Thomas', 24, 3);

INSERT INTO Employee (fname, lname, age, contact_id, position, beg_date, hourly_wage, status) VALUES
('Tom', 'Harris', 30, 7, 'Manager', '2020-01-01', 25.50, 'active'),
('Sara', 'Lee', 28, 8, 'Cashier', '2021-05-15', 15.00, 'active'),
('Mike', 'Jones', 35, 9, 'Stocker', '2019-11-20', 18.25, 'active'),
('Nancy', 'King', 40, 6, 'Supervisor', '2018-03-01', 20.00, 'active'),
('James', 'Miller', 50, 5, 'Janitor', '2017-07-10', 14.50, 'active'),
('Patricia', 'Williams', 33, 4, 'Cashier', '2022-09-01', 15.75, 'active'),
('Robert', 'Martinez', 38, 3, 'Stocker', '2019-06-01', 17.00, 'active'),
('Linda', 'Garcia', 42, 2, 'Manager', '2015-02-20', 26.00, 'active'),
('Michael', 'Wilson', 29, 1, 'Clerk', '2023-01-15', 16.00, 'active'),
('Susan', 'Anderson', 36, 10, 'Supervisor', '2021-12-01', 22.00, 'active');

INSERT INTO Products (name, section_id, shelf_life) VALUES
('Coke', 1, 365),
('Pepsi', 1, 365),
('Lays Chips', 2, 180),
('Doritos', 2, 180),
('Apples', 3, 10),
('Bananas', 3, 7),
('Carrots', 4, 14),
('Milk', 5, 7),
('Bread', 6, 3),
('Chicken', 7, 5);

INSERT INTO BulkOrders (product_id, supplier_id, total_quantity, order_date) VALUES
(1, 1, 1000, '2024-01-01'),
(2, 1, 800, '2024-01-02'),
(3, 2, 500, '2024-01-05'),
(4, 2, 400, '2024-01-10'),
(5, 3, 200, '2024-01-15'),
(6, 3, 300, '2024-01-20'),
(7, 4, 100, '2024-01-25'),
(8, 5, 600, '2024-01-30'),
(9, 6, 50, '2024-02-01'),
(10, 7, 150, '2024-02-05');

INSERT INTO Inventory (bulk_order_id, location, quantity) VALUES
(1, 'storage', 500),
(1, 'shelf', 500),
(2, 'storage', 400),
(2, 'shelf', 400),
(3, 'storage', 250),
(3, 'shelf', 250),
(4, 'storage', 200),
(5, 'storage', 150),
(6, 'shelf', 100),
(7, 'storage', 100);

INSERT INTO Sales (inventory_id, customer_id, sale_quantity, sale_date, sale_price) VALUES
(1, 1, 10, '2024-02-10', 12.50),
(2, 2, 8, '2024-02-11', 10.00),
(3, 3, 15, '2024-02-12', 18.75),
(4, 4, 5, '2024-02-13', 6.25),
(5, 5, 20, '2024-02-14', 25.00),
(6, 6, 12, '2024-02-15', 15.00),
(7, 7, 7, '2024-02-16', 8.75),
(8, 8, 10, '2024-02-17', 11.50),
(9, 9, 3, '2024-02-18', 3.75),
(10, 10, 6, '2024-02-19', 7.50);

INSERT INTO Returns (sale_id, returned_quantity, return_date, reason) VALUES
(1, 2, '2024-02-20', 'Damaged packaging'),
(2, 1, '2024-02-21', 'Wrong product'),
(3, 3, '2024-02-22', 'Expired product'),
(4, 1, '2024-02-23', 'Customer request');
