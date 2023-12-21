SELECT *
FROM dbo.Cleanup

---Date Cleanup

SELECT SaleDate, CONVERT(date,SaleDate)
FROM dbo.Cleanup

UPDATE Cleanup
SET SaleDate = CONVERT(date,SaleDate)

Alter Table Cleanup
ADD SaleDateConverted Date;

UPDATE Cleanup
SET SaleDateConverted = CONVERT(date,SaleDate)

---Populated Property Address Data

SELECT *
FROM dbo.Cleanup
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM dbo.Cleanup a
Join dbo.Cleanup b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM dbo.Cleanup a
Join dbo.Cleanup b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


---Breaking Out Address into Individual Columns (Address, City, State) 

SELECT PropertyAddress
FROM dbo.Cleanup
--WHERE PropertyAddress is null
--ORDER BY ParcelID

---by using substring

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) AS ADDRESS,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS ADDRESS
FROM dbo.Cleanup

Alter Table Cleanup
ADD PropertySplitAddress Nvarchar(255);

UPDATE Cleanup
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)

Alter Table Cleanup
ADD PropertySplitCity Nvarchar(255);

UPDATE Cleanup
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

---by using parsing

SELECT *
FROM dbo.Cleanup

SELECT OwnerAddress
FROM dbo.Cleanup

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from dbo.Cleanup

Alter Table Cleanup
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Cleanup
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

Alter Table Cleanup
ADD OwnerSplitCity Nvarchar(255);

UPDATE Cleanup
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table Cleanup
ADD OwnerAddressSplitState Nvarchar(255);

UPDATE Cleanup
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

---Using Case statement to add clean up same format for SoldAsVacant column

SELECT *
FROM dbo.Cleanup

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM dbo.Cleanup
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
FROM dbo.Cleanup

UPDATE dbo.Cleanup 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

SELECT SoldAsVacant
FROM dbo.Cleanup

--REMOVE DUPLICATES not DONE NORMALLY

WITH rownumCTE as (SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by 
				UniqueID
				) row_num
FROM dbo.Cleanup
--Order by ParcelID
)DELETE FROM rownumCTE
WHERE row_num > 1

---REVIEW THAT DATA HAS BEEN REMOVED

WITH rownumCTE as (SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by 
				UniqueID
				) row_num
FROM dbo.Cleanup
--Order by ParcelID
)SELECT * FROM rownumCTE
WHERE row_num > 1


---DELETE UNUSED COLUMNS --NOT NORMALLY DONE IN PRACTICE WITH RAW DATA UPLOADED IN DATABASE

SELECT *
FROM dbo.Cleanup

ALTER TABLE Cleanup
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Cleanup
DROP COLUMN SaleDate

