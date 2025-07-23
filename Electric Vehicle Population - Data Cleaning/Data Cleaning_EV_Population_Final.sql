------ Data Cleaning in MSSQL : Electric Vehicle Population Data ------

-- To view all data in raw dataset
SELECT *
FROM portfolio_projects..EV_Population;

-- To view datatype of all columns
SELECT 
COLUMN_NAME,
DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ev_population_staging';

-- Create a temporary dataset to work with 
-- This ensures the raw/original dataset remains unchanged during the cleaning process.
SELECT *
INTO ev_population_staging
FROM portfolio_projects..EV_Population;

-- To view all data in temporary table
SELECT *
FROM ev_population_staging; 

-- Standardization
-- Convert all column names to lowercase and replace spaces with underscores for consistency and best practices
EXEC sp_rename 'ev_population_staging.[Vin(1–10)]', 'vin';
EXEC sp_rename 'ev_population_staging.[Postal Code]', 'postal_code';
EXEC sp_rename 'ev_population_staging.[Model Year]', 'model_year';
EXEC sp_rename 'ev_population_staging.[Electric Vehicle Type]', 'electric_vehicle_type';
EXEC sp_rename 'ev_population_staging.[Electric Range]', 'electric_range';
EXEC sp_rename 'ev_population_staging.[Base MSRP]', 'base_msrp';
EXEC sp_rename 'ev_population_staging.[Legislative District]', 'legislative_district';
EXEC sp_rename 'ev_population_staging.[DOL Vehicle ID]', 'dol_vehicle_id';
EXEC sp_rename 'ev_population_staging.[Vehicle Location]', 'vehicle_location';
EXEC sp_rename 'ev_population_staging.[Electric Utility]', 'electric_utility';

-- Remove unnecessary white spaces from data values
SELECT TRIM(county)
FROM ev_population_staging;

UPDATE ev_population_staging
SET county = TRIM(county);

--Remove periods from text data
UPDATE ev_population_staging
SET state = LEFT(state, LEN(state) - 1)
WHERE RIGHT(state, 1) = '.';

-- Identify and remove duplicate records
-- This ensures data integrity by keeping only unique entries based on relevant columns

-- Check for duplicates 
WITH cte_duplicate AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY dol_vehicle_id ,vin ORDER BY model_year DESC ) AS row_num
FROM ev_population_staging
)
SELECT * 
FROM cte_duplicate
WHERE row_num > 1;

-- Delete the duplicates
WITH cte_duplicate AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY dol_vehicle_id ,vin ORDER BY model_year DESC ) AS row_num
FROM ev_population_staging
)
DELETE 
FROM cte_duplicate
WHERE row_num > 1

-- Fix inconsistent entries in categorical fields
-- Standardize values with varied spellings, casing, or formats 

SELECT DISTINCT make
FROM ev_population_staging
ORDER BY make desc;

UPDATE ev_population_staging
SET make = 'VOLKSWAGEN'
WHERE make LIKE 'VOLKSWAGEN%' 

UPDATE ev_population_staging
SET make = 'TESLA'
WHERE make LIKE 'TESLA%' 

UPDATE ev_population_staging
SET make = 'KIA'
WHERE make LIKE 'KIA%' 

-- Data type conversions
/* We can use either CONVERT or CAST to change data types within a specific query, 
   without modifying the table structure or original data.
   CONVERT is generally more reliable and flexible when working with DATE and DATETIME data types. */

SELECT postal_code, CAST(postal_code AS varchar(10)) AS new_postal_code
FROM ev_population_staging;

/* ALTER COLUMN permanently changes the data type of a column in the table, 
   which can affect all existing and future data stored in that column */

ALTER TABLE ev_population_staging
ALTER COLUMN postal_code VARCHAR(10);

ALTER TABLE ev_population_staging
ALTER COLUMN model_year INT;

ALTER TABLE ev_population_staging
ALTER COLUMN base_msrp INT;

ALTER TABLE ev_population_staging
ALTER COLUMN dol_vehicle_id BIGINT;

-- Handle missing or NULL values
-- Identify columns with NULLs and apply appropriate strategies

