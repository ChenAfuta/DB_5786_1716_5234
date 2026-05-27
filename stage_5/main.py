"""
Main Application Entry Point
Stage 5 - PostgreSQL Database GUI Application
"""

import tkinter as tk
from tkinter import messagebox
import sys
import os

# Add screens directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'screens'))

from screens.table_crud import TableCRUDScreen
from screens.queries_screen import QueriesScreen
from screens.procedures_screen import ProceduresScreen
import db

class MainMenuScreen:
    """Main menu screen for the application"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Database Management System - Main Menu")
        self.root.geometry("600x500")
        self.root.configure(bg='#f0f0f0')
        
        # Test database connection
        try:
            db.get_connection().close()
        except Exception as e:
            messagebox.showerror("Connection Error", f"Failed to connect to database:\n{str(e)}")
            self.root.quit()
            return
        
        self.create_widgets()
    
    def create_widgets(self):
        """Create main menu widgets"""
        
        # Title
        title_label = tk.Label(
            self.root,
            text="Database Management System",
            font=("Arial", 24, "bold"),
            bg='#f0f0f0',
            fg='#333'
        )
        title_label.pack(pady=20)
        
        subtitle_label = tk.Label(
            self.root,
            text="Billing & Finance Division Database",
            font=("Arial", 12),
            bg='#f0f0f0',
            fg='#666'
        )
        subtitle_label.pack(pady=5)
        
        # Separator
        separator = tk.Frame(self.root, height=2, bg='#cccccc')
        separator.pack(fill=tk.X, pady=10)
        
        # Menu buttons frame
        button_frame = tk.Frame(self.root, bg='#f0f0f0')
        button_frame.pack(pady=20)
        
        # Table management buttons
        table_label = tk.Label(button_frame, text="Table Management", font=("Arial", 12, "bold"), bg='#f0f0f0')
        table_label.pack(pady=10)
        
        tables = ['BILLING_STAFF', 'INVOICE', 'INVOICE_ITEM', 'PAYMENT', 'REFUND', 'INSURANCE_CLAIM']
        for table in tables:
            btn = tk.Button(
                button_frame,
                text=f"Manage {table}",
                width=30,
                command=lambda t=table: self.open_table_crud(t),
                bg='#4CAF50',
                fg='white',
                font=("Arial", 10),
                padx=10,
                pady=8
            )
            btn.pack(pady=5)
        
        # Separator
        sep2 = tk.Frame(button_frame, height=1, bg='#cccccc')
        sep2.pack(fill=tk.X, pady=10)
        
        # Queries and procedures buttons
        query_btn = tk.Button(
            button_frame,
            text="View Queries",
            width=30,
            command=self.open_queries,
            bg='#2196F3',
            fg='white',
            font=("Arial", 10),
            padx=10,
            pady=8
        )
        query_btn.pack(pady=5)
        
        proc_btn = tk.Button(
            button_frame,
            text="Run Functions/Procedures",
            width=30,
            command=self.open_procedures,
            bg='#FF9800',
            fg='white',
            font=("Arial", 10),
            padx=10,
            pady=8
        )
        proc_btn.pack(pady=5)
        
        # Separator
        sep3 = tk.Frame(button_frame, height=1, bg='#cccccc')
        sep3.pack(fill=tk.X, pady=10)
        
        # Exit button
        exit_btn = tk.Button(
            button_frame,
            text="Exit",
            width=30,
            command=self.root.quit,
            bg='#f44336',
            fg='white',
            font=("Arial", 10),
            padx=10,
            pady=8
        )
        exit_btn.pack(pady=5)
    
    def open_table_crud(self, table_name):
        """Open table CRUD screen"""
        crud_window = tk.Toplevel(self.root)
        TableCRUDScreen(crud_window, table_name)
    
    def open_queries(self):
        """Open queries screen"""
        query_window = tk.Toplevel(self.root)
        QueriesScreen(query_window)
    
    def open_procedures(self):
        """Open procedures screen"""
        proc_window = tk.Toplevel(self.root)
        ProceduresScreen(proc_window)

def main():
    """Main application entry point"""
    root = tk.Tk()
    app = MainMenuScreen(root)
    root.mainloop()

if __name__ == "__main__":
    main()
