"""
Procedures and Functions Screen
Displays and executes Stage 4 functions and procedures
"""

import tkinter as tk
from tkinter import messagebox, ttk
import db

class ProceduresScreen:
    """Screen for viewing and executing functions and procedures"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Functions & Procedures")
        self.root.geometry("900x600")
        self.root.configure(bg='#f0f0f0')
        
        # Define functions and procedures
        self.procedures = {
            'Calculate Invoice Balance': {
                'type': 'function',
                'name': 'fn_calculate_invoice_balance',
                'params': [('Invoice ID', 'invoice_id', 'int')],
                'description': 'Calculate remaining balance for an invoice'
            },
            'Validate Payment Amount': {
                'type': 'function',
                'name': 'fn_validate_payment_amount',
                'params': [
                    ('Invoice ID', 'invoice_id', 'int'),
                    ('Payment Amount', 'amount', 'float')
                ],
                'description': 'Validate if payment amount is acceptable'
            },
            'Process Refund': {
                'type': 'procedure',
                'name': 'sp_process_refund',
                'params': [
                    ('Payment ID', 'payment_id', 'int'),
                    ('Refund Amount', 'amount', 'float'),
                    ('Reason', 'reason', 'text')
                ],
                'description': 'Process a refund for a payment'
            },
            'Update Insurance Claim': {
                'type': 'procedure',
                'name': 'sp_update_insurance_claim_status',
                'params': [
                    ('Claim ID', 'claim_id', 'int'),
                    ('New Status', 'status', 'text'),
                    ('Staff ID', 'staff_id', 'int')
                ],
                'description': 'Update insurance claim status'
            }
        }
        
        self.create_widgets()
    
    def create_widgets(self):
        """Create procedures screen widgets"""
        
        # Title
        title_label = tk.Label(
            self.root,
            text="Functions & Procedures",
            font=("Arial", 14, "bold"),
            bg='#f0f0f0'
        )
        title_label.pack(pady=10)
        
        # Main content frame
        content_frame = tk.Frame(self.root, bg='#f0f0f0')
        content_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Left frame for procedure list
        left_frame = tk.Frame(content_frame, bg='white', relief=tk.SUNKEN, bd=1)
        left_frame.pack(side=tk.LEFT, fill=tk.Y, padx=5)
        
        list_label = tk.Label(left_frame, text="Available Functions/Procedures", bg='white', font=("Arial", 10, "bold"))
        list_label.pack(pady=5, padx=5)
        
        self.proc_listbox = tk.Listbox(left_frame, width=25, height=20)
        self.proc_listbox.pack(padx=5, pady=5, fill=tk.BOTH, expand=True)
        self.proc_listbox.bind('<<ListboxSelect>>', self.on_select_procedure)
        
        for proc_name in self.procedures.keys():
            self.proc_listbox.insert(tk.END, proc_name)
        
        # Right frame for details and execution
        right_frame = tk.Frame(content_frame, bg='#f0f0f0')
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=5)
        
        # Description
        desc_frame = tk.Frame(right_frame, bg='#f0f0f0')
        desc_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Label(desc_frame, text="Description:", bg='#f0f0f0', font=("Arial", 10, "bold")).pack(anchor=tk.W)
        self.desc_label = tk.Label(desc_frame, text="", bg='#f0f0f0', wraplength=400, justify=tk.LEFT)
        self.desc_label.pack(anchor=tk.W)
        
        # Parameters frame
        param_frame = tk.Frame(right_frame, bg='#f0f0f0')
        param_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Label(param_frame, text="Parameters:", bg='#f0f0f0', font=("Arial", 10, "bold")).pack(anchor=tk.W)
        
        # Scrollable parameters area
        params_scroll = tk.Frame(param_frame)
        params_scroll.pack(fill=tk.BOTH, expand=True)
        
        self.params_canvas = tk.Canvas(params_scroll, bg='white', highlightthickness=0, height=200)
        scrollbar = ttk.Scrollbar(params_scroll, orient=tk.VERTICAL, command=self.params_canvas.yview)
        self.params_frame = tk.Frame(self.params_canvas, bg='white')
        
        self.params_frame.bind(
            "<Configure>",
            lambda e: self.params_canvas.configure(scrollregion=self.params_canvas.bbox("all"))
        )
        
        self.params_canvas.create_window((0, 0), window=self.params_frame, anchor="nw")
        self.params_canvas.configure(yscrollcommand=scrollbar.set)
        
        self.params_canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Execute button
        execute_btn = tk.Button(
            right_frame,
            text="Execute",
            command=self.execute_procedure,
            bg='#FF9800',
            fg='white',
            padx=20,
            pady=10,
            font=("Arial", 10, "bold")
        )
        execute_btn.pack(pady=10)
        
        # Results frame
        results_frame = tk.Frame(right_frame, bg='white', relief=tk.SUNKEN, bd=1)
        results_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        tk.Label(results_frame, text="Results:", bg='white', font=("Arial", 10, "bold")).pack(pady=5)
        
        self.results_text = tk.Text(results_frame, height=10, width=50, bg='#f5f5f5')
        self.results_text.pack(padx=5, pady=5, fill=tk.BOTH, expand=True)
        
        # Close button
        close_btn = tk.Button(
            right_frame,
            text="Close",
            command=self.root.quit,
            bg='#757575',
            fg='white',
            padx=20,
            pady=5
        )
        close_btn.pack(pady=5)
        
        # Store parameter entries
        self.param_entries = {}
    
    def on_select_procedure(self, event):
        """Handle procedure selection"""
        selection = self.proc_listbox.curselection()
        if not selection:
            return
        
        proc_name = self.proc_listbox.get(selection[0])
        proc_info = self.procedures[proc_name]
        
        # Update description
        self.desc_label.config(text=proc_info['description'])
        
        # Clear previous parameters
        for widget in self.params_frame.winfo_children():
            widget.destroy()
        self.param_entries.clear()
        
        # Create parameter entries
        for display_name, param_name, param_type in proc_info['params']:
            frame = tk.Frame(self.params_frame, bg='white')
            frame.pack(fill=tk.X, padx=5, pady=5)
            
            label = tk.Label(frame, text=f"{display_name} ({param_type}):", bg='white', width=20, anchor=tk.W)
            label.pack(side=tk.LEFT)
            
            entry = tk.Entry(frame, width=30)
            entry.pack(side=tk.LEFT, padx=10)
            
            self.param_entries[param_name] = (entry, param_type)
    
    def execute_procedure(self):
        """Execute selected procedure"""
        selection = self.proc_listbox.curselection()
        if not selection:
            messagebox.showwarning("Warning", "Please select a procedure")
            return
        
        proc_name = self.proc_listbox.get(selection[0])
        proc_info = self.procedures[proc_name]
        
        try:
            # Collect parameters
            params = []
            for param_name, (entry, param_type) in self.param_entries.items():
                value = entry.get()
                if not value:
                    messagebox.showwarning("Warning", f"Please enter {param_name}")
                    return
                
                # Convert to appropriate type
                if param_type == 'int':
                    value = int(value)
                elif param_type == 'float':
                    value = float(value)
                
                params.append(value)
            
            # Execute function or procedure
            if proc_info['type'] == 'function':
                results = db.execute_function(proc_info['name'], params)
            else:
                results = db.execute_procedure(proc_info['name'], params)
            
            # Display results
            self.results_text.delete('1.0', tk.END)
            
            if results:
                for row in results:
                    if isinstance(row, dict):
                        for key, value in row.items():
                            self.results_text.insert(tk.END, f"{key}: {value}\n")
                    else:
                        self.results_text.insert(tk.END, str(row) + "\n")
            
            messagebox.showinfo("Success", f"{proc_name} executed successfully")
        
        except ValueError as e:
            messagebox.showerror("Input Error", f"Invalid input: {str(e)}")
        except Exception as e:
            messagebox.showerror("Execution Error", f"Failed to execute: {str(e)}")
