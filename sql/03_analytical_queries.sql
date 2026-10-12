USE sales_management_db;

-- 🔹 Basic Queries (4)
-- Q1: All records from customer_sales
SELECT * FROM customer_sales;

-- Q2: All records from branches
SELECT * FROM branches;

-- Q3: All records from payment_splits
SELECT * FROM payment_splits;

-- Q4: Sales with status = 'Open'
SELECT * FROM customer_sales WHERE status = 'Open';

-- 🔹 Aggregation Queries (4)
-- Q5: Total gross sales across all branches
SELECT SUM(gross_sales) AS total_gross_sales FROM customer_sales;

-- Q6: Total received amount across all sales
SELECT SUM(received_amount) AS total_received FROM customer_sales;

-- Q7: Total pending amount across all sales
SELECT SUM(pending_amount) AS total_pending FROM customer_sales;

-- Q8: Count of sales per branch
SELECT branch_id, COUNT(*) AS sales_count FROM customer_sales GROUP BY branch_id;

-- 🔹 Join-Based Queries (4)
-- Q9: Sales details along with branch name
SELECT s.sale_id, s.name, s.gross_sales, b.branch_name 
FROM customer_sales s
JOIN branches b ON s.branch_id = b.branch_id;

-- Q10: Branch-wise total gross sales
SELECT b.branch_name, SUM(s.gross_sales) AS branch_gross_sales
FROM branches b
LEFT JOIN customer_sales s ON b.branch_id = s.branch_id
GROUP BY b.branch_id, b.branch_name;

-- Q11: Sales along with payment method used
SELECT s.sale_id, s.name, p.amount_paid, p.payment_method, p.payment_date
FROM customer_sales s
JOIN payment_splits p ON s.sale_id = p.sale_id;

-- Q12: Sales along with branch admin name
SELECT s.sale_id, s.name, b.branch_name, b.branch_admin_name
FROM customer_sales s
JOIN branches b ON s.branch_id = b.branch_id;

-- 🔹 Financial Tracking Queries (3)
-- Q13: Sales where pending amount > 5000
SELECT sale_id, name, gross_sales, received_amount, pending_amount 
FROM customer_sales 
WHERE pending_amount > 5000;

-- Q14: Top 3 highest gross sales
SELECT sale_id, name, gross_sales 
FROM customer_sales 
ORDER BY gross_sales DESC 
LIMIT 3;

-- Q15: Payment method-wise total collection
SELECT payment_method, SUM(amount_paid) AS total_collected
FROM payment_splits
GROUP BY payment_method;