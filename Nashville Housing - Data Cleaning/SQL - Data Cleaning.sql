SELECT  *
FROM PortfolioProject..NashvilleHousing

/* To find DATATYPE of specific column */

SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NASHVILLEHOUSING'
	  AND
	  COLUMN_NAME ='SaleDateFormat';

/* To find the USER name */
SELECT SUSER_SNAME()

/* To find the user have permission to do changes to the data */

select *
from sys.fn_my_permissions('PortfolioProject..NashvilleHousing', 'object')


/* we can use either CONVERT or CAST for changing datatypes 
but CONVERT is more reliable for changing DATE TIME datatype*/

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM PortfolioProject..NashvilleHousing 

SELECT SaleDate,CAST(SaleDate AS DATE) AS NEWDATE
FROM PortfolioProject..NashvilleHousing

/* Alter, update, drop column in the table.
Alter Add - Add new column */

ALTER TABLE NashvilleHousing
ADD Family nvarchar(200)

UPDATE NashvilleHousing
SET Family=CONVERT(nvarchar(200), LandUse)

ALTER TABLE NashvilleHousing
DROP COLUMN Family

UPDATE PortfolioProject..NashvilleHousing
SET  LandUse = 'MULTI FAMILY'
WHERE UniqueID = '5871'


--------------------------------

ALTER TABLE NashvilleHousing
ADD SaleDateFormat	DATE

UPDATE NashvilleHousing
SET SaleDateFormat = CONVERT(DATE, SaleDate)

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

/*ISNULL() Return the specified value IF the expression is NULL, otherwise return the expression:
		ISNULL(expression, value) */

SELECT tableA.ParcelID,tableA.PropertyAddress,tableB.ParcelID,tableB.PropertyAddress,
		ISNULL(tableA.PropertyAddress,tableB.PropertyAddress) 		
FROM PortfolioProject..NashvilleHousing tableA
JOIN PortfolioProject..NashvilleHousing tableB
ON tableA.ParcelID = tableB.ParcelID
AND tableA.[UniqueID ]<>tableB.[UniqueID ]
WHERE tableA.PropertyAddress IS NULL

/* Update the tableA.PropertyAddress column which has null value */

UPDATE tableA
SET PropertyAddress=ISNULL(tableA.PropertyAddress,tableB.PropertyAddress)
FROM PortfolioProject..NashvilleHousing tableA
JOIN PortfolioProject..NashvilleHousing tableB
On tableA.ParcelID = tableB.ParcelID
AND tableA.[UniqueID ]<>tableB.[UniqueID ]
WHERE tableA.PropertyAddress IS NULL

/* Breaking out Address into individual columns */

SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing

/* SUBSTRING -extracts some characters from a string. 
   SUBSTRING(Expression, start, length)
   CHARINDEX -Searches for a substring in a string, and returns the position. 
   CHARINDEX('Substring',expression/string,start) */

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

/* Creating new column for street and city and update it using substring and charindex */

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyStreetAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyCityAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


/*  methods to split the text 
	1. Using SUBSTRING and CHARINDEX
	2. PARSENAME
*/

SELECT OwnerAddress,
SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) AS StreetAddress,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress) +1,10 ) AS CityAddress,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+12 ,LEN(OwnerAddress)) AS StateAddress
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress,REPLACE(OwnerAddress,',','.') AS newOwner,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerStreetAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


/* To get limited no.of results */

SELECT TOP 10 * 
FROM PortfolioProject..NashvilleHousing

/* OFFSET anf FETCH only work in conjunction with an ORDER BY clause */
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY [UniqueID ]
OFFSET 0 ROWS
FETCH FIRST 50 ROWS ONLY

/* Change Y and N as YES and NO */

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END
FROM PortfolioProject..NashvilleHousing

/* Remove Duplicates - Can be done by CTE, RANK , GROUPBY & HAVING */
/* Using CTE ( Common Table Expression) */
/* ROW_NUMBER , PARTITION BY */

WITH RowNum AS(
		SELECT ROW_NUMBER() OVER(PARTITION BY ParcelID,
									 PropertyAddress, 
									 SalePrice,
									 SaleDate,
									 LegalReference
									 ORDER BY UniqueID) row_num
		FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNum
WHERE row_num > 1


-- Delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate