# Sales Intelligence Hub — Project Documentation

## 1. Domain
Sales Analytics & Financial Tracking System.

## 2. Problem statement
Organizations with multiple branches need consistent tracking of sales, collected payments, outstanding balances, and payment methods. Manual tracking can cause calculation errors and poor visibility.

## 3. Objectives
- Store branch-wise sales records.
- Track partial payments.
- Automatically calculate received and pending amounts.
- Restrict branch Admin users to their own branch.
- Give Super Admin an overall view of all branches.
- Provide reports and predefined SQL analytics.

## 4. Technology stack
- Python
- MySQL
- Streamlit
- mysql-connector-python
- pandas

## 5. Database design
- `branches`: branch master data.
- `customer_sales`: customer sales transactions.
- `users`: Super Admin and Admin accounts.
- `payment_splits`: multiple payments per sale.

Relationships:
- One branch can have many sales.
- One branch can have many Admin users.
- One sale can have many payment split rows.

## 6. Financial logic
- `received_amount` is updated by a MySQL trigger after a payment row is inserted.
- `pending_amount` is a generated column: `gross_sales - received_amount`.
- Sale status becomes `Close` when received amount reaches gross sales; otherwise `Open`.
- The app prevents recording a payment greater than the currently pending amount.

## 7. Access control
- Super Admin can view all branches and add sales to any branch.
- Admin users are assigned a branch and can view/create sales and payments only for that branch.
- Passwords in the demo SQL are hashed with SHA-256 for this training project. For production deployment, use a modern password-hashing library such as Argon2 or bcrypt, enforce HTTPS, and keep secrets out of source control.

## 8. Dashboard
- KPI metrics: total gross sales, received amount, pending amount, pending collection percentage.
- Sales records and sales entry form.
- Payment split entry and payment history.
- Branch-wise sales, payment method summary, and date trends.
- Predefined SQL analytics.

## 9. Analytical SQL
`sql/03_analytical_queries.sql` contains basic retrieval, aggregations, joins, and financial tracking queries. The brief asks for any 15 analytical queries; this file provides more than 15 options.

## 10. Testing checklist
- [ ] Schema creates successfully.
- [ ] Demo rows are inserted.
- [ ] Demo logins work.
- [ ] Admin sees only their assigned branch.
- [ ] Super Admin sees all branches.
- [ ] A new sale is saved.
- [ ] A partial payment updates `received_amount`.
- [ ] `pending_amount` changes automatically.
- [ ] Fully paid sale status becomes `Close`.
- [ ] All report tabs render without errors.

## 11. Run locally
See `README.md` for setup and run instructions.

## 12. Limitations
The required brief specifies an `AFTER INSERT` trigger. The supplied trigger covers new payment rows. If payment rows are later edited or deleted directly in SQL, totals will not automatically recalculate; avoid those operations in this version or add corresponding update/delete triggers after instructor approval.
