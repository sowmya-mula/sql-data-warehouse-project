/*
===============================================================================
QUALITY CHECKS - GOLD LAYER
===============================================================================
*/

-- ============================================================================
-- DIM_CUSTOMERS CHECKS
-- ============================================================================

-- Check for duplicate customer keys
SELECT customer_key, COUNT(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check for duplicate business customer IDs
SELECT customer_id, COUNT(*)
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check for null customer keys
SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;

-- Check for unwanted gender values
SELECT DISTINCT gender
FROM gold.dim_customers;

-- Check for future birthdates
SELECT *
FROM gold.dim_customers
WHERE birthdate > GETDATE();

-- Check for future create dates
SELECT *
FROM gold.dim_customers
WHERE create_date > GETDATE();


-- ============================================================================
-- DIM_PRODUCTS CHECKS
-- ============================================================================

-- Check for duplicate product keys
SELECT product_key, COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Check for duplicate business product IDs
SELECT product_id, COUNT(*)
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check for null product keys
SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;

-- Check for null product names
SELECT *
FROM gold.dim_products
WHERE product_name IS NULL;

-- Check for negative product costs
SELECT *
FROM gold.dim_products
WHERE cost < 0;

-- Check category distribution
SELECT category, COUNT(*)
FROM gold.dim_products
GROUP BY category
ORDER BY COUNT(*) DESC;


-- ============================================================================
-- FACT_SALES CHECKS
-- ============================================================================

-- Check for null foreign keys
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;

-- Check for orphan customer records
SELECT *
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON fs.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

-- Check for orphan product records
SELECT *
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key
WHERE dp.product_key IS NULL;

-- Check for negative sales amounts
SELECT *
FROM gold.fact_sales
WHERE sales_amount < 0;

-- Check for negative quantities
SELECT *
FROM gold.fact_sales
WHERE quantity < 0;

-- Check for negative prices
SELECT *
FROM gold.fact_sales
WHERE price < 0;

-- Check sales calculation consistency
SELECT *
FROM gold.fact_sales
WHERE ABS(sales_amount - (quantity * price)) > 1;

-- Check order date validity
SELECT *
FROM gold.fact_sales
WHERE order_date > GETDATE();

-- Check shipping date before order date
SELECT *
FROM gold.fact_sales
WHERE shipping_date < order_date;

-- Check due date before order date
SELECT *
FROM gold.fact_sales
WHERE due_date < order_date;


-- ============================================================================
-- STAR SCHEMA VALIDATION
-- ============================================================================

-- Row counts
SELECT COUNT(*) AS customer_count
FROM gold.dim_customers;

SELECT COUNT(*) AS product_count
FROM gold.dim_products;

SELECT COUNT(*) AS sales_count
FROM gold.fact_sales;

-- Check referential integrity
SELECT COUNT(*) AS missing_customers
FROM gold.fact_sales
WHERE customer_key IS NULL;

SELECT COUNT(*) AS missing_products
FROM gold.fact_sales
WHERE product_key IS NULL;

-- Revenue validation
SELECT
    SUM(sales_amount) AS total_revenue,
    SUM(quantity) AS total_quantity,
    AVG(price) AS average_price
FROM gold.fact_sales;


