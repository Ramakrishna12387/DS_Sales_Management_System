USE sales_management_db;

-- Branches
INSERT INTO branches (branch_id, branch_name, branch_admin_name) VALUES
(1, 'Chennai', 'Rajesh Kumar'),
(2, 'Delhi', 'Amit Sharma'),
(3, 'Bangalore', 'Priya Nair');

-- Users
INSERT INTO users (username, password, branch_id, role, email) VALUES
('superadmin', 'admin123', NULL, 'Super Admin', 'superadmin@saleshub.com'),
('admin_chennai', 'chennai123', 1, 'Admin', 'chennai@saleshub.com'),
('admin_delhi', 'delhi123', 2, 'Admin', 'delhi@saleshub.com');

-- Sales
INSERT INTO customer_sales (sale_id, branch_id, date, name, mobile_number, product_name, gross_sales) VALUES
(1, 1, '2026-03-01', 'Anand V', '9876543210', 'DS', 50000.00),
(2, 1, '2026-03-05', 'Kavitha R', '9876543211', 'DA', 40000.00),
(3, 2, '2026-03-08', 'Rohit Verma', '9876543212', 'FSD', 60000.00),
(4, 3, '2026-03-10', 'Deepa M', '9876543213', 'BA', 35000.00);

-- Payment Splits (Trigger will automatically update customer_sales)
INSERT INTO payment_splits (sale_id, payment_date, amount_paid, payment_method) VALUES
(1, '2026-03-01', 25000.00, 'UPI'),
(1, '2026-03-15', 25000.00, 'Card'), -- Clears Sale 1
(2, '2026-03-05', 20000.00, 'Cash'),  -- Partial for Sale 2
(3, '2026-03-08', 30000.00, 'UPI');   -- Partial for Sale 3