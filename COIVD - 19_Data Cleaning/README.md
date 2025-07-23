# Nashville Housing Data Cleaning Project
This SQL project focuses on cleaning and transforming a raw real estate dataset from Nashville, Tennessee, to prepare it for further analysis and visualization.

### Key Tasks Performed
- **Data Type Transformation:** Converted string-based date columns (SaleDate) into proper DATE format.
- **Missing Value Handling:** Used JOIN and ISNULL() to fill in missing PropertyAddress values based on matching ParcelID.
- **Data Normalization:** Split compound address fields (PropertyAddress, OwnerAddress) into separate columns for street, city, and state using SUBSTRING, CHARINDEX, and PARSENAME.
- **Column Standardization:** Cleaned up SoldAsVacant values by converting 'Y' and 'N' into more readable 'Yes' and 'No'.
- **Data Deduplication:** Removed duplicate records using ROW_NUMBER() and CTE (WITH clause) based on unique field combinations.
- **Schema Refinement:** Dropped unnecessary columns like OwnerAddress, TaxDistrict, and PropertyAddress after normalizing and splitting their contents.

The dataset is now clean, consistent, and ready for use in data visualization tools like Power BI or for advanced analysis in Python or R.
