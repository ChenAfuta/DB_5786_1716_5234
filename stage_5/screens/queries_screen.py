"""
Queries Screen
Displays and executes Stage 2 queries
"""

import tkinter as tk
from tkinter import messagebox, ttk
import db

class QueriesScreen:
    """Screen for viewing and executing queries"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Queries Screen")
        self.root.geometry("1000x600")
        self.root.configure(bg='#f0f0f0')
        
        # Query results
        self.results = None
        
        # Define queries from Stage 2
        self.queries = {
            'Payment Summary by Invoice': '''
                SELECT 
                    i.invoice_id,
                    i.total_amount,
                    COUNT(p.payment_id) as payment_count,
                    SUM(p.amount) as total_paid,
                    (i.total_amount - COALESCE(SUM(p.amount), 0)) as remaining_balance
                FROM INVOICE i
                LEFT JOIN PAYMENT p ON i.invoice_id = p.invoice_id
                GROUP BY i.invoice_id, i.total_amount
                ORDER BY i.invoice_id
            ''',
            
            'Claims by Status': '''
                SELECT 
                    claim_status,
                    COUNT(*) as claim_count,
                    COUNT(DISTINCT invoice_id) as invoice_count
                FROM INSURANCE_CLAIM
                GROUP BY claim_status
                ORDER BY claim_status
            ''',
            
            'Invoice Processing Status': '''
                SELECT 
                    processing_status,
                    COUNT(*) as invoice_count,
                    SUM(total_amount) as total_amount,
                    AVG(total_amount) as avg_amount
                FROM INVOICE
                GROUP BY processing_status
                ORDER BY processing_status
            ''',
            
            'Refunds Summary': '''
                SELECT 
                    r.refund_id,
                    r.payment_id,
                    r.refund_date,
                    r.amount,
                    r.refund_reason,
                    p.amount as original_payment_amount
                FROM REFUND r
                INNER JOIN PAYMENT p ON r.payment_id = p.payment_id
                ORDER BY r.refund_date DESC
            ''',
            
            'Payment Methods Distribution': '''
                SELECT 
                    payment_method,
                    COUNT(*) as payment_count,
                    SUM(amount) as total_amount,
                    AVG(amount) as avg_amount
                FROM PAYMENT
                GROUP BY payment_method
                ORDER BY total_amount DESC
            '''
        }
        
        self.create_widgets()
    
    def create_widgets(self):
        """Create query screen widgets"""
        
        # Title
        title_label = tk.Label(
            self.root,
            text="Database Queries",
            font=("Arial", 14, "bold"),
            bg='#f0f0f0'
        )
        title_label.pack(pady=10)
        
        # Query buttons frame
        btn_frame = tk.Frame(self.root, bg='#f0f0f0')
        btn_frame.pack(pady=10)
        
        for query_name in self.queries.keys():
            btn = tk.Button(
                btn_frame,
                text=query_name,
                command=lambda q=query_name: self.execute_query(q),
                bg='#2196F3',
                fg='white',
                padx=20,
                pady=8,
                wraplength=150
            )
            btn.pack(side=tk.LEFT, padx=5)
        
        tk.Button(btn_frame, text="Close", command=self.root.quit, bg='#757575', fg='white', padx=10).pack(side=tk.LEFT, padx=5)
        
        # Results frame
        results_frame = tk.Frame(self.root, bg='white')
        results_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Status label
        self.status_label = tk.Label(results_frame, text="Select a query to execute", bg='white', fg='#666')
        self.status_label.pack(pady=5)
        
        # Treeview for results
        self.tree = ttk.Treeview(results_frame, height=15)
        self.tree.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Scrollbars
        vsb = ttk.Scrollbar(results_frame, orient=tk.VERTICAL, command=self.tree.yview)
        hsb = ttk.Scrollbar(results_frame, orient=tk.HORIZONTAL, command=self.tree.xview)
        self.tree.configure(yscroll=vsb.set, xscroll=hsb.set)
    
    def execute_query(self, query_name):
        """Execute a query and display results"""
        try:
            query = self.queries[query_name]
            results = db.execute_query(query)
            
            # Clear previous results
            for item in self.tree.get_children():
                self.tree.delete(item)
            
            if not results:
                self.status_label.config(text=f"Query '{query_name}' returned no results", fg='#FF9800')
                return
            
            # Get column names
            columns = list(results[0].keys())
            self.tree['columns'] = columns
            self.tree.heading('#0', text='')
            self.tree.column('#0', width=0, stretch=tk.NO)
            
            for col in columns:
                self.tree.heading(col, text=col)
                self.tree.column(col, anchor=tk.W, width=120)
            
            # Insert data
            for row in results:
                values = [row.get(col, '') for col in columns]
                self.tree.insert('', tk.END, values=values)
            
            self.status_label.config(
                text=f"Query '{query_name}' returned {len(results)} row(s)", 
                fg='#4CAF50'
            )
        except Exception as e:
            messagebox.showerror("Query Error", f"Failed to execute query: {str(e)}")
            self.status_label.config(text="Query failed", fg='#f44336')
