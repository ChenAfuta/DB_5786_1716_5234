# Stage 5: PostgreSQL Database GUI Application

## Project Overview

This is a comprehensive desktop application for managing a PostgreSQL database in the Billing & Finance Division system. The application provides a user-friendly graphical interface for database operations, including CRUD (Create, Read, Update, Delete) operations on all database tables, predefined queries, and execution of stored functions and procedures.

## Technology Stack

- **Python 3.x**: Programming language
- **Tkinter**: GUI framework (included with Python)
- **psycopg2**: PostgreSQL adapter for Python
- **python-dotenv**: Environment variable management

## Installation

### Prerequisites

- Python 3.7 or higher
- PostgreSQL database server running and accessible
- pip (Python package manager)

### Setup Steps

1. **Clone or download the project** to your local machine.

2. **Install required packages**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure database connection**:
   Edit the `.env` file with your database credentials:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=billing_db
   DB_USER=postgres
   DB_PASSWORD=your_password
   ```

4. **Ensure database is initialized**:
   - Run all SQL scripts from Stage 1-4 in your PostgreSQL database
   - The database must have all tables and stored procedures created

## Running the Application

To start the application:

```bash
python main.py
```

The main menu window will open, from which you can navigate to all application features.

## Application Structure

### File Organization

```
stage_5/
├── main.py                    # Application entry point
├── db.py                      # Database connection and utilities
├── .env                       # Database credentials
├── requirements.txt           # Python dependencies
├── README_RUN.md             # This file
├── screenshots/              # Folder for application screenshots
└── screens/
    ├── __init__.py
    ├── table_crud.py         # CRUD operations for tables
    ├── queries_screen.py     # Pre-defined queries
    └── procedures_screen.py  # Functions and procedures execution
```

### Module Descriptions

#### `main.py`
- Entry point for the application
- Displays the main menu with navigation buttons
- Tests database connection on startup

#### `db.py`
- Database connection management
- Helper functions for CRUD operations
- Query and procedure execution functions
- Table definitions and metadata

#### `screens/table_crud.py`
- Generic CRUD interface for all database tables
- SELECT: View all records with refresh capability
- INSERT: Add new records to tables
- UPDATE: Modify existing records (loads current values)
- DELETE: Remove records with confirmation

#### `screens/queries_screen.py`
- Executes pre-defined SQL queries from Stage 2
- Displays results in a table view
- Included queries:
  - Payment Summary by Invoice
  - Claims by Status
  - Invoice Processing Status
  - Refunds Summary
  - Payment Methods Distribution

#### `screens/procedures_screen.py`
- Executes stored functions and procedures from Stage 4
- Supports parameter input
- Displays execution results
- Included functions/procedures:
  - Calculate Invoice Balance
  - Validate Payment Amount
  - Process Refund
  - Update Insurance Claim Status

## Features and Operations

### 1. Main Menu
- Clean interface with clear navigation
- Direct access to all table management screens
- Quick access to queries and procedures
- Exit button to close the application

### 2. Table Management (CRUD Operations)

#### Supported Tables
- **BILLING_STAFF**: Staff assigned to billing roles
- **INVOICE**: Billing invoices
- **INVOICE_ITEM**: Service items on invoices
- **PAYMENT**: Payments for invoices
- **REFUND**: Refunds for payments
- **INSURANCE_CLAIM**: Insurance claims related to invoices

#### SELECT (View)
- Displays all records in a table view
- Columns are clearly labeled
- Scrollable for large datasets
- Refresh button to reload data
- Row selection for update/delete operations

#### INSERT (Create)
- Form-based data entry
- Input validation
- Automatically generates primary keys where applicable
- Success confirmation message
- Automatic table refresh after insertion

#### UPDATE (Edit)
- Select a record from the table
- Click "Update" button
- System loads current values into edit form
- Edit desired fields
- Save changes with confirmation
- Table refreshes to show updated data

#### DELETE (Remove)
- Select a record from the table
- Click "Delete" button
- Confirmation dialog prevents accidental deletion
- Record removed from database
- Table refreshes automatically

### 3. Queries Screen
- Access 5 pre-built queries for data analysis
- Each query displays results in table format
- Status messages show number of returned rows
- Examples:
  - Summarize payments by invoice
  - Analyze claim distributions by status
  - View invoice processing statistics
  - Track refund activities
  - Analyze payment methods usage

### 4. Functions & Procedures Screen
- Execute 4 important database functions and procedures
- Parameter input fields for each procedure
- Results displayed clearly
- Includes:
  - **Calculate Invoice Balance**: Get remaining balance for an invoice
  - **Validate Payment Amount**: Check if payment is acceptable
  - **Process Refund**: Create and log a refund
  - **Update Insurance Claim**: Change claim status and related invoices

## Database Connection

The application uses environment variables for database configuration. The `.env` file should contain:

```
DB_HOST=localhost          # Database server hostname
DB_PORT=5432             # PostgreSQL default port
DB_NAME=billing_db       # Database name
DB_USER=postgres         # Database user
DB_PASSWORD=password     # Database password
```

**Important**: Never commit actual passwords to version control. Use secure credential management in production.

## Error Handling

The application includes comprehensive error handling:
- Database connection failures are caught and reported
- Invalid input is validated before submission
- SQL errors are displayed in user-friendly messages
- Confirmation dialogs prevent accidental data loss

## User Interface Design

### Visual Design Principles
- Clean, professional appearance
- Consistent color scheme:
  - Green (#4CAF50): Insert/Create operations
  - Blue (#2196F3): Update/View operations
  - Orange (#FF9800): Execute/Run operations
  - Red (#f44336): Delete/Dangerous operations
  - Gray (#757575): Navigation/Exit

### Usability Features
- Clear button labels
- Intuitive navigation flow
- Status messages for all operations
- Confirmation dialogs for destructive actions
- Error messages with actionable information
- Scrollable areas for large datasets

## Screenshots

Screenshots of the application should be placed in the `screenshots/` folder:
- `01_main_menu.png` - Main menu screen
- `02_table_crud_select.png` - Table view with SELECT
- `03_insert_operation.png` - INSERT form
- `04_update_operation.png` - UPDATE form
- `05_delete_confirmation.png` - DELETE confirmation
- `06_queries_screen.png` - Queries execution
- `07_procedures_screen.png` - Functions/procedures screen

## Troubleshooting

### Connection Issues
- Verify PostgreSQL is running
- Check database credentials in `.env` file
- Ensure database name and user exist
- Check network connectivity to database server

### Missing Tables
- Run Stage 1-4 SQL scripts to create tables
- Verify all ALTER TABLE statements from Stage 4 were executed
- Check database object privileges

### Procedure Not Found Errors
- Ensure Stage 4 SQL files were executed
- Check function/procedure names match Stage 4 definitions
- Verify procedures are in the correct database

## Future Enhancements

Possible improvements for future versions:
- User authentication and role-based access
- Data export to CSV/Excel
- Advanced filtering and search
- Batch import from files
- Transaction history and audit logs
- Performance optimization for large datasets
- Multi-language support

## Support

For issues or questions:
1. Check database connection settings
2. Verify all SQL scripts have been executed
3. Review error messages in the application
4. Check terminal output for detailed error logs

## License

This application was developed as part of a database course project.

---

**Last Updated**: May 2026
**Version**: 1.0
