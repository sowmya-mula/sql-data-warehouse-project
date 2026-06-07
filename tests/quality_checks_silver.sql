/*
===============================================================================
Data Quality Checks - Silver Layer
===============================================================================

Script Purpose:
    Validate data quality after loading the Silver layer.

Expected Result:
    All queries should return zero rows unless data quality issues exist.
===============================================================================
*/

-- =============================================================================
-- silver.crm_cust_info
-- =============================================================================

-- Check for NULLs or duplicate customer IDs
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
   OR cst_id IS NULL;

-- Check invalid marital status values
SELECT DISTINCT cst_martial_status
FROM silver.crm_cust_info
WHERE cst_martial_status NOT IN ('Single', 'Married', 'n/a');

-- Check invalid gender values
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');

-- Check for leading/trailing spaces
SELECT *
FROM silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname);

-- Check for empty first names
SELECT *
FROM silver.crm_cust_info
WHERE cst_firstname IS NULL
   OR TRIM(cst_firstname) = '';

-- Check for empty last names
SELECT *
FROM silver.crm_cust_info
WHERE cst_lastname IS NULL
   OR TRIM(cst_lastname) = '';
-- =============================================================================
-- silver.crm_prd_info
-- =============================================================================

-- Check for duplicate product keys
SELECT
    prd_key,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- Check for NULL product keys
SELECT *
FROM silver.crm_prd_info
WHERE prd_key IS NULL;

-- Check invalid product line values
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
WHERE prd_line NOT IN
(
    'Mountain',
    'Road',
    'Touring',
    'Other Sales',
    'n/a'
);

-- Check invalid date ranges
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Check for negative product costs
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0;

-- Check for NULL product names
SELECT *
FROM silver.crm_prd_info
WHERE prd_nm IS NULL;

-- =============================================================================
-- silver.crm_sales_details
-- =============================================================================

-- Check for NULL order numbers
SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL;

-- Check future order dates
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > GETDATE();

-- Check ship dates before order dates
SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt < sls_order_dt;

-- Check due dates before order dates
SELECT *
FROM silver.crm_sales_details
WHERE sls_due_dt < sls_order_dt;

-- Check sales calculations
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * ABS(sls_price);

-- Check invalid quantities
SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0;

-- Check for NULL customer IDs
SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL;

-- Check for NULL product keys
SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL;

-- Check for negative prices
SELECT *
FROM silver.crm_sales_details
WHERE sls_price < 0;

-- =============================================================================
-- silver.erp_cust_az12
-- =============================================================================

-- Check for NULL customer IDs
SELECT *
FROM silver.erp_cust_az12
WHERE cid IS NULL;

-- Check future birth dates
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Check invalid gender values
SELECT DISTINCT gen
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a');


-- =============================================================================
-- silver.erp_loc_a101
-- =============================================================================

-- Check for NULL customer IDs
SELECT *
FROM silver.erp_loc_a101
WHERE cid IS NULL;

-- Check blank country values
SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';

-- Review country normalization
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- =============================================================================
-- silver.erp_px_cat_g1v2
-- =============================================================================

-- Check duplicate IDs
SELECT
    id,
    COUNT(*) AS record_count
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;

-- Check NULL IDs
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL;

-- Check missing category information
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat IS NULL
   OR subcat IS NULL;

-- Check for duplicate category IDs
SELECT
    id,
    COUNT(*)
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;
