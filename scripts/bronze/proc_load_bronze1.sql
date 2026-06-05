/*
===============================================================================
Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
    This stored procedure loads raw data from CSV source files into the
    Bronze layer tables of the Data Warehouse.

    The procedure performs the following tasks:
    - Truncates existing data from Bronze tables.
    - Loads CRM source data using BULK INSERT.
    - Loads ERP source data using BULK INSERT.
    - Tracks and displays load duration for each table.
    - Tracks and displays total batch execution time.
    - Handles and reports loading errors.

Source Files:
    CRM:
    - cust_info.csv
    - prd_info.csv
    - sales_details.csv

    ERP:
    - cust_az12.csv
    - loc_a101.csv
    - px_cat_g1v2.csv

Target Tables:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_cust_az12
    - bronze.erp_loc_a101
    - bronze.erp_px_cat_g1v2

Warning:
    - This procedure truncates all Bronze layer tables before loading data.
    - Existing data in the target tables will be permanently removed.
    - Ensure source file paths are valid and accessible before execution.
Usage Example:
      Execute bronze.load_bronze1;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze1 as 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT'======================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT'======================================================================';

		PRINT'----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT'----------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting into Table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\sathwika\OneDrive\Documents\Desktop\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR =',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT'----------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Insering into Table: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\sathwika\OneDrive\Documents\Desktop\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR =',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT'----------------';


        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting into Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\sathwika\OneDrive\Documents\Desktop\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR =',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT'----------------';

		PRINT'----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT'----------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting into Table: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\sathwika\OneDrive\Documents\Desktop\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR =',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT'----------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting into Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\sathwika\OneDrive\Documents\Desktop\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR =',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT'----------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting into Table: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\sathwika\OneDrive\Documents\Desktop\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR =',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT'>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT'----------------';


	    SET @batch_end_time = GETDATE();
		PRINT '========================================================';
		PRINT 'Loading Bronze Layer is Completed';
	    PRINT'  - Total Load Duration : ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT'=========================================================';
	END TRY
	BEGIN CATCH

		PRINT '========================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================';

	END CATCH

END
