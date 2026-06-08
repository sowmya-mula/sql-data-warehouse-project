/*
===============================================================================
DATA CATALOG - GOLD LAYER
===============================================================================

TABLE: gold.dim_customers
PURPOSE:
Stores customer master data enriched from CRM and ERP systems.
Used for customer analytics, segmentation, and sales reporting.

COLUMNS:
--------------------------------------------------------------------------------
customer_key     : Surrogate key generated in the data warehouse.
customer_id      : Unique customer identifier from source system.
customer_number  : Business customer key.
first_name       : Customer first name.
last_name        : Customer last name.
country          : Customer country.
marital_status   : Customer marital status.
gender           : Customer gender. CRM data takes precedence; ERP data is used
                   when CRM gender is unavailable.
birthdate        : Customer date of birth.
create_date      : Date customer record was created.

===============================================================================

TABLE: gold.dim_products
PURPOSE:
Stores current active products enriched with category information.
Used for product analysis, category reporting, and sales analytics.

COLUMNS:
--------------------------------------------------------------------------------
product_key      : Surrogate key generated in the data warehouse.
product_id       : Unique product identifier from source system.
product_number   : Business product key.
product_name     : Product name.
category_id      : Product category identifier.
category         : Product category.
subcategory      : Product subcategory.
maintenance      : Product maintenance classification.
cost             : Product cost.
product_line     : Product line classification.
start_date       : Product activation date.

===============================================================================

TABLE: gold.fact_sales
PURPOSE:
Stores sales transactions and links customers and products for
business reporting and analytics.

COLUMNS:
--------------------------------------------------------------------------------
order_number     : Unique sales order number.
product_key      : Reference to gold.dim_products.
customer_key     : Reference to gold.dim_customers.
order_date       : Date the order was placed.
shipping_date    : Date the order was shipped.
due_date         : Expected delivery date.
sales_amount     : Total sales value of the transaction.
quantity         : Quantity sold.
price            : Unit selling price.

===============================================================================

DATA MODEL
===============================================================================

fact_sales
    |
    |-- customer_key --> dim_customers.customer_key
    |
    |-- product_key  --> dim_products.product_key

===============================================================================
*/
