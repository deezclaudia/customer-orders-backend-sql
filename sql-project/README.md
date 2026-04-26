# Order Management System (SQL Backend)

## Overview

This project is a backend-oriented relational database system built using SQL (Oracle).
It simulates a real-world order management environment, including customers, orders, products, and inventory control.

The system incorporates advanced database features such as:

* Stored procedures
* User-defined functions
* Triggers
* Business rules enforcement
* Audit logging

---

## Architecture & Features

### Core Modules

* **Orders Management**

  * Order creation and tracking
  * Order item insertion with validations

* **Customer Analytics**

  * Total spending per customer
  * Order aggregation functions

* **Inventory Control**

  * Automatic stock validation
  * Inventory updates via triggers

* **Audit System**

  * Tracks INSERT, UPDATE, DELETE operations on orders

---

## Technical Implementation

### Functions

* `fnc_total_pedido` → Calculates total amount per order
* `fnc_total_cliente` → Calculates total spending per customer
* `fnc_validar_stock` → Validates product availability
* `fnc_desc_pedido` → Generates order descriptions

### Stored Procedures

* `prc_crear_pedido` → Creates new orders
* `prc_insertar_item` → Inserts order items with stock validation
* `prc_reporte_pedidos` → Generates order reports
* `prc_reporte_clientes` → Generates customer reports
* `prc_update_precios` → Bulk price updates

### Triggers

* `trg_valida_precio` → Prevents invalid product pricing
* `trg_audit_orders` → Logs all order activity
* `trg_update_inventory` → Updates stock after purchases
* `trg_limite_credito` → Restricts excessive orders per customer
* `trg_control_stock` → Prevents overselling

---

## Technologies

* SQL (Oracle PL/SQL)
* Relational Database Design
* Transaction Control
* Data Integrity & Constraints

---

## Getting Started

### 1. Requirements

* Oracle Database (or compatible environment)
* SQL Developer / any SQL client

### 2. Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/sql-project.git
   ```

2. Open your SQL environment

3. Run:

   ```sql
   @backend.sql
   ```

---

## Testing

The project includes test queries and execution examples:

```sql
SELECT fnc_total_pedido(1) FROM dual;
EXEC prc_reporte_pedidos;
```

---

## Business Rules Implemented

* Orders cannot be created beyond a customer limit
* Products cannot have negative pricing
* Orders cannot exceed available inventory
* All order operations are audited automatically

---

## Project Structure

```
sql-project/
│
├── backend.sql   # Main database logic
└── README.md     # Project documentation
```

---

## Author

**Claudia Hernandez Garcia**

---

## Portfolio Note

This project demonstrates practical backend database skills, including:

* Business logic implementation in SQL
* Data validation and integrity enforcement
* Real-world system simulation

---

## Contact

If you are a recruiter or collaborator, feel free to reach out.
