import streamlit as st
import mysql.connector
import pandas as pd

# Page setup
st.set_page_config(page_title="Sales Intelligence Hub", layout="wide")

# Database Connection
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="root",  # MySQL கடவுச்சொல்லை உள்ளிடவும்
        database="sales_management_db"
    )

def execute_query(query, params=None):
    conn = get_connection()
    df = pd.read_sql(query, conn, params=params)
    conn.close()
    return df

def run_commit(query, params):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params)
    conn.commit()
    cursor.close()
    conn.close()

# Session State for Authentication
if "authenticated" not in st.session_state:
    st.session_state.authenticated = False
    st.session_state.user = None

# --- LOGIN SCREEN ---
if not st.session_state.authenticated:
    st.title("🔐 Sales Intelligence Hub - Login")
    with st.form("login_form"):
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")
        submit = st.form_submit_button("Sign In")

        if submit:
            user_df = execute_query(
                "SELECT * FROM users WHERE username = %s AND password = %s", 
                (username, password)
            )
            if not user_df.empty:
                st.session_state.authenticated = True
                st.session_state.user = user_df.iloc[0].to_dict()
                st.rerun()
            else:
                st.error("Invalid username or password.")
    st.stop()

# --- MAIN DASHBOARD (AUTHENTICATED) ---
user = st.session_state.user
st.sidebar.title(f"👤 {user['username']}")
st.sidebar.info(f"Role: {user['role']}")

if st.sidebar.button("Logout"):
    st.session_state.authenticated = False
    st.session_state.user = None
    st.rerun()

menu = st.sidebar.radio(
    "Navigation", 
    ["Overview & KPIs", "Sales Management", "Payment Splits", "Predefined SQL Queries"]
)

# Branch constraint for normal Admin
branch_filter = None if user['role'] == "Super Admin" else user['branch_id']

# 1. OVERVIEW & KPIS
if menu == "Overview & KPIs":
    st.title("📊 Executive Dashboard")

    query = "SELECT * FROM customer_sales"
    if branch_filter:
        query += f" WHERE branch_id = {branch_filter}"
    sales_df = execute_query(query)

    total_gross = sales_df['gross_sales'].sum() if not sales_df.empty else 0.0
    total_received = sales_df['received_amount'].sum() if not sales_df.empty else 0.0
    total_pending = sales_df['pending_amount'].sum() if not sales_df.empty else 0.0

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Gross Sales", f"₹{total_gross:,.2f}")
    col2.metric("Total Received", f"₹{total_received:,.2f}")
    col3.metric("Total Pending", f"₹{total_pending:,.2f}")

    st.subheader("Sales Overview")
    st.dataframe(sales_df, use_container_width=True)

# 2. SALES MANAGEMENT
elif menu == "Sales Management":
    st.title("📝 Add New Sale")
    branches = execute_query("SELECT branch_id, branch_name FROM branches")
    
    if user['role'] == "Admin":
        branch_opts = branches[branches['branch_id'] == user['branch_id']]
    else:
        branch_opts = branches

    with st.form("new_sale_form"):
        branch_map = dict(zip(branch_opts['branch_name'], branch_opts['branch_id']))
        selected_branch = st.selectbox("Branch", list(branch_map.keys()))
        date = st.date_input("Date")
        name = st.text_input("Customer Name")
        mobile = st.text_input("Mobile Number")
        product = st.selectbox("Product", ["DS", "DA", "BA", "FSD"])
        gross_sales = st.number_input("Gross Sales Amount", min_value=1.0, step=1000.0)
        
        if st.form_submit_button("Record Sale"):
            try:
                run_commit(
                    """INSERT INTO customer_sales (branch_id, date, name, mobile_number, product_name, gross_sales)
                       VALUES (%s, %s, %s, %s, %s, %s)""",
                    (branch_map[selected_branch], date, name, mobile, product, gross_sales)
                )
                st.success("Sale entry created successfully!")
            except Exception as e:
                st.error(f"Error: {e}")

# 3. PAYMENT SPLITS
elif menu == "Payment Splits":
    st.title("💳 Record Split Payment")
    
    sales_q = "SELECT sale_id, name, pending_amount FROM customer_sales WHERE status = 'Open'"
    if branch_filter:
        sales_q += f" AND branch_id = {branch_filter}"
    active_sales = execute_query(sales_q)

    if active_sales.empty:
        st.info("No open sales requiring payment.")
    else:
        sale_dict = {f"Sale #{row['sale_id']} - {row['name']} (Pending: ₹{row['pending_amount']})": row['sale_id'] 
                     for _, row in active_sales.iterrows()}
        selected_sale_label = st.selectbox("Select Sale Record", list(sale_dict.keys()))
        selected_sale_id = sale_dict[selected_sale_label]

        with st.form("payment_form"):
            pay_date = st.date_input("Payment Date")
            amount = st.number_input("Amount Paid", min_value=1.0, step=500.0)
            method = st.selectbox("Payment Method", ["UPI", "Cash", "Card"])
            
            if st.form_submit_button("Record Payment"):
                try:
                    run_commit(
                        """INSERT INTO payment_splits (sale_id, payment_date, amount_paid, payment_method)
                           VALUES (%s, %s, %s, %s)""",
                        (selected_sale_id, pay_date, amount, method)
                    )
                    st.success("Payment recorded. Database trigger has updated received & pending balances.")
                except Exception as e:
                    st.error(f"Error: {e}")

# 4. PREDEFINED SQL QUERIES
elif menu == "Predefined SQL Queries":
    st.title("🔍 SQL Analytical Query Viewer")
    
    query_options = {
        "1. Open Sales Records": "SELECT * FROM customer_sales WHERE status = 'Open'",
        "2. Branch-wise Gross Sales": """
            SELECT b.branch_name, SUM(s.gross_sales) AS total_gross 
            FROM branches b 
            LEFT JOIN customer_sales s ON b.branch_id = s.branch_id 
            GROUP BY b.branch_name
        """,
        "3. Payment Method-wise Collection": """
            SELECT payment_method, SUM(amount_paid) AS total_collected 
            FROM payment_splits 
            GROUP BY payment_method
        """,
        "4. High Pending Amounts (> ₹5,000)": """
            SELECT sale_id, name, gross_sales, received_amount, pending_amount 
            FROM customer_sales 
            WHERE pending_amount > 5000
        """
    }
    
    selected_query_label = st.selectbox("Select Predefined Query", list(query_options.keys()))
    selected_sql = query_options[selected_query_label]
    
    st.code(selected_sql, language="sql")
    result_df = execute_query(selected_sql)
    st.dataframe(result_df, use_container_width=True)