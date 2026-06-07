/*
===============================================================================
Stored Procedure: silver.load_silver
===============================================================================

Script Purpose:
    This stored procedure loads data from the Bronze layer into the
    Silver layer of the Data Warehouse.

    The procedure performs data cleansing, standardization, validation,
    and transformation to improve data quality before it is consumed
    by downstream analytical models and reporting layers.

Processing Steps:
    1. Truncate existing Silver layer tables.
    2. Load customer data with:
       - Duplicate removal
       - Data standardization
       - Gender normalization
       - Marital status normalization

    3. Load product data with:
       - Category extraction
       - Product key transformation
       - Product line mapping
       - Product history end-date calculation

    4. Load sales data with:
       - Date validation and conversion
       - Sales amount validation
       - Price recalculation
       - Data quality corrections

    5. Load ERP customer data with:
       - Customer ID cleansing
       - Future birthdate validation
       - Gender standardization

    6. Load ERP location data with:
       - Country code normalization
       - Missing value handling

    7. Load ERP product category data.

Source Tables:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_cust_az12
    - bronze.erp_loc_a101
    - bronze.erp_px_cat_g1v2

Target Tables:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

Features:
    - ETL logging using PRINT statements
    - Load duration tracking
    - Batch execution monitoring
    - Error handling using TRY...CATCH
    - Data quality validation and cleansing

Warning:
    - This procedure truncates all Silver layer tables before loading.
    - Existing data in the Silver layer will be permanently removed.
    - Execute only after the Bronze layer has been successfully loaded.
    - Ensure all source files and Bronze tables are available before execution.

Execution:
    EXEC silver.load_silver;

===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
        BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=======================================================';
        PRINT 'Loading silver layer';
        PRINT '=======================================================';

        PRINT '-------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------------------------------';

        --Loading silver.crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting Data into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_martial_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lasttname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_martial_status, -- Normalize martial status values to readable format
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,-- Normalize gender values to readable format
            cst_create_date
        FROM (
            SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY cst_id
                        ORDER BY cst_create_date DESC
                    ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1; -- Select the most recent record per customer
        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
        PRINT'----------------'

        --Loading silver.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info
        PRINT '>> Inserting Data into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info(
        prd_id ,
        cat_id,
        prd_key ,
        prd_nm ,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt 
        )
        SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5) ,'-','_') AS cat_id, -- Extract Category id
        SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,		--Extract product key
        prd_nm,
        ISNULL(prd_cost,0) AS prd_cost,
        CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	            ELSE 'n/a'
        END AS prd_line,	--Map product line codes to descriptive values
        CAST (prd_start_dt AS DATE) AS prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 
        AS DATE
        ) AS prd_end_dt		-- Calculate end date as one day before the next start date
        FROM bronze.crm_prd_info

        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds'
        PRINT'----------------'

         --Loading silver.crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details
        PRINT '>> Inserting Data into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key ,
            sls_cust_id ,
            sls_order_dt ,
            sls_ship_dt,
            sls_due_dt ,
            sls_sales ,
            sls_quantity,
            sls_price 
        )

        SELECT 
        sls_ord_num ,
        sls_prd_key ,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	            ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
        END AS sls_order_dt,

        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	            ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
        END AS sls_ship_dt,

        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
	            ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
        END AS sls_due_dt,

        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
        END AS sls_sales,       --Recalculate sales if original value is missing or incorrect

        sls_quantity ,

        CASE WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales/ NULLIF(sls_quantity,0)
                ELSE sls_price     --Derive price if original value is invalid
        END AS sls_price
        FROM bronze.crm_sales_details

        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT'----------------';

        PRINT '-------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-------------------------------------------------------';
        --Loading silver.erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12
        PRINT '>> Inserting Data into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
        SELECT 
		        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING (cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
			        ELSE cid
	        END cid,
		        CASE WHEN bdate > GETDATE()
		            THEN NULL
		            ELSE bdate
	        END bdate,				--set future birthdates to null
		        CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			        ELSE 'n/a'
	        END AS gen				--Normalize gender values and handle unknown cases
        FROM bronze.erp_cust_az12
        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT'----------------';

    
        --Loading silver.erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101
        PRINT '>> Inserting Data into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101
        (cid,cntry)
        SELECT 
        REPLACE(cid,'-','') cid,
        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	            WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	            ELSE TRIM(cntry)
        END AS cntry --Normalize and Handle Missing or blank country codes
        FROM bronze.erp_loc_a101

        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT'----------------';


        --Loading silver.erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2
        PRINT '>> Inserting Data into: erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2
        (
        id,cat,subcat,maintenance
        )
        SELECT 
        id,
        cat,
        subcat,
        maintenance 
        FROM bronze.erp_px_cat_g1v2

        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT'----------------';
 
        SET @batch_end_time = GETDATE();
        PRINT '===========================================================';
        PRINT 'Loading Silver Layer is Completed ';
        PRINT '>>  - Toatl Load Duration :' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '===========================================================';

    END TRY
    BEGIN CATCH
        PRINT '===========================================================';
        PRINT 'ERROR OCCURED DURING LOAING SILVER LAYER' ;
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
        PRINT '===========================================================';
    END CATCH
END
