"""
Table CRUD Operations Screen
Provides SELECT, INSERT, UPDATE, and DELETE functionality for tables
"""

import tkinter as tk
from tkinter import messagebox, ttk
import db

class TableCRUDScreen:
    """Generic CRUD screen for database tables"""
    
    def __init__(self, root, table_name):
        self.root = root
        self.table_name = table_name
        self.table_info = db.TABLES[table_name]
        self.pk_column = self.table_info['primary_key']
        
        self.root.title(f"Manage {table_name}")
        self.root.geometry("1000x600")
        self.root.configure(bg='#f0f0f0')
        
        # Current data and selected row
        self.current_data = []
        self.selected_row = None
        
        self.create_widgets()
        self.refresh_data()
    
    def create_widgets(self):
        """Create CRUD interface"""
        
        # Title
        title_label = tk.Label(
            self.root,
            text=f"Managing: {self.table_name}",
            font=("Arial", 14, "bold"),
            bg='#f0f0f0'
        )
        title_label.pack(pady=10)
        
        # Button frame
        btn_frame = tk.Frame(self.root, bg='#f0f0f0')
        btn_frame.pack(pady=10)
        
        tk.Button(btn_frame, text="Insert", command=self.open_insert, bg='#4CAF50', fg='white', padx=10).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Update", command=self.open_update, bg='#2196F3', fg='white', padx=10).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Delete", command=self.delete_record, bg='#f44336', fg='white', padx=10).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Refresh", command=self.refresh_data, bg='#FFC107', fg='black', padx=10).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Close", command=self.root.quit, bg='#757575', fg='white', padx=10).pack(side=tk.LEFT, padx=5)
        
        # Table frame with scrollbar
        table_frame = tk.Frame(self.root, bg='white')
        table_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Create treeview
        self.tree = ttk.Treeview(table_frame, columns=self.table_info['display_columns'], height=15)
        self.tree.heading('#0', text='')
        self.tree.column('#0', width=0, stretch=tk.NO)
        
        for i, col in enumerate(self.table_info['display_columns']):
            self.tree.heading(i, text=col)
            self.tree.column(i, anchor=tk.W, width=100)
        
        # Scrollbars
        vsb = ttk.Scrollbar(table_frame, orient=tk.VERTICAL, command=self.tree.yview)
        hsb = ttk.Scrollbar(table_frame, orient=tk.HORIZONTAL, command=self.tree.xview)
        self.tree.configure(yscroll=vsb.set, xscroll=hsb.set)
        
        self.tree.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        hsb.grid(row=1, column=0, sticky='ew')
        
        table_frame.grid_rowconfigure(0, weight=1)
        table_frame.grid_columnconfigure(0, weight=1)
        
        # Bind selection
        self.tree.bind('<<TreeviewSelect>>', self.on_select)
    
    def refresh_data(self):
        """Refresh table data"""
        try:
            self.current_data = db.get_table_data(self.table_name)
            self.tree.delete(*self.tree.get_children())
            
            for row in self.current_data:
                values = [row.get(col) for col in self.table_info['columns']]
                self.tree.insert('', tk.END, values=values)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load data: {str(e)}")
    
    def on_select(self, event):
        """Handle row selection"""
        selection = self.tree.selection()
        if selection:
            self.selected_row = self.tree.index(selection[0])
    
    def open_insert(self):
        """Open insert dialog"""
        insert_window = tk.Toplevel(self.root)
        insert_window.title(f"Insert into {self.table_name}")
        insert_window.geometry("400x400")
        insert_window.configure(bg='#f0f0f0')
        
        # Form fields
        entries = {}
        columns_to_skip = [self.pk_column]  # Skip auto-increment primary key
        
        for col in self.table_info['columns']:
            if col not in columns_to_skip:
                frame = tk.Frame(insert_window, bg='#f0f0f0')
                frame.pack(pady=5, padx=20, fill=tk.X)
                
                label = tk.Label(frame, text=col, width=15, bg='#f0f0f0')
                label.pack(side=tk.LEFT)
                
                entry = tk.Entry(frame, width=25)
                entry.pack(side=tk.LEFT, padx=10)
                entries[col] = entry
        
        # Insert button
        def do_insert():
            try:
                data = {col: entry.get() for col, entry in entries.items() if entry.get()}
                db.insert_record(self.table_name, data)
                messagebox.showinfo("Success", "Record inserted successfully")
                self.refresh_data()
                insert_window.quit()
            except Exception as e:
                messagebox.showerror("Error", f"Insert failed: {str(e)}")
        
        tk.Button(insert_window, text="Insert", command=do_insert, bg='#4CAF50', fg='white', padx=20, pady=10).pack(pady=20)
    
    def open_update(self):
        """Open update dialog"""
        if self.selected_row is None:
            messagebox.showwarning("Warning", "Please select a row to update")
            return
        
        selected_item = self.tree.item(self.tree.selection()[0])
        pk_value = selected_item['values'][0]  # First column is primary key
        
        # Load current record
        try:
            record = db.get_table_by_pk(self.table_name, pk_value)
            if not record:
                messagebox.showerror("Error", "Record not found")
                return
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load record: {str(e)}")
            return
        
        update_window = tk.Toplevel(self.root)
        update_window.title(f"Update {self.table_name}")
        update_window.geometry("400x400")
        update_window.configure(bg='#f0f0f0')
        
        # Primary key display
        pk_frame = tk.Frame(update_window, bg='#f0f0f0')
        pk_frame.pack(pady=5, padx=20, fill=tk.X)
        tk.Label(pk_frame, text=f"{self.pk_column}:", width=15, bg='#f0f0f0').pack(side=tk.LEFT)
        tk.Label(pk_frame, text=str(pk_value), width=25, bg='#e0e0e0').pack(side=tk.LEFT, padx=10)
        
        # Form fields
        entries = {}
        for col in self.table_info['columns']:
            if col != self.pk_column:
                frame = tk.Frame(update_window, bg='#f0f0f0')
                frame.pack(pady=5, padx=20, fill=tk.X)
                
                label = tk.Label(frame, text=col, width=15, bg='#f0f0f0')
                label.pack(side=tk.LEFT)
                
                entry = tk.Entry(frame, width=25)
                entry.insert(0, str(record.get(col, '')))
                entry.pack(side=tk.LEFT, padx=10)
                entries[col] = entry
        
        # Update button
        def do_update():
            try:
                data = {col: entry.get() for col, entry in entries.items()}
                db.update_record(self.table_name, pk_value, data)
                messagebox.showinfo("Success", "Record updated successfully")
                self.refresh_data()
                update_window.quit()
            except Exception as e:
                messagebox.showerror("Error", f"Update failed: {str(e)}")
        
        tk.Button(update_window, text="Update", command=do_update, bg='#2196F3', fg='white', padx=20, pady=10).pack(pady=20)
    
    def delete_record(self):
        """Delete selected record"""
        if self.selected_row is None:
            messagebox.showwarning("Warning", "Please select a row to delete")
            return
        
        selected_item = self.tree.item(self.tree.selection()[0])
        pk_value = selected_item['values'][0]
        
        if messagebox.askyesno("Confirm", f"Delete record with {self.pk_column}={pk_value}?"):
            try:
                db.delete_record(self.table_name, pk_value)
                messagebox.showinfo("Success", "Record deleted successfully")
                self.refresh_data()
            except Exception as e:
                messagebox.showerror("Error", f"Delete failed: {str(e)}")