-- Count NULL values in each column
DECLARE @table_name NVARCHAR(100) = 'ev_population_staging';
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = STRING_AGG(
    'COUNT(CASE WHEN [' + COLUMN_NAME + '] IS NULL OR [' + COLUMN_NAME + '] = '''' THEN 1 END) AS [' + COLUMN_NAME + '_null_or_empty]',
    ', '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
  AND DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar', 'text');

SET @sql = 'SELECT ' + @sql + ' FROM ' + QUOTENAME(@table_name) + ';';

EXEC sp_executesql @sql;

-- Update NULL values in the City column
-- Fill missing city data using corresponding County, State, and Postal Code information
SELECT *
FROM ev_population_staging
WHERE city IS NULL;

UPDATE ev_population_staging
SET city = NULL
WHERE city = '';

SELECT *
FROM ev_population_staging ev1
JOIN ev_population_staging ev2
ON ev1.county = ev2.county
AND ev1.state = ev2.state
AND ev1.postal_code = ev2.postal_code
WHERE ev1.city IS NULL
AND ev2.city IS NOT NULL;

UPDATE  ev1
SET ev1.city = ev2.city
FROM ev_population_staging ev1
JOIN ev_population_staging ev2
  ON ev1.county = ev2.county
 AND ev1.state = ev2.state
 AND ev1.postal_code = ev2.postal_code
WHERE ev1.city IS NULL
  AND ev2.city IS NOT NULL;

-- Update NULL values in the Postal Code column
-- Fill missing Postal Code data using corresponding County, State, and City  information

SELECT *
FROM ev_population_staging
WHERE postal_code IS NULL;

UPDATE ev_population_staging
SET postal_code = NULL
WHERE postal_code = '';

SELECT *
FROM ev_population_staging ev1
JOIN ev_population_staging ev2
ON ev1.county = ev2.county
AND ev1.state = ev2.state
AND ev1.city = ev2.city
WHERE ev1.postal_code IS NULL
AND ev2.postal_code IS NOT NULL;

UPDATE  ev1
SET ev1.postal_code = ev2.postal_code
FROM ev_population_staging ev1
JOIN ev_population_staging ev2
  ON ev1.county = ev2.county
AND ev1.state = ev2.state
AND ev1.city = ev2.city
WHERE ev1.postal_code IS NULL
AND ev2.postal_code IS NOT NULL;

-- Update NULL values in the Make column
-- Fill missing Make data using corresponding Model Year and Model  information

SELECT *
FROM ev_population_staging
WHERE make IS NULL;

UPDATE ev_population_staging
SET make = NULL
WHERE make = '';

SELECT *
FROM ev_population_staging ev1
JOIN ev_population_staging ev2
ON ev1.model_year = ev2.model_year
AND ev1.model = ev2.model
WHERE ev1.make IS NULL
AND ev2.make IS NOT NULL;

UPDATE  ev1
SET ev1.make = ev2.make
FROM ev_population_staging ev1
JOIN ev_population_staging ev2
ON ev1.model_year = ev2.model_year
AND ev1.model = ev2.model
WHERE ev1.make IS NULL
AND ev2.make IS NOT NULL;

-- Remove irrelevant data
DELETE 
FROM ev_population_staging
WHERE postal_code IS NULL;

ALTER TABLE ev_population_staging
DROP COLUMN row_num;

-- Extract abbreviations using SUBSTRING and update them into a new column

/*  SUBSTRING: Extracts a portion of a string to standardize or format data values.
    Syntax: SUBSTRING(expression, start_position, length)
    CHARINDEX: Finds the starting position of a substring within a string.
    Syntax: CHARINDEX(substring, expression, start)*/

ALTER TABLE ev_population_staging
ADD vehicle_type_code VARCHAR(20);

UPDATE ev_population_staging
SET vehicle_type_code = SUBSTRING(
    electric_vehicle_type,
    CHARINDEX('(', electric_vehicle_type) + 1,
    CHARINDEX(')', electric_vehicle_type) - CHARINDEX('(', electric_vehicle_type) - 1);

UPDATE ev_population_staging
SET electric_vehicle_type = RTRIM(LTRIM(
    LEFT(electric_vehicle_type, CHARINDEX('(', electric_vehicle_type) - 1)
));