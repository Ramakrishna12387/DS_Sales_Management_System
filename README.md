# Sales Intelligence Hub - Branch-Based Sales Management System

## Overview
A centralized, branch-based financial and sales tracking platform built using Python, MySQL, and Streamlit. The system implements database-level automation (Triggers and Generated Columns) to calculate balances and updates in real-time with role-based access control (Super Admin vs Admin).

## Architecture & Database Design
- **branches**: Stores regional branch and branch-admin details.
- **users**: Handles credentials and role-based access ('Super Admin', 'Admin').
- **customer_sales**: Main transaction table; includes `pending_amount` as a generated column (`gross_sales - received_amount`).
- **payment_splits**: Records multi-installment payments for a sale.
- **Trigger (`trg_after_payment_insert`)**: Automatically updates `received_amount` and alters status (`Open`/`Close`) on `payment_splits` insertion.

## Tech Stack
- Backend: MySQL 8.0+
- Frontend / Dashboard: Streamlit
- Language: Python 3.x
- Connectors: `mysql-connector-python`, `pandas`

## Setup & Execution
1. Import `schema.sql` and `seed_data.sql` into your local MySQL server.
2. Update database credentials inside `app.py` in `get_connection()`.
3. Install dependencies: `pip install -r requirements.txt`.
4. Run application: `streamlit run app.py`.