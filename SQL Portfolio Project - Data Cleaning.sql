/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM PortfolioProject.dbo.NashvilleHouse

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT CONVERT(date,SaleDate) 
FROM PortfolioProject.dbo.NashvilleHouse

UPDATE NashvilleHouse
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHouse
ALTER COLUMN Saledate DATE


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT *
FROM PortfolioProject.dbo.NashvilleHouse
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHouse a
JOIN PortfolioProject.dbo.NashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHouse a
JOIN PortfolioProject.dbo.NashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHouse

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHouse

ALTER TABLE NashvilleHouse
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHouse
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHouse

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHouse

ALTER TABLE NashvilleHouse
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHouse
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHouse
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHouse
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHouse

UPDATE NashvilleHouse
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) as row_num
FROM PortfolioProject.dbo.NashvilleHouse
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM PortfolioProject.dbo.NashvilleHouse

ALTER TABLE PortfolioProject.dbo.NashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


-----------------------------------------------------------------------------------------------