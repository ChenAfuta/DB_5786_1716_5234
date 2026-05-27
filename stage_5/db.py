"""
Database Connection Module
Handles all PostgreSQL database connections and queries
"""

import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection details
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'billing_db')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')

def get_connection():
    """
    Create and return a database connection
    
    Returns:
        psycopg2 connection object
    """
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except psycopg2.Error as e:
        raise Exception(f"Failed to connect to database: {str(e)}")

def execute_query(query, params=None, fetch_one=False):
    """
    Execute a SELECT query and return results
    
    Args:
        query: SQL query string
        params: Query parameters (optional)
        fetch_one: If True, return single row; if False, return all rows
        
    Returns:
        Single row, list of rows, or None
    """
    conn = get_connection()
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(query, params)
        if fetch_one:
            result = cur.fetchone()
        else:
            result = cur.fetchall()
        cur.close()
        return result
    except psycopg2.Error as e:
        raise Exception(f"Query error: {str(e)}")
    finally:
        conn.close()

def execute_update(query, params=None):
    """
    Execute an INSERT, UPDATE, or DELETE query
    
    Args:
        query: SQL query string
        params: Query parameters (optional)
        
    Returns:
        Number of affected rows
    """
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(query, params)
        affected_rows = cur.rowcount
        conn.commit()
        cur.close()
        return affected_rows
    except psycopg2.Error as e:
        conn.rollback()
        raise Exception(f"Update error: {str(e)}")
    finally:
        conn.close()

def execute_procedure(proc_name, params=None):
    """
    Execute a stored procedure
    
    Args:
        proc_name: Procedure name
        params: Procedure parameters (optional)
        
    Returns:
        Output parameters from procedure
    """
    conn = get_connection()
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        if params:
            placeholders = ','.join(['%s'] * len(params))
            cur.execute(f"CALL {proc_name}({placeholders})", params)
        else:
            cur.execute(f"CALL {proc_name}()")
        result = cur.fetchall()
        conn.commit()
        cur.close()
        return result
    except psycopg2.Error as e:
        conn.rollback()
        raise Exception(f"Procedure error: {str(e)}")
    finally:
        conn.close()

def execute_function(func_name, params=None):
    """
    Execute a stored function
    
    Args:
        func_name: Function name
        params: Function parameters (optional)
        
    Returns:
        Function result
    """
    conn = get_connection()
    try:
        cur = conn.cursor(cursor_factory=RealDictCursor)
        if params:
            placeholders = ','.join(['%s'] * len(params))
            cur.execute(f"SELECT {func_name}({placeholders})", params)
        else:
            cur.execute(f"SELECT {func_name}()")
        result = cur.fetchall()
        cur.close()
        return result
    except psycopg2.Error as e:
        raise Exception(f"Function error: {str(e)}")
    finally:
        conn.close()

# Table definitions
TABLES = {
    'BILLING_STAFF': {
        'primary_key': 'billing_staff_id',
        'columns': ['billing_staff_id', 'staff_id', 'role'],
        'display_columns': ['ID', 'Staff ID', 'Role']
    },
    'INVOICE': {
        'primary_key': 'invoice_id',
        'columns': ['invoice_id', 'patient_id', 'admission_id', 'invoice_date', 
                   'total_amount', 'processing_status', 'processed_date', 'processing_staff_id'],
        'display_columns': ['Invoice ID', 'Patient ID', 'Admission ID', 'Date', 
                           'Amount', 'Status', 'Processed Date', 'Staff ID']
    },
    'INVOICE_ITEM': {
        'primary_key': 'item_id',
        'columns': ['item_id', 'invoice_id', 'service_name', 'cost'],
        'display_columns': ['Item ID', 'Invoice ID', 'Service', 'Cost']
    },
    'PAYMENT': {
        'primary_key': 'payment_id',
        'columns': ['payment_id', 'invoice_id', 'payment_date', 'amount', 'payment_method', 'payment_status'],
        'display_columns': ['Payment ID', 'Invoice ID', 'Date', 'Amount', 'Method', 'Status']
    },
    'REFUND': {
        'primary_key': 'refund_id',
        'columns': ['refund_id', 'payment_id', 'refund_date', 'amount', 'refund_reason'],
        'display_columns': ['Refund ID', 'Payment ID', 'Date', 'Amount', 'Reason']
    },
    'INSURANCE_CLAIM': {
        'primary_key': 'claim_id',
        'columns': ['claim_id', 'invoice_id', 'insurance_id', 'claim_status', 'claim_date', 'claim_processed_date'],
        'display_columns': ['Claim ID', 'Invoice ID', 'Insurance ID', 'Status', 'Claim Date', 'Processed Date']
    }
}

def get_table_data(table_name):
    """Get all data from a table"""
    query = f"SELECT * FROM {table_name} ORDER BY {TABLES[table_name]['primary_key']}"
    return execute_query(query)

def get_table_by_pk(table_name, pk_value):
    """Get a single record by primary key"""
    pk_column = TABLES[table_name]['primary_key']
    query = f"SELECT * FROM {table_name} WHERE {pk_column} = %s"
    return execute_query(query, (pk_value,), fetch_one=True)

def insert_record(table_name, data):
    """Insert a record into a table"""
    columns = list(data.keys())
    placeholders = ','.join(['%s'] * len(columns))
    query = f"INSERT INTO {table_name} ({','.join(columns)}) VALUES ({placeholders})"
    values = tuple(data.values())
    return execute_update(query, values)

def update_record(table_name, pk_value, data):
    """Update a record in a table"""
    pk_column = TABLES[table_name]['primary_key']
    set_clause = ','.join([f"{k}=%s" for k in data.keys()])
    query = f"UPDATE {table_name} SET {set_clause} WHERE {pk_column}=%s"
    values = tuple(list(data.values()) + [pk_value])
    return execute_update(query, values)

def delete_record(table_name, pk_value):
    """Delete a record from a table"""
    pk_column = TABLES[table_name]['primary_key']
    query = f"DELETE FROM {table_name} WHERE {pk_column}=%s"
    return execute_update(query, (pk_value,))
