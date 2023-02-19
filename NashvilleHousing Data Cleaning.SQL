/*
Cleaning Nashville Housing Data 

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;



--Populate Property Adress
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL 

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
Order BY ParcelID


SELECT a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing   a
JOIN   PortfolioProject..NashvilleHousing  b
ON a.ParcelID= b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing   a
JOIN   PortfolioProject..NashvilleHousing  b
ON a.ParcelID= b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Check if there still any PropertyAdress NULL
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL



--Transforming Adress into individual Columns (Address, city, State)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(250);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(250);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


--Now do the same for OwnerAddress

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(250);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	END
 
 -- Testing 
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant




---Remove Duplicates 
--Create a CTE 
WITH ROWNUM AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
			) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM ROWNUM
WHERE row_num>1
--ORDER BY PropertyAddress


--Delete Unused Data 

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict*

SELECT *
FROM PortfolioProject..NashvilleHousing
