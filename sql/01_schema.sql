-- 1. Database Creation
CREATE DATABASE IF NOT EXISTS sales_management_db;
USE sales_management_db;

-- 2. Branches Table
CREATE TABLE IF NOT EXISTS branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    branch_admin_name VARCHAR(100) NOT NULL
);

-- 3. Users Table (Role-based Authentication)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    branch_id INT NULL,
    role ENUM('Super Admin', 'Admin') NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE SET NULL
);

-- 4. Customer Sales Table
CREATE TABLE IF NOT EXISTS customer_sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    date DATE NOT NULL,
    name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL UNIQUE,
    product_name VARCHAR(30) NOT NULL,
    gross_sales DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    received_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    pending_amount DECIMAL(12,2) AS (gross_sales - received_amount) STORED,
    status ENUM('Open', 'Close') NOT NULL DEFAULT 'Open',
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE CASCADE
);

-- 5. Payment Splits Table
CREATE TABLE IF NOT EXISTS payment_splits (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES customer_sales(sale_id) ON DELETE CASCADE
);

-- 6. Trigger: Update received_amount and status on Payment Insert
DELIMITER $$
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON payment_splits
FOR EACH ROW
BEGIN
    DECLARE total_received DECIMAL(12, 2);
    DECLARE total_gross DECIMAL(12, 2);

    -- Calculate current total paid for the sale
    SELECT IFNULL(SUM(amount_paid), 0.00) INTO total_received
    FROM payment_splits
    WHERE sale_id = NEW.sale_id;

    -- Fetch gross sale amount
    SELECT gross_sales INTO total_gross
    FROM customer_sales
    WHERE sale_id = NEW.sale_id;

    -- Update received amount and set status to 'Close' if fully paid
    UPDATE customer_sales
    SET 
        received_amount = total_received,
        status = CASE 
            WHEN total_received >= total_gross THEN 'Close'
            ELSE 'Open'
        END
    WHERE sale_id = NEW.sale_id;
END$$
DELIMITER ;